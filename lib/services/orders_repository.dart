import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';
import 'supabase_service.dart';

class OrdersRepository {
  /// Writes the order and its line items to Supabase, then asks the
  /// notify-new-order edge function to email the store owner. Returns the
  /// new order's id. Throws if Supabase isn't configured or the order/items
  /// insert fails — the checkout screen decides what to show the customer
  /// in that case. A failure to *send the email* never fails the order:
  /// the customer's purchase already succeeded by that point.
  static Future<String> create({
    required String fullName,
    required String email,
    required String address,
    required String phone1,
    required String phone2,
    required String paymentMethod,
    required CartProvider cart,
  }) async {
    if (!SupabaseConfig.isConfigured) {
      throw StateError('Supabase isn\'t configured, so orders can\'t be saved.');
    }
    final orderRow = await SupabaseService.client
        .from('orders')
        .insert({
          'full_name': fullName,
          'email': email,
          'address': address,
          'phone_1': phone1,
          'phone_2': phone2,
          'payment_method': paymentMethod,
          'subtotal': cart.subtotal,
          'shipping': cart.shipping,
          'total': cart.total,
        })
        .select('id')
        .single();

    final orderId = orderRow['id'] as String;

    final items = cart.lines
        .map((line) => {
              'order_id': orderId,
              'product_id': line.product.id,
              'product_name': line.product.name,
              'unit_price': line.product.price,
              'quantity': line.quantity,
            })
        .toList();

    await SupabaseService.client.from('order_items').insert(items);

    // Bumps each purchased product's running sales_count atomically via a
    // Postgres function (so concurrent checkouts never race/clobber each
    // other) — powers the storefront's "Best sellers" section. Never
    // blocks or fails the order: a hiccup here just means that section is
    // a beat behind, not that the purchase failed.
    _incrementSalesCounts(items);

    _notifyOwner(
      fullName: fullName,
      email: email,
      address: address,
      phone1: phone1,
      phone2: phone2,
      paymentMethod: paymentMethod,
      cart: cart,
      items: items,
    );

    return orderId;
  }

  /// Fire-and-forget call to bump `products.sales_count` for everything in
  /// this order, via the `increment_product_sales` Postgres function (see
  /// supabase/schema.sql). Only logs on failure — never blocks checkout.
  static void _incrementSalesCounts(List<Map<String, dynamic>> items) {
    final payload = items
        .map((i) => {'product_id': i['product_id'], 'quantity': i['quantity']})
        .where((i) => i['product_id'] != null)
        .toList();
    if (payload.isEmpty) return;
    SupabaseService.client.rpc('increment_product_sales', params: {'items': payload}).catchError((e) {
      debugPrint('Carnet: incrementing product sales_count failed (order still saved fine): $e');
    });
  }

  /// Fire-and-forget call to the notify-new-order edge function. Any error
  /// here (function not deployed yet, Resend key missing, etc.) is only
  /// logged — it must never block or fail the checkout flow. This is
  /// separate from — and in addition to — the WhatsApp message the
  /// checkout screen opens directly on the customer's phone.
  static void _notifyOwner({
    required String fullName,
    required String email,
    required String address,
    required String phone1,
    required String phone2,
    required String paymentMethod,
    required CartProvider cart,
    required List<Map<String, dynamic>> items,
  }) {
    SupabaseService.client.functions.invoke(
      'notify-new-order',
      body: {
        'order': {
          'full_name': fullName,
          'email': email,
          'address': address,
          'phone_1': phone1,
          'phone_2': phone2,
          'payment_method': paymentMethod,
          'subtotal': cart.subtotal,
          'shipping': cart.shipping,
          'total': cart.total,
        },
        'items': items,
      },
    ).catchError((e) {
      debugPrint('Carnet: new-order email notification failed (order still saved fine): $e');
    });
  }

  /// Fetches all orders (newest first) with their line items, for the admin
  /// dashboard's Orders view. Requires the admin to be signed in — the
  /// `orders`/`order_items` tables are only readable by authenticated
  /// requests per the RLS policies in supabase/schema.sql.
  static Future<List<Order>> fetchAll() async {
    if (!SupabaseConfig.isConfigured) return [];
    final data = await SupabaseService.client
        .from('orders')
        .select('*, order_items(*)')
        .order('created_at', ascending: false);
    return (data as List)
        .map((row) => Order.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  /// Marks an order done (or reopens it) so the owner can track which
  /// orders still need attention. Throws on failure so the UI can show an
  /// error instead of silently pretending it worked.
  static Future<void> setCompleted(String orderId, bool completed) async {
    await SupabaseService.client
        .from('orders')
        .update({'is_completed': completed})
        .eq('id', orderId);
  }

  /// Permanently deletes an order (and, via "on delete cascade" in
  /// supabase/schema.sql, its order_items rows) from Supabase. Throws on
  /// failure so the UI can show an error instead of silently pretending it
  /// worked. Requires the "Authenticated can delete orders" policy — run
  /// the updated schema.sql if this fails with a permissions error on an
  /// existing project.
  static Future<void> delete(String orderId) async {
    await SupabaseService.client.from('orders').delete().eq('id', orderId);
  }

  /// Counts orders not yet marked done, for the red badge on the Orders
  /// icon in the dashboard. Returns 0 if Supabase isn't configured or the
  /// request fails, so a hiccup here never blocks the dashboard from
  /// showing.
  static Future<int> countPending() async {
    if (!SupabaseConfig.isConfigured) return 0;
    try {
      final data = await SupabaseService.client
          .from('orders')
          .select('id')
          .eq('is_completed', false);
      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }
}

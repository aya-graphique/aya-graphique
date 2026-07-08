import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/product.dart';
import 'supabase_service.dart';

class ProductsRepository {
  /// True if the most recent fetchAll() actually returned rows from
  /// Supabase. False means the request failed or returned nothing — check
  /// the browser console (F12) for the logged reason why.
  static bool lastFetchWasLive = false;

  /// Fetches the catalog from Supabase. Returns an empty list if Supabase
  /// isn't configured yet, the table is empty, or the request fails for
  /// any reason (e.g. offline, RLS blocking the read).
  static Future<List<Product>> fetchAll() async {
    if (!SupabaseConfig.isConfigured) {
      lastFetchWasLive = false;
      return [];
    }
    try {
      final data = await SupabaseService.client
          .from('products')
          .select()
          .order('sort_order', ascending: true);
      final rows = (data as List)
          .map((row) => Product.fromMap(row as Map<String, dynamic>))
          .toList();
      if (rows.isEmpty) {
        debugPrint(
          'Carnet: the "products" table in Supabase is empty. Add a product '
          'from the admin dashboard, or check that it actually saved.',
        );
        lastFetchWasLive = false;
        return [];
      }
      lastFetchWasLive = true;
      return rows;
    } catch (e) {
      debugPrint(
        'Carnet: fetching products from Supabase failed. Real error was:\n$e',
      );
      lastFetchWasLive = false;
      return [];
    }
  }

  static Future<void> create(Product product) async {
    await SupabaseService.client.from('products').insert(product.toInsertMap());
  }

  static Future<void> update(String id, Product product) async {
    await SupabaseService.client
        .from('products')
        .update(product.toInsertMap())
        .eq('id', id);
  }

  static Future<void> delete(String id) async {
    await SupabaseService.client.from('products').delete().eq('id', id);
  }
}

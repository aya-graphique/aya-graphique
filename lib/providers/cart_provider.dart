import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/settings_repository.dart';

class CartLine {
  final Product product;
  final int quantity;

  const CartLine({required this.product, required this.quantity});

  double get lineTotal => product.discountedPrice * quantity;

  CartLine copyWith({int? quantity}) =>
      CartLine(product: product, quantity: quantity ?? this.quantity);
}

/// Cart state lives on-device — no account needed to shop. Lines are kept
/// in memory for the session (as before) and also mirrored to
/// SharedPreferences on every change, so a shopper who closes the tab/app
/// mid-shop finds their cart exactly as they left it next time — see
/// [restore], called once after the product catalog loads.
class CartProvider extends ChangeNotifier {
  static const _prefsKey = 'aya_cart_v1';

  final Map<String, CartLine> _lines = {};

  List<CartLine> get lines => _lines.values.toList();

  int get itemCount => _lines.values.fold(0, (sum, l) => sum + l.quantity);

  double get subtotal => _lines.values.fold(0.0, (sum, l) => sum + l.lineTotal);

  double _shipping = SettingsRepository.defaultShippingCost;

  /// The flat shipping fee, set by the store admin from the dashboard.
  double get shipping => _shipping;

  double get total => _lines.isEmpty ? 0 : subtotal + shipping;

  /// Pulls the current shipping fee from Supabase. Call once on app start.
  Future<void> loadShipping() async {
    _shipping = await SettingsRepository.fetchShippingCost();
    notifyListeners();
  }

  /// Called right after the admin saves a new shipping fee, so the change
  /// applies immediately across the app without needing a reload.
  void applyShipping(double value) {
    _shipping = value;
    notifyListeners();
  }

  bool contains(String productId) => _lines.containsKey(productId);

  int quantityOf(String productId) => _lines[productId]?.quantity ?? 0;

  void add(Product product, {int quantity = 1}) {
    final existing = _lines[product.id];
    _lines[product.id] = CartLine(
      product: product,
      quantity: (existing?.quantity ?? 0) + quantity,
    );
    notifyListeners();
    _persist();
  }

  void setQuantity(String productId, int quantity) {
    final existing = _lines[productId];
    if (existing == null) return;
    if (quantity <= 0) {
      _lines.remove(productId);
    } else {
      _lines[productId] = existing.copyWith(quantity: quantity);
    }
    notifyListeners();
    _persist();
  }

  void remove(String productId) {
    _lines.remove(productId);
    notifyListeners();
    _persist();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
    _persist();
  }

  /// Fire-and-forget save of {productId, quantity} pairs — deliberately
  /// not awaited by the callers above so add/remove/setQuantity stay
  /// instant-feeling; a slow disk write here should never stall the UI.
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _lines.values.map((l) => {'id': l.product.id, 'qty': l.quantity}).toList();
      await prefs.setString(_prefsKey, jsonEncode(data));
    } catch (_) {
      // Best-effort only — losing the saved cart on a write failure isn't
      // worth surfacing to the shopper.
    }
  }

  /// Reloads any cart saved from a previous session, matched against the
  /// freshly-fetched catalog so a since-deleted product can't resurrect a
  /// line for it. Call once, right after the product list first loads
  /// (see MainShell.initState). A no-op if the cart already has items —
  /// e.g. this got called twice, or the shopper already added something
  /// before the catalog finished loading.
  Future<void> restore(List<Product> products) async {
    if (_lines.isNotEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final saved = jsonDecode(raw) as List;
      final byId = {for (final p in products) p.id: p};
      for (final entry in saved) {
        final map = entry as Map;
        final product = byId[map['id']];
        final qty = (map['qty'] as num?)?.toInt() ?? 0;
        if (product != null && qty > 0) {
          _lines[product.id] = CartLine(product: product, quantity: qty);
        }
      }
      if (_lines.isNotEmpty) notifyListeners();
    } catch (_) {
      // Corrupt or old-format data — start with an empty cart rather than
      // crash the app over it.
    }
  }
}

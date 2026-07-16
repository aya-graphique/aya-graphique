import 'package:flutter/foundation.dart';
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

/// Cart state lives on-device for the session — no account needed to shop.
/// (Wire this up to a Supabase `cart_items` table keyed by user id if you
/// want carts to persist across devices/logins.)
class CartProvider extends ChangeNotifier {
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
  }

  void remove(String productId) {
    _lines.remove(productId);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}

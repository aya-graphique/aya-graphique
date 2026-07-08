import 'package:flutter/foundation.dart';

/// Wishlist state lives on-device for the session, same as the cart.
class FavoritesProvider extends ChangeNotifier {
  final Set<String> _ids = {};

  Set<String> get ids => _ids;

  bool isFavorite(String productId) => _ids.contains(productId);

  void toggle(String productId) {
    if (_ids.contains(productId)) {
      _ids.remove(productId);
    } else {
      _ids.add(productId);
    }
    notifyListeners();
  }
}

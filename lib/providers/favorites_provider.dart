import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wishlist state lives on-device — no account needed. IDs are kept in
/// memory for the session (as before) and also mirrored to
/// SharedPreferences on every change, so a shopper who closes the tab/app
/// mid-browse finds their saved items exactly as they left them next time
/// — see [load], called once at app start (mirrors [CartProvider.restore]).
class FavoritesProvider extends ChangeNotifier {
  static const _prefsKey = 'aya_favorites_v1';

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
    _persist();
  }

  /// Fire-and-forget save of the saved-product IDs — deliberately not
  /// awaited by [toggle] so a tap on the heart stays instant-feeling; a
  /// slow disk write here should never stall the UI.
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, _ids.toList());
    } catch (_) {
      // Best-effort only — losing the saved wishlist on a write failure
      // isn't worth surfacing to the shopper.
    }
  }

  /// Reloads whatever was saved from a previous session. Call once, right
  /// after the app starts (see AyaGraphiqueApp). Doesn't need the product
  /// catalog like CartProvider.restore does — a since-deleted product's ID
  /// just quietly matches nothing in the favorites list/grid.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_prefsKey);
      if (saved != null && saved.isNotEmpty) {
        _ids.addAll(saved);
        notifyListeners();
      }
    } catch (_) {
      // Corrupt or old-format data — start with an empty wishlist rather
      // than crash the app over it.
    }
  }
}

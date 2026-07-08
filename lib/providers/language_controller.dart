import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The two languages the *storefront* (customer-facing side) can be
/// displayed in. This is completely separate from [FontController]'s
/// Arabic-font toggle — this one actually swaps the text, not just the
/// typeface.
///
/// IMPORTANT: this only affects the storefront (home, search, cart,
/// checkout, product detail). The admin dashboard is intentionally never
/// wrapped in this controller's `Directionality`/text lookups, so it
/// always stays in English regardless of what the shopper picks.
enum AppLanguage { en, ar }

class LanguageController extends ChangeNotifier {
  static const _prefsKey = 'aya_app_language';

  AppLanguage _language = AppLanguage.en;
  bool _loaded = false;

  LanguageController() {
    _restore();
  }

  AppLanguage get language => _language;
  bool get isArabic => _language == AppLanguage.ar;
  bool get isLoaded => _loaded;

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved == 'ar') _language = AppLanguage.ar;
      if (saved == 'en') _language = AppLanguage.en;
    } catch (_) {
      // No local storage available — just default to English for this
      // session.
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  /// Flips between Arabic and English. This is what the storefront logo
  /// tap calls — it never touches anything admin-related.
  Future<void> toggleLanguage() async {
    _language = isArabic ? AppLanguage.en : AppLanguage.ar;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, isArabic ? 'ar' : 'en');
    } catch (_) {
      // Preference just won't persist across restarts — not fatal.
    }
  }
}

extension LanguageContextX on BuildContext {
  AppLanguage get appLanguage => watch<LanguageController>().language;
  bool get isArabicLanguage => watch<LanguageController>().isArabic;
  LanguageController get languageController => read<LanguageController>();
}

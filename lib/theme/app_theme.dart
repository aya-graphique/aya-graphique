import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Aya's Graphique — design tokens.
/// Same monochrome-purple palette as the Aya's Graphique brand system:
/// deep aubergine background, mid violet, and an electric-orchid accent.
/// Dark, moody, gallery-like canvas so product photography pops — with a
/// bright, paper-like counterpart for people who prefer light mode.
class AppColors {
  final Color bgDeep;
  final Color bgPurple;
  final Color surface;
  final Color surfaceRaised;
  final Color ink;

  final Color violetDeep;
  final Color violetMid;
  final Color violetLight;
  final Color violetPop;
  final Color orchid;
  final Color orchidSoft;

  final Color cream;
  final Color creamDim;

  final Color success;
  final Color danger;

  final LinearGradient heroGradient;
  final LinearGradient violetGradient;
  final LinearGradient violetGradientWide;
  final LinearGradient cardGradient;

  const AppColors._({
    required this.bgDeep,
    required this.bgPurple,
    required this.surface,
    required this.surfaceRaised,
    required this.ink,
    required this.violetDeep,
    required this.violetMid,
    required this.violetLight,
    required this.violetPop,
    required this.orchid,
    required this.orchidSoft,
    required this.cream,
    required this.creamDim,
    required this.success,
    required this.danger,
    required this.heroGradient,
    required this.violetGradient,
    required this.violetGradientWide,
    required this.cardGradient,
  });

  /// True for the dark palette, where [cream] is a light hue used as a
  /// near-white hairline on dark surfaces. False for the light palette,
  /// where [cream] is a dark hue used for ink-colored borders/text.
  bool get isDark => cream.computeLuminance() > 0.5;

  /// Theme-aware border tone. In dark mode this stays a faint light
  /// hairline (as [opacity] suggests). In light mode the same low opacity
  /// would be nearly invisible against a white surface, so it's boosted
  /// to read as a clearly visible dark border instead.
  Color border(double opacity) {
    if (isDark) return cream.withOpacity(opacity);
    return cream.withOpacity((opacity * 3.2).clamp(0.0, 0.65));
  }

  /// The original moody dark palette.
  static const AppColors dark = AppColors._(
    bgDeep: Color(0xFF0D0512),
    bgPurple: Color(0xFF3A1750),
    surface: Color(0xFF1E0F2A),
    surfaceRaised: Color(0xFF2E1740),
    ink: Color(0xFF1A0B26),
    violetDeep: Color(0xFF2C1240),
    violetMid: Color(0xFF5C3578),
    violetLight: Color(0xFF8B6BAE),
    violetPop: Color(0xFF9B3FD1),
    orchid: Color(0xFFC183EE),
    orchidSoft: Color(0xFFE7D4F5),
    cream: Color(0xFFF6EFFB),
    creamDim: Color(0xFFC2AED4),
    success: Color(0xFF7FE3A6),
    danger: Color(0xFFE36F8B),
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0D0512),
        Color(0xFF1A0B26),
        Color(0xFF3A1750),
        Color(0xFF2E1740),
      ],
      stops: [0.0, 0.32, 0.68, 1.0],
    ),
    violetGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF2C1240), Color(0xFF9B3FD1), Color(0xFFC183EE)],
      stops: [0.0, 0.55, 1.0],
    ),
    violetGradientWide: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1A0B26),
        Color(0xFF2C1240),
        Color(0xFF5C3578),
        Color(0xFF9B3FD1),
        Color(0xFFC183EE),
      ],
      stops: [0.0, 0.3, 0.55, 0.8, 1.0],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF2E1740), Color(0xFF1E0F2A), Color(0xFF1A0B26)],
      stops: [0.0, 0.55, 1.0],
    ),
  );

  /// A bright, paper-like counterpart — same brand purples as accents,
  /// but on soft lavender-white surfaces with dark ink text.
  static const AppColors light = AppColors._(
    bgDeep: Color(0xFFffffff),
    bgPurple: Color(0xFFE9D9F4),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF0E1F9),
    ink: Color(0xFF1A0B26),
    violetDeep: Color(0xFF2C1240),
    violetMid: Color(0xFF5C3578),
    violetLight: Color(0xFF8B6BAE),
    violetPop: Color(0xFF9B3FD1),
    orchid: Color(0xFFC183EE),
    orchidSoft: Color(0xFF9B3FD1),
    cream: Color(0xFF241132),
    creamDim: Color(0xFF241132),
    success: Color(0xFF2E9A5C),
    danger: Color(0xFFC23F63),
    heroGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFBF8FD),
        Color(0xFFFFFFFF),
        Color(0xFFE9D9F4),
        Color(0xFFF0E1F9),
      ],
      stops: [0.0, 0.32, 0.68, 1.0],
    ),
    violetGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF2C1240), Color(0xFF9B3FD1), Color(0xFFC183EE)],
      stops: [0.0, 0.55, 1.0],
    ),
    violetGradientWide: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1A0B26),
        Color(0xFF2C1240),
        Color(0xFF5C3578),
        Color(0xFF9B3FD1),
        Color(0xFFC183EE),
      ],
      stops: [0.0, 0.3, 0.55, 0.8, 1.0],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF0E1F9), Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
      stops: [0.0, 0.55, 1.0],
    ),
  );
}

class AppFonts {
  AppFonts._();

  /// Matches any character in the main Arabic Unicode blocks (Arabic,
  /// Arabic Supplement, Arabic Extended-A, Arabic Presentation Forms).
  /// Used to auto-detect Arabic text (product names, descriptions,
  /// categories, etc. typed by the store owner) so it renders in a proper
  /// Arabic typeface instead of the Latin display font.
  static final RegExp _arabicPattern =
      RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]');

  /// Visitor-controlled override, flipped by [FontController]. When true,
  /// every AppFonts.* call below renders in the Arabic typeface regardless
  /// of what the text actually contains — lets a visitor opt into the
  /// Arabic look for the whole storefront from the nav bar switch, instead
  /// of relying purely on automatic per-string detection.
  static bool forceArabic = false;

  static bool isArabic(String text) => forceArabic || _arabicPattern.hasMatch(text);

  /// Small bump applied to Cairo (Arabic) text sizes only. Cairo reads a
  /// touch smaller than Poppins at the same fontSize, so this nudges
  /// Arabic copy up slightly to feel balanced — Latin text is untouched.
  static const double _arabicSizeBoost = 1.08;

  /// Headline/display face. Latin uses Poppins; Arabic uses Cairo (Bold+)
  /// — the closest free/open equivalent to the commercial "Bahij
  /// TheSansArabic" look: a warm, modern, geometric humanist sans that
  /// still reads as a confident headline face at large sizes.
  ///
  /// [boostArabicSize] lets a specific call opt out of the Arabic size
  /// bump (e.g. tags/pills that need to keep an exact size regardless of
  /// language).
  static TextStyle display({
    required Color color,
    double size = 64,
    FontWeight weight = FontWeight.w700,
    double? height,
    double? letterSpacing,
    String? text,
    bool boostArabicSize = true,
  }) {
    if (forceArabic || (text != null && isArabic(text))) {
      return GoogleFonts.cairo(
        fontSize: boostArabicSize ? size * _arabicSizeBoost : size,
        fontWeight: weight,
        color: color,
        height: height,
      );
    }
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing ?? -1.0,
    );
  }

  /// Body copy. Latin uses Poppins; Arabic uses Cairo Regular — clean and
  /// highly readable at small sizes.
  ///
  /// [boostArabicSize] lets a specific call opt out of the Arabic size
  /// bump (e.g. tags/pills that need to keep an exact size regardless of
  /// language).
  static TextStyle body({
    required Color color,
    double size = 16,
    FontWeight weight = FontWeight.w400,
    double? height,
    String? text,
    bool boostArabicSize = true,
  }) {
    if (forceArabic || (text != null && isArabic(text))) {
      return GoogleFonts.cairo(
        fontSize: boostArabicSize ? size * _arabicSizeBoost : size,
        fontWeight: weight,
        color: color,
        height: height ?? 1.7,
      );
    }
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height ?? 1.6,
    );
  }

  /// Small caps-style labels/eyebrows. Latin uses Poppins with wide
  /// tracking; Arabic uses Cairo SemiBold with lighter tracking, since wide
  /// letter spacing distorts connected Arabic letterforms.
  ///
  /// [boostArabicSize] lets a specific call opt out of the Arabic size
  /// bump (e.g. tags/pills that need to keep an exact size regardless of
  /// language).
  static TextStyle label({
    required Color color,
    double size = 13,
    FontWeight weight = FontWeight.w600,
    double letterSpacing = 3.0,
    String? text,
    bool boostArabicSize = true,
  }) {
    if (forceArabic || (text != null && isArabic(text))) {
      return GoogleFonts.cairo(
        fontSize: boostArabicSize ? size * _arabicSizeBoost : size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing * 0.15,
      );
    }
    return GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}

class AppBreakpoints {
  AppBreakpoints._();
  static const double mobile = 700;
  static const double tablet = 1050;
  static const double desktop = 1400;

  static bool isMobile(double w) => w < mobile;
  static bool isTablet(double w) => w >= mobile && w < tablet;
  static bool isDesktop(double w) => w >= tablet;
}

/// Holds the current light/dark preference, persists it, and notifies the
/// whole app so every screen re-reads its colors when the person flips the
/// switch.
class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'aya_theme_mode';

  ThemeMode _mode = ThemeMode.dark;
  bool _loaded = false;

  ThemeController() {
    _restore();
  }

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;
  AppColors get colors => _mode == ThemeMode.dark ? AppColors.dark : AppColors.light;

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved == 'light') _mode = ThemeMode.light;
      if (saved == 'dark') _mode = ThemeMode.dark;
    } catch (_) {
      // If local storage isn't available (e.g. some web/embedded contexts),
      // just fall back to the default dark mode for this session.
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, isDark ? 'dark' : 'light');
    } catch (_) {
      // Preference just won't persist across restarts — not fatal.
    }
  }

  bool get isLoaded => _loaded;
}

/// Lets any widget grab `context.colors` (reactive — rebuilds when the
/// theme changes) instead of importing and watching ThemeController by hand.
extension ThemeContextX on BuildContext {
  AppColors get colors => watch<ThemeController>().colors;
  ThemeController get themeController => read<ThemeController>();

  /// Same colors as `context.colors`, but non-reactive (`read`, not
  /// `watch`). Use this instead of `context.colors` inside callbacks that
  /// run *after* the widget tree finished building — e.g. an onTap/onPressed
  /// handler that shows a SnackBar or dialog. Calling `context.colors`
  /// (which watches) from outside a build method throws
  /// "Tried to listen to a value exposed with provider, from outside of the
  /// widget tree" — this getter is the fix for exactly that case.
  AppColors get colorsRead => themeController.colors;
}

/// Visitor-facing switch for the storefront's typography. Off (default)
/// means text renders in Arabic (Cairo) only where it actually contains
/// Arabic characters, and everything else stays Poppins. On means the
/// visitor has chosen to see the whole storefront in the Arabic typeface,
/// regardless of what any individual string contains — a manual override
/// on top of the automatic per-string detection.
class FontController extends ChangeNotifier {
  static const _prefsKey = 'aya_font_mode';

  bool _arabicMode = false;

  FontController() {
    _restore();
  }

  bool get arabicMode => _arabicMode;

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _arabicMode = prefs.getBool(_prefsKey) ?? false;
    } catch (_) {
      // No local storage available — just default to auto-detect only.
    } finally {
      AppFonts.forceArabic = _arabicMode;
      notifyListeners();
    }
  }

  Future<void> toggleArabicMode() async {
    _arabicMode = !_arabicMode;
    AppFonts.forceArabic = _arabicMode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, _arabicMode);
    } catch (_) {
      // Preference just won't persist across restarts — not fatal.
    }
  }
}

extension FontContextX on BuildContext {
  bool get isArabicFontMode => watch<FontController>().arabicMode;
  FontController get fontController => read<FontController>();
}

ThemeData buildAppTheme(AppColors colors, {required bool isDark}) {
  return ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: colors.bgDeep,
    fontFamily: GoogleFonts.poppins().fontFamily,
    colorScheme: isDark
        ? ColorScheme.dark(
            primary: colors.violetPop,
            secondary: colors.orchid,
            surface: colors.surface,
          )
        : ColorScheme.light(
            primary: colors.violetPop,
            secondary: colors.orchid,
            surface: colors.surface,
          ),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
  );
}

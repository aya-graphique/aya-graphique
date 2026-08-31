import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/language_controller.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/main_shell.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';
import 'utils/browser_tab_history.dart';

// Shared by every screen that pushes a real Navigator route on top of
// MainShell (product detail, checkout, admin screens, ...), so the
// browser-back handling in main_shell.dart can ask "is there a pushed
// screen on top right now?" and pop *that* first, instead of only ever
// knowing about MainShell's own tab switches. See rootNavigatorObserver
// below for the other half of this.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// Mirrors every real Navigator.push (product detail, checkout, admin
// sub-screens, ...) into the browser's session history, the same way
// MainShell's _goTo already does for tab switches (see
// browser_tab_history.dart). Without this, opening one of those screens
// doesn't add anything for a phone back-press/gesture to undo, so the
// very first back press falls straight through to the browser's real
// "leave the page" behaviour instead of closing the screen — which is
// what made back jump all the way to Home instead of the screen you came
// from.
class _BrowserHistorySyncObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // previousRoute is null for the very first (initial) route — that's
    // MainShell itself, which doesn't need an extra history entry.
    if (previousRoute != null) {
      pushTabHistoryEntry();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // There's no native Flutter splash screen anymore — the brand moment
  // (portrait badge, name, tagline, loading bar) lives entirely in
  // web/index.html's #pre_splash, which paints the instant the page loads,
  // long before Flutter's engine/JS has even downloaded. It stays on
  // screen until MainShell's own data is actually ready (see
  // notifyAppContentReady in main_shell.dart), so it's safe to just await
  // Supabase init here like a normal app instead of racing it against a
  // fixed on-screen timer.
  await SupabaseService.init();
  runApp(const AyaGraphiqueApp());
}

class AyaGraphiqueApp extends StatelessWidget {
  const AyaGraphiqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()..loadShipping()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()..load()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => FontController()),
        ChangeNotifierProvider(create: (_) => LanguageController()),
      ],
      child: Consumer2<ThemeController, FontController>(
        builder: (context, themeController, fontController, _) {
          return MaterialApp(
            navigatorKey: rootNavigatorKey,
            navigatorObservers: [_BrowserHistorySyncObserver()],
            title: "Aya's Graphique — Notebooks & Calendars",
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(AppColors.light, isDark: false),
            darkTheme: buildAppTheme(AppColors.dark, isDark: true),
            themeMode: themeController.mode,
            // Named routes so the browser URL matters: visiting your-site.com/#/admin
            // (Flutter web uses hash URLs by default) opens the admin login directly,
            // without going through the storefront first. Handy for a GitHub Pages
            // deploy where you want a bookmarkable admin link.
            initialRoute: '/',
            routes: {
              '/': (context) => const MainShell(),
              '/admin': (context) => const AdminLoginScreen(),
            },
            onUnknownRoute: (settings) => MaterialPageRoute(builder: (_) => const MainShell()),
          );
        },
      ),
    );
  }
}

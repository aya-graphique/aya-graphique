import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/language_controller.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/main_shell.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

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

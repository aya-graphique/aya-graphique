import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/language_controller.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Supabase init used to be awaited *before* runApp — that made the very
  // first frame wait on a network call, which is what made the app feel
  // slow to open. Now runApp fires immediately and SplashScreen kicks off
  // that same init itself, in the background, while showing the brand
  // moment — so the app opens instantly and still doesn't show the shop
  // until data is actually ready.
  runApp(const AyaGraphiqueApp());
}

class AyaGraphiqueApp extends StatelessWidget {
  const AyaGraphiqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()..loadShipping()),
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
              '/': (context) => const SplashScreen(),
              '/admin': (context) => const AdminLoginScreen(),
            },
            onUnknownRoute: (settings) => MaterialPageRoute(builder: (_) => const MainShell()),
          );
        },
      ),
    );
  }
}

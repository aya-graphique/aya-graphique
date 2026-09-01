import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/language_controller.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/product_link_screen.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // No splash screen: while the page/engine is loading, the browser just
  // shows a plain brand-colored background (set in web/index.html) instead
  // of a white flash or a dedicated splash widget. The app opens directly
  // into MainShell as soon as it's ready.
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
            // '/product/<id>' isn't a fixed route (the id varies per
            // product), so it can't live in the static `routes` map above —
            // it's handled here instead. This is what makes a shared
            // product link (see ProductCard._shareProduct) open straight to
            // that product instead of just the storefront root.
            onGenerateRoute: (settings) {
              final name = settings.name ?? '/';
              const prefix = '/product/';
              if (name.startsWith(prefix) && name.length > prefix.length) {
                final id = Uri.decodeComponent(name.substring(prefix.length));
                return MaterialPageRoute(builder: (_) => ProductLinkScreen(productId: id));
              }
              return null;
            },
            onUnknownRoute: (settings) => MaterialPageRoute(builder: (_) => const MainShell()),
          );
        },
      ),
    );
  }
}

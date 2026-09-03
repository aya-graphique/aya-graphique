import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // THE REAL FIX for "the browser's own back button only works once, then
  // goes dead": by default, a plain MaterialApp (Navigator 1.0 — no
  // MaterialApp.router) drives the web engine in *single-entry history*
  // mode. In that mode, every route change — no matter how many distinct
  // Navigator.push calls happen, and no matter how unique their
  // RouteSettings.name is (see uniqueRouteName / _TabMarkerRoute below) —
  // is reported to the browser with history.replaceState(), not
  // pushState(). That collapses the ENTIRE app's navigation into one
  // single browser history entry, which is why the physical back button
  // only ever has one real step to give you before it goes dead.
  // Confirmed by Flutter's own docs — only `Router`-based apps get "a
  // History API entry ... added to the browser's history stack" on every
  // navigation: https://docs.flutter.dev/ui/navigation#web-support.
  //
  // Calling SystemNavigator.selectMultiEntryHistory() switches that over
  // — BUT it has to happen here, scheduled for *after* the first frame,
  // not up above before runApp(). Flutter's own NavigatorState.initState()
  // unconditionally calls SystemNavigator.selectSingleEntryHistory() the
  // moment the app's root Navigator is created (this is what
  // MaterialApp's `reportsRouteUpdateToEngine: true` default does) — and
  // that initState runs *during* runApp(), i.e. strictly after any call
  // placed before it. A call made before runApp() was therefore being
  // silently overwritten a few milliseconds later by Flutter's own
  // startup code — no error, it just quietly reset back to single-entry
  // right after. Scheduling this in a post-frame callback guarantees it
  // runs once the root Navigator's initState (and its single-entry
  // request) has already happened, so this is the one that actually
  // sticks. From then on every reported route change genuinely pushes a
  // new browser history entry, and the back button can walk back through
  // as many of them as the person has actually visited.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    SystemNavigator.selectMultiEntryHistory();
  });
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

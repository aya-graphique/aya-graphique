import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'models/portfolio_project.dart';
import 'models/product.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/home_data_controller.dart';
import 'providers/language_controller.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_home_banners_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_orders_screen.dart';
import 'screens/admin/admin_product_form_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/main_shell.dart';
import 'screens/my_works_screen.dart';
import 'screens/product_link_screen.dart';
import 'screens/project_detail_screen.dart';
import 'services/auth_service.dart';
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

/// Every route in the app, as a real go_router location — this is what
/// replaces the old plain `MaterialApp` + hand-rolled
/// `_TabMarkerRoute`/`_navHistory`/`SystemNavigator.selectMultiEntryHistory()`
/// machinery in the previous version of this file. go_router's `Router`
/// integration reports every navigation to the browser as its own real
/// history entry on its own, so the browser/phone back button "just
/// works" by construction instead of needing that workaround at all.
///
/// URLs stay hash-based (`your-site.com/#/shop`, etc.) since
/// `usePathUrlStrategy()` is never called — same as before, and still the
/// right call for a static GitHub Pages-style deploy.
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    // The 8 main tabs. Each is a real, bookmarkable location, and
    // go_router's StatefulShellRoute keeps exactly one IndexedStack of
    // them under the hood — same "switching tabs preserves each tab's
    // scroll position/state" behaviour the old MainShell had, just owned
    // by go_router instead of a hand-built IndexedStack.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (context, state) => const HomeTabPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/shop', builder: (context, state) => const ShopTabPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/search', builder: (context, state) => const SearchTabPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/services', builder: (context, state) => const ServicesTabPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/who-am-i', builder: (context, state) => const AboutTabPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/my-works', builder: (context, state) => const MyWorksTabPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/favorites', builder: (context, state) => const FavoritesTabPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/cart', builder: (context, state) => const CartTabPage())],
        ),
      ],
    ),

    // Shared product links (see ProductCard._shareProduct) look like
    // `your-site.com/#/product/<id>`. In-app taps push this same route
    // with the Product already in hand via `extra`, so ProductRoutePage
    // only needs to fetch the catalog itself when opened cold (a shared
    // link, a bookmark, a page refresh).
    GoRoute(
      path: '/product/:id',
      builder: (context, state) => ProductRoutePage(
        productId: state.pathParameters['id']!,
        product: state.extra as Product?,
      ),
    ),

    // These three routes all take their data from the URL itself
    // (category name / project id / image index as path params) instead
    // of go_router's `extra`. `extra` only lives in memory, so it's gone
    // the moment one of these routes gets rebuilt from a bare URL rather
    // than a live in-app push — which happens on a page refresh, *and*
    // on a real browser/phone physical back-button step (as opposed to
    // the in-app back arrow, which just pops the in-memory route stack
    // and always has `extra` available). Deriving everything from the
    // URL means every one of these screens can always rebuild itself
    // correctly, so the phone's back button steps back one screen at a
    // time (lightbox -> project -> category -> my-works) instead of
    // hitting a "no extra" guard and bouncing straight to '/my-works'.
    GoRoute(
      path: '/my-works/category/:name',
      builder: (context, state) {
        final name = state.pathParameters['name'];
        final category = _findCategoryByName(name);
        if (category == null) return const _RedirectTo('/my-works');
        return CategoryProjectsScreen(category: category);
      },
    ),
    GoRoute(
      path: '/my-works/project/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        final isArabic = context.watch<LanguageController>().isArabic;
        final project = _findProjectById(kProjects(isArabic), id);
        if (project == null) return const _RedirectTo('/my-works');
        return ProjectDetailScreen(project: project);
      },
      routes: [
        GoRoute(
          path: 'lightbox/:index',
          // A real route (not a bare Navigator.push overlay) specifically
          // so it gets its own browser-history entry — see
          // ProjectDetailScreen._openLightbox for why that matters on
          // mobile, where the phone's back button skips straight past
          // anything that never got a history entry of its own.
          pageBuilder: (context, state) {
            final id = state.pathParameters['id'];
            final initialIndex = int.tryParse(state.pathParameters['index'] ?? '');
            final isArabic = context.watch<LanguageController>().isArabic;
            final project = _findProjectById(kProjects(isArabic), id);
            if (project == null || initialIndex == null || project.images.isEmpty) {
              return NoTransitionPage(child: const _RedirectTo('/my-works'));
            }
            return CustomTransitionPage(
              opaque: false,
              barrierColor: Colors.black.withOpacity(0.95),
              transitionDuration: const Duration(milliseconds: 220),
              child: ProjectImageLightbox(
                images: project.images,
                initialIndex: initialIndex.clamp(0, project.images.length - 1),
              ),
              transitionsBuilder: (context, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            );
          },
        ),
      ],
    ),

    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),

    // Reachable from the storefront footer's "Store admin" link, or
    // directly via a bookmarked '/admin' URL.
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin/dashboard',
      // Guards this whole branch (and its sub-routes below, since
      // go_router evaluates a parent route's redirect for any location
      // that matches one of its children too): dashboard pages are only
      // ever meant to be reached via a successful sign-in on
      // AdminLoginScreen, never by guessing/bookmarking the URL directly.
      redirect: (context, state) => AuthService.isSignedIn ? null : '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
      routes: [
        GoRoute(
          path: 'orders',
          builder: (context, state) => const AdminOrdersScreen(),
        ),
        GoRoute(
          path: 'banners',
          builder: (context, state) => const AdminHomeBannersScreen(),
        ),
        GoRoute(
          path: 'product-form',
          builder: (context, state) => AdminProductFormScreen(existing: state.extra as Product?),
        ),
      ],
    ),
  ],
  // Anything that doesn't match (a stale/bad link, a typo) quietly sends
  // the visitor back to the storefront root instead of showing an error
  // page — same behaviour as the old `onUnknownRoute`.
  errorBuilder: (context, state) => const _RedirectTo('/'),
);

/// Looks up a [ProjectCategory] by its enum `.name` (used as the
/// `/my-works/category/:name` path segment). Returns null for a
/// missing/mistyped/stale name instead of throwing.
ProjectCategory? _findCategoryByName(String? name) {
  for (final category in ProjectCategory.values) {
    if (category.name == name) return category;
  }
  return null;
}

/// Looks up a [PortfolioProject] by its stable [PortfolioProject.id]
/// (used as the `/my-works/project/:id` path segment). Returns null for
/// a missing/mistyped/stale id instead of throwing.
PortfolioProject? _findProjectById(List<PortfolioProject> projects, String? id) {
  for (final project in projects) {
    if (project.id == id) return project;
  }
  return null;
}

/// Renders nothing and immediately navigates to [path] — used wherever a
/// route can't show what it's meant to (missing `extra`, no match, etc.)
/// so the visitor gets quietly bounced somewhere sensible instead of
/// seeing a crash.
class _RedirectTo extends StatefulWidget {
  final String path;
  const _RedirectTo(this.path);

  @override
  State<_RedirectTo> createState() => _RedirectToState();
}

class _RedirectToState extends State<_RedirectTo> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(widget.path);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
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
        // Starts fetching the catalog/banners immediately (lazy: false),
        // same timing as before when this lived inside MainShell's
        // initState — but scoped at the app level now since go_router's
        // per-tab routes no longer share one parent widget the way a
        // single IndexedStack-holding MainShell used to.
        ChangeNotifierProvider(create: (_) => HomeDataController(), lazy: false),
      ],
      child: Consumer2<ThemeController, FontController>(
        builder: (context, themeController, fontController, _) {
          return MaterialApp.router(
            title: "Aya's Graphique — Notebooks & Calendars",
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(AppColors.light, isDark: false),
            darkTheme: buildAppTheme(AppColors.dark, isDark: true),
            themeMode: themeController.mode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/home_data_controller.dart';
import '../providers/language_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_backdrop.dart';
import '../widgets/shop_nav_bar.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'graphical_services_screen.dart';
import 'home_screen.dart';
import 'my_works_screen.dart';
import 'search_screen.dart';
import 'shop_screen.dart';
import 'who_am_i_screen.dart';

/// Cross-tab remote controls + shared data, handed down to every branch
/// page inside [MainShell] via [Provider].
///
/// Before the go_router migration, MainShell built every tab's screen
/// itself (inside one big IndexedStack) and simply passed all of this as
/// constructor params. Now that go_router's `StatefulShellRoute` owns
/// that IndexedStack — each tab is its own route/Navigator, built by its
/// own tiny page widget below — the tab pages are no longer direct
/// children of `_MainShellState` in the widget tree, so they reach back
/// up for this instead.
class ShellControls {
  final List<Product> products;
  final ServicesFocusController servicesFocusController;
  final ShopFocusController shopFocusController;
  final ScrollController homeScrollController;
  final ScrollController shopScrollController;
  final void Function(ShopPage page) goTo;
  final VoidCallback refreshProducts;

  ShellControls({
    required this.products,
    required this.servicesFocusController,
    required this.shopFocusController,
    required this.homeScrollController,
    required this.shopScrollController,
    required this.goTo,
    required this.refreshProducts,
  });

  // Called from Home's service circles: switch to the Services tab and
  // have it scroll straight to (and expand) the tapped category.
  void openServiceCategory(int index) {
    goTo(ShopPage.services);
    servicesFocusController.focusCategory(index);
  }

  // Called from Home's product category circles: switch to the Shop tab
  // with that category already selected.
  void openShopCategory(String category) {
    goTo(ShopPage.shop);
    shopFocusController.focusCategory(category);
  }
}

/// The storefront's persistent chrome — the frosted nav bar/drawer and
/// backdrop — wrapped around whichever tab [navigationShell] currently
/// has active. This is the `builder` widget for a
/// `StatefulShellRoute.indexedStack` (see main.dart): go_router itself
/// now owns the IndexedStack of tabs (one real Navigator + browser
/// history entry per tab), so this widget's only job is the chrome plus
/// the handful of pieces of state/controllers the tabs need to talk to
/// each other (see [ShellControls]) — it no longer builds any tab's
/// screen directly.
class MainShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Only used on mobile, to open ShopNavDrawer from the compact top bar's
  // menu button — desktop never touches this since it keeps the full pill
  // nav instead of a drawer.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _homeScrollController = ScrollController();
  final ScrollController _shopScrollController = ScrollController();
  // Lets Home's "service circles" row jump straight to a specific
  // category on the standalone Services tab.
  final ServicesFocusController _servicesFocusController = ServicesFocusController();
  // Lets Home's product category circles jump straight to a specific
  // category on the standalone Shop tab.
  final ShopFocusController _shopFocusController = ShopFocusController();

  @override
  void initState() {
    super.initState();
    // Reload whatever was in the cart last time this shopper was here,
    // once we actually have the catalog to match those saved lines
    // against (see CartProvider.restore). HomeDataController starts this
    // fetch the moment it's created (see AyaGraphiqueApp), so this just
    // waits on it.
    context.read<HomeDataController>().productsFuture.then((products) {
      if (!mounted) return;
      context.read<CartProvider>().restore(products);
    });
  }

  @override
  void dispose() {
    _homeScrollController.dispose();
    _shopScrollController.dispose();
    _servicesFocusController.dispose();
    _shopFocusController.dispose();
    super.dispose();
  }

  void _goTo(ShopPage page) {
    // Each tab is a real go_router branch/location now — switching tabs
    // is genuine navigation (StatefulNavigationShell.goBranch), and
    // go_router reports every one of these to the browser as its own
    // history entry on its own. That's exactly what the old
    // _TabMarkerRoute/_navHistory hand-rolled machinery existed to fake
    // for a plain Navigator 1.0 app, so none of that is needed anymore.
    widget.navigationShell.goBranch(
      page.index,
      initialLocation: page.index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = AppBreakpoints.isMobile(width);
    // Only the storefront (this shell, plus product detail & checkout,
    // which wrap themselves the same way) follows the language toggle.
    // The admin dashboard is reached through its own routes and never
    // reads LanguageController, so it always stays LTR/English.
    final textDirection = context.watch<LanguageController>().textDirection;
    // AppFonts.forceArabic is a global static flag (several storefront
    // widgets rely on it instead of threading a `text:` argument through).
    // Each admin screen forces it back to false on its own build, so
    // resync it here to the shopper's real preference every time the
    // storefront rebuilds — otherwise a visit to /admin could leave the
    // storefront stuck showing the Latin font after a shopper picked
    // Arabic.
    AppFonts.forceArabic = context.watch<FontController>().arabicMode;
    final page = ShopPage.values[widget.navigationShell.currentIndex];
    final data = context.watch<HomeDataController>();

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: context.colors.bgDeep,
        // The drawer only exists on mobile — desktop keeps the full pill
        // nav bar floating over the content instead, so there's nothing
        // for a drawer to open there.
        drawer: isMobile ? ShopNavDrawer(active: page, onTap: _goTo) : null,
        body: AnimatedBackdrop(
          child: FutureBuilder<List<Product>>(
            future: data.productsFuture,
            builder: (context, snapshot) {
              final products = snapshot.data ?? const [];
              final loading = snapshot.connectionState == ConnectionState.waiting;
              final controls = ShellControls(
                products: products,
                servicesFocusController: _servicesFocusController,
                shopFocusController: _shopFocusController,
                homeScrollController: _homeScrollController,
                shopScrollController: _shopScrollController,
                goTo: _goTo,
                refreshProducts: data.refresh,
              );

              return Stack(
                children: [
                  if (loading)
                    Center(
                      child: CircularProgressIndicator(color: context.colors.orchid),
                    )
                  else
                    Provider<ShellControls>.value(
                      value: controls,
                      child: widget.navigationShell,
                    ),
                  Positioned(
                    top: 20,
                    left: isMobile ? 10 : 0,
                    right: isMobile ? 10 : 0,
                    child: Center(
                      // Mobile swaps the full pill nav for the compact top
                      // bar (menu button + logo + cart) that opens
                      // ShopNavDrawer; desktop is unchanged.
                      child: isMobile
                          ? ShopMobileTopBar(
                              active: page,
                              onTap: _goTo,
                              onMenuTap: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                            )
                          : ShopNavBar(
                              active: page,
                              onTap: _goTo,
                              isMobile: isMobile,
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Below: one tiny page widget per tab/branch (see main.dart's
/// `StatefulShellRoute.indexedStack`). Each just resolves [ShellControls]
/// (and, for Home, [HomeDataController] directly for its banner futures)
/// and builds the real screen — the screens' own widget APIs are
/// unchanged from before this migration.
class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);
    final controls = context.watch<ShellControls>();
    final data = context.watch<HomeDataController>();
    return HomeScreen(
      products: controls.products,
      isMobile: isMobile,
      scrollController: controls.homeScrollController,
      onAdminReturn: controls.refreshProducts,
      bannersFuture: data.bannersFuture,
      mostOrderedBannersFuture: data.mostOrderedBannersFuture,
      onServiceCategoryTap: controls.openServiceCategory,
      onShopTap: () => controls.goTo(ShopPage.shop),
      onCategoryTap: controls.openShopCategory,
      onViewProfileTap: () => controls.goTo(ShopPage.myWorks),
    );
  }
}

class ShopTabPage extends StatelessWidget {
  const ShopTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);
    final controls = context.watch<ShellControls>();
    return ShopScreen(
      products: controls.products,
      isMobile: isMobile,
      scrollController: controls.shopScrollController,
      focusController: controls.shopFocusController,
    );
  }
}

class SearchTabPage extends StatelessWidget {
  const SearchTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);
    final controls = context.watch<ShellControls>();
    return SearchScreen(products: controls.products, isMobile: isMobile);
  }
}

class ServicesTabPage extends StatelessWidget {
  const ServicesTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);
    final controls = context.watch<ShellControls>();
    return GraphicalServicesScreen(
      isMobile: isMobile,
      focusController: controls.servicesFocusController,
    );
  }
}

class AboutTabPage extends StatelessWidget {
  const AboutTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);
    return WhoAmIScreen(isMobile: isMobile);
  }
}

class MyWorksTabPage extends StatelessWidget {
  const MyWorksTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);
    return MyWorksScreen(isMobile: isMobile);
  }
}

class FavoritesTabPage extends StatelessWidget {
  const FavoritesTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);
    final controls = context.watch<ShellControls>();
    return FavoritesScreen(
      products: controls.products,
      isMobile: isMobile,
      onBrowse: () => controls.goTo(ShopPage.shop),
    );
  }
}

class CartTabPage extends StatelessWidget {
  const CartTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = AppBreakpoints.isMobile(MediaQuery.of(context).size.width);
    final controls = context.watch<ShellControls>();
    return CartScreen(
      isMobile: isMobile,
      onBrowse: () => controls.goTo(ShopPage.shop),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/home_banner.dart';
import '../models/product.dart';
import '../providers/language_controller.dart';
import '../services/home_banners_repository.dart';
import '../services/products_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_backdrop.dart';
import '../widgets/shop_nav_bar.dart';
import 'cart_screen.dart';
import 'graphical_services_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'shop_screen.dart';
import 'who_am_i_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Home is the site's landing page — sliders, category/service teasers,
  // and the owner intro, all in one scroll. The shop grid itself now
  // lives on its own standalone Shop tab (see ShopScreen).
  ShopPage _page = ShopPage.home;
  // Only used on mobile, to open ShopNavDrawer from the compact top bar's
  // menu button — desktop never touches this since it keeps the full pill
  // nav instead of a drawer.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _homeScrollController = ScrollController();
  final ScrollController _shopScrollController = ScrollController();
  // Lets Home's "service circles" row jump straight to a specific
  // category on the standalone Services tab (see _openServiceCategory
  // below and ServicesFocusController in graphical_services_screen.dart).
  final ServicesFocusController _servicesFocusController = ServicesFocusController();
  // Lets Home's product category circles jump straight to a specific
  // category on the standalone Shop tab (see _openShopCategory below and
  // ShopFocusController in shop_screen.dart).
  final ShopFocusController _shopFocusController = ShopFocusController();
  late Future<List<Product>> _productsFuture;
  // Kicked off here, at the same time as _productsFuture, instead of
  // inside HomeScreen's own initState — previously the banner fetch only
  // *started* once HomeScreen mounted, which was itself gated behind
  // _productsFuture resolving, so it was two network round-trips back to
  // back (products, then banners) instead of one. Starting both together
  // here is what actually fixes the banner slideshow feeling slow to
  // appear; HomeScreen now just awaits whatever's passed in.
  late Future<List<HomeBanner>> _bannersFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductsRepository.fetchAll();
    _bannersFuture = HomeBannersRepository.fetchSlides();
  }

  @override
  void dispose() {
    _homeScrollController.dispose();
    _shopScrollController.dispose();
    _servicesFocusController.dispose();
    _shopFocusController.dispose();
    super.dispose();
  }

  void _goTo(ShopPage page) => setState(() => _page = page);

  // Called from Home's service circles: switch to the Services tab and
  // have it scroll straight to (and expand) the tapped category.
  void _openServiceCategory(int index) {
    _goTo(ShopPage.services);
    _servicesFocusController.focusCategory(index);
  }

  // Called from Home's product category circles: switch to the Shop tab
  // with that category already selected.
  void _openShopCategory(String category) {
    _goTo(ShopPage.shop);
    _shopFocusController.focusCategory(category);
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = ProductsRepository.fetchAll();
      _bannersFuture = HomeBannersRepository.fetchSlides();
    });
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

    return PopScope(
      // Tab switches inside this shell (_goTo) are plain setState calls,
      // not Navigator pushes, so they never land on the back stack. Without
      // this, pressing back on any tab other than Home closes the app (or
      // leaves the site, on web) instead of returning to Home like a user
      // would expect. canPop is only true once we're already on Home, so
      // that back press behaves normally (exits the app / leaves the page).
      canPop: _page == ShopPage.home,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _goTo(ShopPage.home);
      },
      child: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: context.colors.bgDeep,
          // The drawer only exists on mobile — desktop keeps the full pill
          // nav bar floating over the content instead, so there's nothing
          // for a drawer to open there.
          drawer: isMobile ? ShopNavDrawer(active: _page, onTap: _goTo) : null,
          body: AnimatedBackdrop(
          child: FutureBuilder<List<Product>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              final products = snapshot.data ?? const [];
              final loading = snapshot.connectionState == ConnectionState.waiting;

              return Stack(
                children: [
                  if (loading)
                    Center(
                      child: CircularProgressIndicator(color: context.colors.orchid),
                    )
                  else
                    IndexedStack(
                      index: _page.index,
                      children: [
                        HomeScreen(
                          products: products,
                          isMobile: isMobile,
                          scrollController: _homeScrollController,
                          onAdminReturn: _refreshProducts,
                          bannersFuture: _bannersFuture,
                          onServiceCategoryTap: _openServiceCategory,
                          onShopTap: () => _goTo(ShopPage.shop),
                          onCategoryTap: _openShopCategory,
                          onViewProfileTap: () => _goTo(ShopPage.about),
                        ),
                        ShopScreen(
                          products: products,
                          isMobile: isMobile,
                          scrollController: _shopScrollController,
                          focusController: _shopFocusController,
                        ),
                        SearchScreen(products: products, isMobile: isMobile),
                        GraphicalServicesScreen(
                          isMobile: isMobile,
                          focusController: _servicesFocusController,
                        ),
                        // Standalone "Who am I" tab — Home no longer
                        // embeds this inline; the owner-intro card's
                        // "View full profile" button jumps here instead
                        // (see HomeScreen.onViewProfileTap).
                        WhoAmIScreen(isMobile: isMobile),
                        CartScreen(isMobile: isMobile, onBrowse: () => _goTo(ShopPage.shop)),
                      ],
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
                              active: _page,
                              onTap: _goTo,
                              onMenuTap: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                            )
                          : ShopNavBar(
                              active: _page,
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
      ),
    );
  }
}

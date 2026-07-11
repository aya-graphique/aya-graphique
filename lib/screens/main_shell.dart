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
import 'who_am_i_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Home is the site's main page now — it's the one that carries the
  // sliders, Services, Shop, and Who am I sections all in one scroll, so
  // it's what visitors should land on first (see HomeScreen).
  ShopPage _page = ShopPage.home;
  // Only used on mobile, to open ShopNavDrawer from the compact top bar's
  // menu button — desktop never touches this since it keeps the full pill
  // nav instead of a drawer.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _homeScrollController = ScrollController();
  // Lets Home's "service circles" row jump straight to a specific
  // category on the standalone Services tab (see _openServiceCategory
  // below and ServicesFocusController in graphical_services_screen.dart).
  final ServicesFocusController _servicesFocusController = ServicesFocusController();
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
    _servicesFocusController.dispose();
    super.dispose();
  }

  void _goTo(ShopPage page) => setState(() => _page = page);

  // Called from Home's service circles: switch to the Services tab and
  // have it scroll straight to (and expand) the tapped category.
  void _openServiceCategory(int index) {
    _goTo(ShopPage.services);
    _servicesFocusController.focusCategory(index);
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

    return Directionality(
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
                        ),
                        SearchScreen(products: products, isMobile: isMobile),
                        GraphicalServicesScreen(
                          isMobile: isMobile,
                          focusController: _servicesFocusController,
                        ),
                        // Standalone "Who am I" tab — same WhoAmIScreen
                        // HomeScreen already embeds inline after the shop
                        // grid, just not embedded here so it gets its own
                        // scroll + top offset like every other tab.
                        WhoAmIScreen(isMobile: isMobile),
                        CartScreen(isMobile: isMobile, onBrowse: () => _goTo(ShopPage.home)),
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
    );
  }
}

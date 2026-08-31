import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/home_banner.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/language_controller.dart';
import '../services/home_banners_repository.dart';
import '../services/products_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_backdrop.dart';
import '../widgets/shop_nav_bar.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'graphical_services_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'shop_screen.dart';
import 'who_am_i_screen.dart';

// A Navigator route that exists purely so a physical/browser back press
// has a real, genuine route entry of ours to pop for each tab switch —
// it never shows anything and never blocks a single tap.
//
// Note this is NOT the same as just passing barrierColor: null to a
// plain PageRouteBuilder: every ModalRoute (which PageRouteBuilder is)
// installs an invisible full-screen "modal barrier" whose entire job is
// to swallow taps aimed at whatever's behind it — that's how a dialog
// stops you from tapping the screen behind it. barrierColor only
// controls whether that barrier is painted; it still intercepts every
// tap even when null. Left as the default, that barrier is what made
// the site "freeze" after switching tabs once — the very next tap on
// any icon was being silently absorbed by this marker route's barrier
// instead of reaching the real nav bar underneath. Overriding
// buildModalBarrier() to render nothing means there's genuinely nothing
// left on top of the real UI, so taps pass straight through.
class _TabMarkerRoute extends PageRouteBuilder<void> {
  _TabMarkerRoute()
      : super(
          opaque: false,
          maintainState: false,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => const SizedBox.shrink(),
        );

  @override
  Widget buildModalBarrier() => const SizedBox.shrink();
}

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
  // Tracks the tabs visited before the current one, most recent last, so
  // the physical/browser back button can retrace the user's actual path
  // (Shop -> Cart -> back goes to Shop) instead of always jumping to
  // Home or leaving the site. Each entry here has a matching invisible
  // route pushed onto the Navigator (see _goTo) — that's what actually
  // gives a browser back press / phone back gesture something of ours to
  // pop, riding the exact same Navigator-push mechanism that already
  // reliably handles back for ProductDetailScreen and CheckoutScreen on
  // both mobile and desktop, instead of the hand-rolled dart:html
  // history.pushState/popstate listener this used to use (which behaved
  // inconsistently between mobile and desktop browsers). Popped one at a
  // time in the push's .then callback below; empty means Home is the
  // only stop so far, so with no marker route left to pop, the next back
  // press correctly falls through to normal browser behaviour (leave the
  // page).
  final List<ShopPage> _navHistory = [];
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
  // Same idea as _bannersFuture, but for the second banner strip further
  // down Home, right above "MOST ORDERED" — its own owner-managed set of
  // photos (see HomeBannerPlacement.mostOrdered), fetched alongside the
  // others so it's ready by the time that part of Home scrolls into view.
  late Future<List<HomeBanner>> _mostOrderedBannersFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductsRepository.fetchAll();
    // Reload whatever was in the cart last time this shopper was here,
    // once we actually have the catalog to match those saved lines
    // against (see CartProvider.restore).
    _productsFuture.then((products) {
      if (!mounted) return;
      context.read<CartProvider>().restore(products);
    });
    _bannersFuture = HomeBannersRepository.fetchSlides();
    _mostOrderedBannersFuture =
        HomeBannersRepository.fetchSlides(placement: HomeBannerPlacement.mostOrdered);
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
    if (page == _page) return;
    final previous = _page;
    setState(() {
      _navHistory.add(previous);
      _page = page;
    });
    // Push a zero-size, fully transparent route so a physical/browser
    // back press has a real Navigator entry of ours to pop before it
    // reaches anything else. This is the same push mechanism already
    // used for ProductDetailScreen/CheckoutScreen — letting Flutter's own
    // Navigator/Router own the browser history entry is what makes back
    // behave consistently across both mobile and desktop browsers.
    // Nothing ever pops this programmatically; it only comes off the
    // stack when the user actually goes back, which is exactly when we
    // want to retrace one tab.
    Navigator.of(context).push(_TabMarkerRoute()).then((_) {
      if (!mounted || _navHistory.isEmpty) return;
      setState(() => _page = _navHistory.removeLast());
    });
  }

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
      _mostOrderedBannersFuture =
          HomeBannersRepository.fetchSlides(placement: HomeBannerPlacement.mostOrdered);
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

    // No PopScope needed here anymore: every tab switch now pushes a real
    // (invisible) Navigator route in _goTo, so the browser back button /
    // phone back gesture already has a genuine route of ours to pop —
    // handled by Flutter's own Navigator, the same well-tested path that
    // already makes back work correctly for ProductDetailScreen and
    // CheckoutScreen. When _navHistory is empty there's no marker route
    // left, so a back press correctly falls through to leaving the page.
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
                          mostOrderedBannersFuture: _mostOrderedBannersFuture,
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
                        // ShopPage.favorites — must sit at this exact
                        // position (index 5) to line up with the enum
                        // order in shop_nav_bar.dart. This was previously
                        // missing entirely, which made IndexedStack throw
                        // an out-of-range assertion (and freeze the whole
                        // app) the moment anyone tapped the Favorites icon
                        // or landed on Cart, since every page after it
                        // was silently shifted one index short.
                        FavoritesScreen(
                          products: products,
                          isMobile: isMobile,
                          onBrowse: () => _goTo(ShopPage.shop),
                        ),
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
    );
  }
}

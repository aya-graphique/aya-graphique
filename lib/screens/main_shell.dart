import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/language_controller.dart';
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
  ShopPage _page = ShopPage.about;
  final ScrollController _homeScrollController = ScrollController();
  final ScrollController _aboutScrollController = ScrollController();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductsRepository.fetchAll();
  }

  @override
  void dispose() {
    _homeScrollController.dispose();
    _aboutScrollController.dispose();
    super.dispose();
  }

  void _goTo(ShopPage page) => setState(() => _page = page);

  void _refreshProducts() {
    setState(() {
      _productsFuture = ProductsRepository.fetchAll();
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
        backgroundColor: context.colors.bgDeep,
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
                        ),
                        SearchScreen(products: products, isMobile: isMobile),
                        GraphicalServicesScreen(isMobile: isMobile),
                        CartScreen(isMobile: isMobile, onBrowse: () => _goTo(ShopPage.home)),
                        WhoAmIScreen(
                          isMobile: isMobile,
                          scrollController: _aboutScrollController,
                        ),
                      ],
                    ),
                  Positioned(
                    top: 20,
                    left: isMobile ? 10 : 0,
                    right: isMobile ? 10 : 0,
                    child: Center(
                      child: ShopNavBar(active: _page, onTap: _goTo, isMobile: isMobile),
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

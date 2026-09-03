import 'package:flutter/foundation.dart';
import '../models/home_banner.dart';
import '../models/product.dart';
import '../services/home_banners_repository.dart';
import '../services/products_repository.dart';

/// Holds the storefront's shared catalog + banner futures for the whole
/// app lifetime.
///
/// Before the go_router migration, these three futures lived as private
/// fields directly on `_MainShellState`, which got away with it because
/// that one State object built every tab's screen itself inside a single
/// IndexedStack. Now that go_router's `StatefulShellRoute` owns that
/// IndexedStack — one real Navigator/route per tab — no single State
/// object sits directly above all the tab screens as their common parent
/// anymore, so this data has to live somewhere all of them can reach
/// regardless of which tab (or which top-level route, like the admin
/// dashboard returning to the storefront) is currently active. A
/// `ChangeNotifierProvider` above the router, right alongside
/// CartProvider/FavoritesProvider, is that place.
class HomeDataController extends ChangeNotifier {
  Future<List<Product>> productsFuture = ProductsRepository.fetchAll();
  Future<List<HomeBanner>> bannersFuture = HomeBannersRepository.fetchSlides();
  Future<List<HomeBanner>> mostOrderedBannersFuture =
      HomeBannersRepository.fetchSlides(placement: HomeBannerPlacement.mostOrdered);

  /// Re-fetches everything — called after anything in the admin dashboard
  /// changes the catalog/banners, so the storefront reflects it the next
  /// time it's shown (see MainShell / AdminLoginScreen's return trip).
  void refresh() {
    productsFuture = ProductsRepository.fetchAll();
    bannersFuture = HomeBannersRepository.fetchSlides();
    mostOrderedBannersFuture =
        HomeBannersRepository.fetchSlides(placement: HomeBannerPlacement.mostOrdered);
    notifyListeners();
  }
}

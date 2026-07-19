import 'home_banner.dart';
import 'illustration_art_item.dart';
import 'product.dart';

/// Everything the Home page (plus the product list the Shop/Search tabs
/// reuse) needs on first load, bundled into one object — see
/// `HomeBootstrapRepository.fetch()`, which fills this from a single
/// Supabase round trip instead of six separate queries.
class HomeBootstrap {
  final List<Product> products;
  final List<HomeBanner> heroBanners;
  final List<HomeBanner> mostOrderedBanners;
  // Owner-set thumbnails for the 3 fixed service circles (Mentoring /
  // Designing / Private Workshop), keyed by their index in
  // kServiceCategories — same shape ServiceCategoriesRepository.fetchImages()
  // used to return on its own.
  final Map<int, String> serviceCategoryImages;
  final List<IllustrationArtItem> illustrationArtItems;

  const HomeBootstrap({
    required this.products,
    required this.heroBanners,
    required this.mostOrderedBanners,
    required this.serviceCategoryImages,
    required this.illustrationArtItems,
  });

  static const empty = HomeBootstrap(
    products: [],
    heroBanners: [],
    mostOrderedBanners: [],
    serviceCategoryImages: {},
    illustrationArtItems: [],
  );
}

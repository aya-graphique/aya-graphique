import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/home_banner.dart';
import '../models/home_bootstrap.dart';
import '../models/illustration_art_item.dart';
import '../models/product.dart';
import 'home_banners_repository.dart';
import 'illustration_art_repository.dart';
import 'products_repository.dart';
import 'service_categories_repository.dart';
import 'supabase_service.dart';

/// Fetches everything Home needs — the product list, both banner strips,
/// service category images, and illustration & art — in a single request
/// via the `get_home_bootstrap` Postgres function (see supabase/schema.sql),
/// instead of the 6 separate queries that used to fire every time Home
/// opened.
class HomeBootstrapRepository {
  static Future<HomeBootstrap> fetch() async {
    if (!SupabaseConfig.isConfigured) return HomeBootstrap.empty;
    try {
      final data = await SupabaseService.client.rpc('get_home_bootstrap');
      final map = data as Map<String, dynamic>;
      return HomeBootstrap(
        products: ((map['products'] as List?) ?? const [])
            .map((row) => Product.fromMap(row as Map<String, dynamic>))
            .toList(),
        heroBanners: ((map['hero_banners'] as List?) ?? const [])
            .map((row) => HomeBanner.fromRow(row as Map<String, dynamic>))
            .toList(),
        mostOrderedBanners: ((map['most_ordered_banners'] as List?) ?? const [])
            .map((row) => HomeBanner.fromRow(row as Map<String, dynamic>))
            .toList(),
        serviceCategoryImages: {
          for (final row in ((map['service_category_images'] as List?) ?? const []))
            if (((row as Map<String, dynamic>)['image_url'] as String? ?? '').isNotEmpty)
              row['category_index'] as int: row['image_url'] as String,
        },
        illustrationArtItems: ((map['illustration_art_items'] as List?) ?? const [])
            .map((row) => IllustrationArtItem.fromRow(row as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      // Most likely an existing project that hasn't re-run schema.sql yet,
      // so the get_home_bootstrap() function doesn't exist there. Fall
      // back to the old per-table calls (in parallel, not sequentially)
      // rather than showing an empty Home page.
      debugPrint(
        "Aya's Graphique: get_home_bootstrap RPC failed (has schema.sql been "
        "re-run since this update?), falling back to separate queries. Real "
        "error was:\n$e",
      );
      return _fetchSeparately();
    }
  }

  static Future<HomeBootstrap> _fetchSeparately() async {
    final results = await Future.wait([
      ProductsRepository.fetchAll(),
      HomeBannersRepository.fetchSlides(),
      HomeBannersRepository.fetchSlides(placement: HomeBannerPlacement.mostOrdered),
      ServiceCategoriesRepository.fetchImages(),
      IllustrationArtRepository.fetchAll(),
    ]);
    return HomeBootstrap(
      products: results[0] as List<Product>,
      heroBanners: results[1] as List<HomeBanner>,
      mostOrderedBanners: results[2] as List<HomeBanner>,
      serviceCategoryImages: results[3] as Map<int, String>,
      illustrationArtItems: results[4] as List<IllustrationArtItem>,
    );
  }
}

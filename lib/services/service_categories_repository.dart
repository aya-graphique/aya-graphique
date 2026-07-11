import '../config/supabase_config.dart';
import 'supabase_service.dart';

/// Owner-set thumbnail images for the three fixed service categories
/// (Mentoring / Designing / Private Workshop) shown on the storefront's
/// Home page category-circles row, keyed by each category's fixed index
/// in `kServiceCategories` (see graphical_services_screen.dart). Mirrors
/// [CategoriesRepository]'s image handling for the shop's own category
/// circles, just for a fixed set of 3 rows instead of an open-ended list.
class ServiceCategoriesRepository {
  /// All saved thumbnails, keyed by category index. A category with no
  /// entry here (or a blank image_url) just falls back to its icon — see
  /// HomeScreen's `_CategoryCircles`.
  static Future<Map<int, String>> fetchImages() async {
    if (!SupabaseConfig.isConfigured) return {};
    try {
      final data = await SupabaseService.client.from('service_category_images').select();
      final rows = (data as List).cast<Map<String, dynamic>>();
      return {
        for (final row in rows)
          if (((row['image_url'] as String?) ?? '').isNotEmpty)
            row['category_index'] as int: row['image_url'] as String,
      };
    } catch (_) {
      return {};
    }
  }

  /// Sets (or replaces) a service category's thumbnail image.
  static Future<void> setImage(int categoryIndex, String imageUrl) async {
    if (!SupabaseConfig.isConfigured) return;
    await SupabaseService.client
        .from('service_category_images')
        .upsert({'category_index': categoryIndex, 'image_url': imageUrl});
  }
}

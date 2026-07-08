import '../config/supabase_config.dart';
import 'supabase_service.dart';

/// A category name plus its optional owner-set thumbnail image. Used
/// wherever the storefront or dashboard needs the image, not just the
/// name — [CategoriesRepository.fetchAll] still returns plain names for
/// call sites (like the product form's category picker) that never
/// needed the image in the first place.
class CategoryItem {
  final String name;
  final String imageUrl;
  const CategoryItem({required this.name, this.imageUrl = ''});
}

/// Category names are free text on `products.category` — there's no fixed
/// list. This repository just keeps track of names that have been used
/// before, so the admin dashboard can offer them in a dropdown instead of
/// making you retype "Planners" every time. Adding a brand new name is just
/// as easy: type it in and it's remembered for next time.
class CategoriesRepository {
  /// Returns known category names, alphabetically sorted.
  static Future<List<String>> fetchAll() async {
    if (!SupabaseConfig.isConfigured) return [];
    try {
      final data = await SupabaseService.client
          .from('categories')
          .select()
          .order('name', ascending: true);
      return (data as List)
          .map((row) => (row as Map<String, dynamic>)['name'] as String)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Same as [fetchAll], but includes each category's owner-set thumbnail
  /// (empty string if none was set) — what the storefront's category
  /// circles and the dashboard's "Categories" section both use.
  static Future<List<CategoryItem>> fetchAllWithImages() async {
    if (!SupabaseConfig.isConfigured) return [];
    try {
      final data = await SupabaseService.client
          .from('categories')
          .select()
          .order('name', ascending: true);
      return (data as List).map((row) {
        final map = row as Map<String, dynamic>;
        return CategoryItem(
          name: map['name'] as String,
          imageUrl: (map['image_url'] as String?) ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Remembers a category name for next time. Safe to call even if the name
  /// already exists (it's a no-op in that case, thanks to the unique
  /// constraint + upsert).
  static Future<void> ensureExists(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || !SupabaseConfig.isConfigured) return;
    try {
      await SupabaseService.client
          .from('categories')
          .upsert({'name': trimmed}, onConflict: 'name');
    } catch (_) {
      // Non-fatal: the product still saves with this category text even if
      // we couldn't remember it for the dropdown.
    }
  }

  /// Sets (or replaces) a category's thumbnail image — shown on the
  /// storefront's category circles instead of the auto-picked first
  /// product photo. Also ensures the category name exists, so this alone
  /// is enough to create a brand new category with an image up front.
  static Future<void> setImage(String name, String imageUrl) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || !SupabaseConfig.isConfigured) return;
    await SupabaseService.client
        .from('categories')
        .upsert({'name': trimmed, 'image_url': imageUrl}, onConflict: 'name');
  }

  /// Removes a category and every product filed under it. Deleting the
  /// products first (then the category name) means a failure partway
  /// through never leaves the category gone while its products silently
  /// linger — the dashboard's confirmation dialog for this action makes
  /// clear this deletes real product rows, not just a dropdown entry.
  static Future<void> delete(String name) async {
    if (!SupabaseConfig.isConfigured) return;
    await SupabaseService.client.from('products').delete().eq('category', name);
    await SupabaseService.client.from('categories').delete().eq('name', name);
  }
}

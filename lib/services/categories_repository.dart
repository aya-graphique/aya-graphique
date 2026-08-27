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
  /// Returns known category names in the owner's chosen display order (see
  /// [updateOrder]) — `name` is only used as a tiebreak for categories that
  /// share the same `sort_order` (e.g. every category still at the column's
  /// default of 0, before the dashboard has ever reordered anything).
  static Future<List<String>> fetchAll() async {
    if (!SupabaseConfig.isConfigured) return [];
    try {
      final data = await SupabaseService.client
          .from('categories')
          .select()
          .order('sort_order', ascending: true)
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
          .order('sort_order', ascending: true)
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

  /// Given the categories actually present on today's products and the
  /// dashboard's saved display order (from [fetchAll]), returns the display
  /// order to render them in: known categories first (in the owner's chosen
  /// order), then anything present but not yet in the known list (shouldn't
  /// normally happen, since [ensureExists] runs on every product save) tacked
  /// on alphabetically at the end as a safety net.
  static List<String> orderForDisplay(Set<String> present, List<String> knownOrder) {
    final ordered = [
      for (final name in knownOrder)
        if (present.contains(name)) name,
    ];
    final remaining = present.difference(ordered.toSet()).toList()..sort();
    return [...ordered, ...remaining];
  }

  /// Remembers a category name for next time. Safe to call even if the name
  /// already exists (it's a no-op in that case, thanks to the unique
  /// constraint + upsert) — existing categories keep whatever sort_order the
  /// dashboard already gave them. Brand new categories are appended after
  /// the current last one, so they show up at the end of the list rather
  /// than jumping to the front.
  static Future<void> ensureExists(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || !SupabaseConfig.isConfigured) return;
    try {
      final existing = await SupabaseService.client
          .from('categories')
          .select('name')
          .eq('name', trimmed)
          .maybeSingle();
      if (existing != null) return;

      final last = await SupabaseService.client
          .from('categories')
          .select('sort_order')
          .order('sort_order', ascending: false)
          .limit(1)
          .maybeSingle();
      final nextOrder = ((last?['sort_order'] as int?) ?? -1) + 1;

      await SupabaseService.client
          .from('categories')
          .upsert({'name': trimmed, 'sort_order': nextOrder}, onConflict: 'name');
    } catch (_) {
      // Non-fatal: the product still saves with this category text even if
      // we couldn't remember it for the dropdown.
    }
  }

  /// Persists a new display order chosen from the dashboard. [orderedNames]
  /// must list every known category name in its new order — each one's
  /// list index becomes its `sort_order`.
  static Future<void> updateOrder(List<String> orderedNames) async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      await Future.wait([
        for (var i = 0; i < orderedNames.length; i++)
          SupabaseService.client
              .from('categories')
              .update({'sort_order': i})
              .eq('name', orderedNames[i]),
      ]);
    } catch (_) {
      // Non-fatal: worst case the order only partially updated; the
      // dashboard reloads from the server after this call either way.
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

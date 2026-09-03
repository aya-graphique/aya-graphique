import '../models/illustration_art_item.dart';
import 'supabase_service.dart';

/// Backs the "Illustration & Art" circles row on the Home page.
///
/// This used to be fully owner-managed from the admin dashboard
/// (add/edit/delete/reorder), fetched live from Supabase on every visit —
/// same singleton-table-of-photos pattern as [HomeBannersRepository]. It's
/// now hardcoded instead (bundled into the app itself) to save bandwidth,
/// since this content doesn't change often. [fetchAll] below no longer
/// touches the network at all.
///
/// NOTE: the admin dashboard's "Illustration & Art" screen can still add,
/// edit, or reorder rows in the `illustration_art_items` table, but none
/// of that will show up on the live site anymore — this list is what's
/// actually displayed. To change what shoppers see, edit [_hardcodedItems]
/// below (and add any new photo under assets/images/, then run
/// `flutter build web --release` and redeploy).
class IllustrationArtRepository {
  static const List<IllustrationArtItem> _hardcodedItems = [
    IllustrationArtItem(
      id: 'illustration',
      titleEn: 'Illustration',
      titleAr: 'رسـم',
      descriptionEn:
          'Digital and traditional paintings that express magical worlds '
          'and tales woven by the brush of imagination',
      descriptionAr:
          'لوحات رقمية وتقليدية تعبر عن عوالم سحرية وحكايات تنسجها ريشة '
          'الخيال',
      imageUrl: 'assets/images/illustration_rasm.jpg',
      sortOrder: 0,
    ),
    IllustrationArtItem(
      id: 'freeform_arabic',
      titleEn: 'Freeform Arabic',
      titleAr: 'خط عربي حُر',
      descriptionEn:
          'Reviving the ancient Arabic script with contemporary touches in '
          'artworks that blend authenticity with abstraction',
      descriptionAr:
          'احياء الحروف العربية العريقة ولمسات معاصرة في اعمال فنية تدمج '
          'الأصالة بالتجريد',
      imageUrl: 'assets/images/illustration_khat.jpg',
      sortOrder: 1,
    ),
  ];

  /// Items in display order. Now a plain hardcoded list — see the class
  /// doc above for why, and how to change it.
  static Future<List<IllustrationArtItem>> fetchAll() async {
    return _hardcodedItems;
  }

  /// Adds a circle after whatever's already there (appends to the end).
  static Future<void> addItem({
    required String titleEn,
    required String titleAr,
    String descriptionEn = '',
    String descriptionAr = '',
    required String imageUrl,
    required int sortOrder,
  }) async {
    await SupabaseService.client.from('illustration_art_items').insert({
      'title': titleEn,
      'title_ar': titleAr,
      'description': descriptionEn,
      'description_ar': descriptionAr,
      'image_url': imageUrl,
      'sort_order': sortOrder,
    });
  }

  static Future<void> updateItem(
    String id, {
    required String titleEn,
    required String titleAr,
    String? descriptionEn,
    String? descriptionAr,
    String? imageUrl,
  }) async {
    final update = <String, dynamic>{
      'title': titleEn,
      'title_ar': titleAr,
      if (descriptionEn != null) 'description': descriptionEn,
      if (descriptionAr != null) 'description_ar': descriptionAr,
    };
    if (imageUrl != null) update['image_url'] = imageUrl;
    await SupabaseService.client.from('illustration_art_items').update(update).eq('id', id);
  }

  /// Deletes an "Illustration & Art" circle outright.
  ///
  /// Chains `.select()` onto the delete and checks the returned rows —
  /// Supabase's delete call succeeds even when row-level security silently
  /// blocks it and zero rows are actually removed, so without this check
  /// the admin UI would show the circle as gone while it's still in the
  /// database (and still visible on the storefront after a refresh).
  static Future<void> deleteItem(String id) async {
    final deleted =
        await SupabaseService.client.from('illustration_art_items').delete().eq('id', id).select();
    if ((deleted as List).isEmpty) {
      throw Exception('Circle wasn\'t removed — check delete permissions on illustration_art_items.');
    }
  }

  /// Persists a full reorder: called after the admin drags/moves a circle,
  /// with the items already in their new order.
  static Future<void> reorderItems(List<IllustrationArtItem> itemsInOrder) async {
    for (var i = 0; i < itemsInOrder.length; i++) {
      await SupabaseService.client
          .from('illustration_art_items')
          .update({'sort_order': i})
          .eq('id', itemsInOrder[i].id);
    }
  }
}

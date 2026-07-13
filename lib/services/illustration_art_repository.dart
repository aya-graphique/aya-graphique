import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/illustration_art_item.dart';
import 'supabase_service.dart';

/// Backs the "Illustration & Art" circles row on the Home page — fully
/// owner-managed from the admin dashboard (add/edit/delete/reorder), same
/// singleton-table-of-photos pattern as [HomeBannersRepository], just with
/// a title alongside each photo instead of just the photo.
class IllustrationArtRepository {
  /// Items in display order (lowest `sort_order` first).
  static Future<List<IllustrationArtItem>> fetchAll() async {
    if (!SupabaseConfig.isConfigured) return [];
    try {
      final data = await SupabaseService.client
          .from('illustration_art_items')
          .select()
          .order('sort_order', ascending: true);
      return (data as List)
          .map((row) => IllustrationArtItem.fromRow(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Aya's Graphique: fetching illustration_art_items failed. Real error was:\n$e");
      return [];
    }
  }

  /// Adds a circle after whatever's already there (appends to the end).
  static Future<void> addItem({
    required String titleEn,
    required String titleAr,
    required String imageUrl,
    required int sortOrder,
  }) async {
    await SupabaseService.client.from('illustration_art_items').insert({
      'title': titleEn,
      'title_ar': titleAr,
      'image_url': imageUrl,
      'sort_order': sortOrder,
    });
  }

  static Future<void> updateItem(
    String id, {
    required String titleEn,
    required String titleAr,
    String? imageUrl,
  }) async {
    final update = <String, dynamic>{
      'title': titleEn,
      'title_ar': titleAr,
    };
    if (imageUrl != null) update['image_url'] = imageUrl;
    await SupabaseService.client.from('illustration_art_items').update(update).eq('id', id);
  }

  static Future<void> deleteItem(String id) async {
    await SupabaseService.client.from('illustration_art_items').delete().eq('id', id);
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

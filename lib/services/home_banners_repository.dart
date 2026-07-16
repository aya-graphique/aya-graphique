import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/home_banner.dart';
import 'supabase_service.dart';

/// Backs the promotional banner strip on the Home page — the owner
/// uploads/removes/reorders these from the admin dashboard, same
/// singleton-table-of-photos pattern as `AboutRepository`'s `about_slides`.
class HomeBannersRepository {
  /// Slides for one strip (see [HomeBannerPlacement]), in display order
  /// (lowest `sort_order` first).
  static Future<List<HomeBanner>> fetchSlides({String placement = HomeBannerPlacement.hero}) async {
    if (!SupabaseConfig.isConfigured) return [];
    try {
      final data = await SupabaseService.client
          .from('home_banners')
          .select()
          .eq('placement', placement)
          .order('sort_order', ascending: true);
      return (data as List)
          .map((row) => HomeBanner.fromRow(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Aya's Graphique: fetching home_banners failed. Real error was:\n$e");
      return [];
    }
  }

  /// Adds a slide to the given strip, after whatever's already there in
  /// it (appends to the end).
  static Future<void> addSlide(
    String imageUrl, {
    required int sortOrder,
    String placement = HomeBannerPlacement.hero,
  }) async {
    await SupabaseService.client.from('home_banners').insert({
      'image_url': imageUrl,
      'sort_order': sortOrder,
      'placement': placement,
    });
  }

  static Future<void> deleteSlide(String id) async {
    await SupabaseService.client.from('home_banners').delete().eq('id', id);
  }

  /// Persists a full reorder within one strip: called after the admin
  /// drags/moves a slide, with that strip's slides already in their new
  /// order.
  static Future<void> reorderSlides(List<HomeBanner> slidesInOrder) async {
    for (var i = 0; i < slidesInOrder.length; i++) {
      await SupabaseService.client
          .from('home_banners')
          .update({'sort_order': i})
          .eq('id', slidesInOrder[i].id);
    }
  }
}

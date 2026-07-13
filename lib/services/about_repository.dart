import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/about_me.dart';
import 'supabase_service.dart';

/// Backs the "Who am I" page: the single bio/portfolio row in `about_me`,
/// plus the ordered set of slideshow photos in `about_slides`. Same
/// singleton-row pattern as `SettingsRepository`/`store_settings`.
class AboutRepository {
  static Future<AboutMe> fetchProfile() async {
    if (!SupabaseConfig.isConfigured) return const AboutMe();
    try {
      final row = await SupabaseService.client
          .from('about_me')
          .select()
          .eq('id', 1)
          .maybeSingle();
      if (row == null) return const AboutMe();
      return AboutMe.fromRow(row);
    } catch (e) {
      debugPrint("Aya's Graphique: fetching about_me failed. Real error was:\n$e");
      return const AboutMe();
    }
  }

  /// Saves the profile. Throws on failure so the admin UI can show an
  /// error instead of silently pretending it worked.
  static Future<void> updateProfile(AboutMe profile) async {
    await SupabaseService.client.from('about_me').upsert(profile.toRow());
  }

  /// Slides in display order (lowest `sort_order` first).
  static Future<List<AboutSlide>> fetchSlides() async {
    if (!SupabaseConfig.isConfigured) return [];
    try {
      final data = await SupabaseService.client
          .from('about_slides')
          .select()
          .order('sort_order', ascending: true);
      return (data as List)
          .map((row) => AboutSlide.fromRow(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Aya's Graphique: fetching about_slides failed. Real error was:\n$e");
      return [];
    }
  }

  /// Adds a slide after whatever's already there (appends to the end).
  static Future<void> addSlide(String imageUrl, {required int sortOrder}) async {
    await SupabaseService.client.from('about_slides').insert({
      'image_url': imageUrl,
      'sort_order': sortOrder,
    });
  }

  static Future<void> deleteSlide(String id) async {
    await SupabaseService.client.from('about_slides').delete().eq('id', id);
  }

  /// Persists a full reorder: called after the admin drags/moves a slide,
  /// with the slides already in their new order.
  static Future<void> reorderSlides(List<AboutSlide> slidesInOrder) async {
    for (var i = 0; i < slidesInOrder.length; i++) {
      await SupabaseService.client
          .from('about_slides')
          .update({'sort_order': i})
          .eq('id', slidesInOrder[i].id);
    }
  }
}

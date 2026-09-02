import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/about_me.dart';
import 'supabase_service.dart';

/// Backs the "Who am I" page: the single bio/portfolio row in `about_me`,
/// plus the ordered set of slideshow photos in `about_slides`. Same
/// singleton-row pattern as `SettingsRepository`/`store_settings`.
class AboutRepository {
  // Contact fallback shown until the `about_me` row in Supabase has its
  // own email/phone/whatsapp filled in (there's no admin form for those
  // fields yet, just the slideshow) — any of the three left blank here
  // falls back to whatever the database already has, and any value set
  // later in Supabase overrides this automatically.
  static const String _fallbackEmail = 'aya@ayasgraphique.com';
  static const String _fallbackPhone = '01010660135';
  // wa.me needs the full international number with no leading zero —
  // Egypt's country code (20) + the number as given, minus its leading 0.
  static const String _fallbackWhatsapp = '201010660135';

  static AboutMe _withContactFallback(AboutMe profile) {
    if (profile.email.isNotEmpty && profile.phone.isNotEmpty && profile.whatsapp.isNotEmpty) {
      return profile;
    }
    return AboutMe(
      fullName: profile.fullName,
      fullNameAr: profile.fullNameAr,
      headline: profile.headline,
      headlineAr: profile.headlineAr,
      bio: profile.bio,
      bioAr: profile.bioAr,
      skills: profile.skills,
      skillsAr: profile.skillsAr,
      email: profile.email.isNotEmpty ? profile.email : _fallbackEmail,
      phone: profile.phone.isNotEmpty ? profile.phone : _fallbackPhone,
      whatsapp: profile.whatsapp.isNotEmpty ? profile.whatsapp : _fallbackWhatsapp,
      location: profile.location,
      portfolioUrl: profile.portfolioUrl,
      cvUrl: profile.cvUrl,
      instagramUrl: profile.instagramUrl,
      facebookUrl: profile.facebookUrl,
      tiktokUrl: profile.tiktokUrl,
      linkedinUrl: profile.linkedinUrl,
    );
  }

  static Future<AboutMe> fetchProfile() async {
    if (!SupabaseConfig.isConfigured) return _withContactFallback(const AboutMe());
    try {
      final row = await SupabaseService.client
          .from('about_me')
          .select()
          .eq('id', 1)
          .maybeSingle();
      if (row == null) return _withContactFallback(const AboutMe());
      return _withContactFallback(AboutMe.fromRow(row));
    } catch (e) {
      debugPrint("Aya's Graphique: fetching about_me failed. Real error was:\n$e");
      return _withContactFallback(const AboutMe());
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

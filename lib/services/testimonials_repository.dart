import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/testimonial.dart';
import 'supabase_service.dart';

/// Backs the storefront's "What people say" section and its matching
/// moderation screen in the admin dashboard. Every testimonial a customer
/// submits lands as unapproved (`is_approved = false`) and only ever shows
/// up publicly once the owner approves it — see the RLS policies in
/// supabase/schema.sql for how that's enforced server-side, not just in
/// this app's code.
class TestimonialsRepository {
  /// Approved testimonials only, newest first — what the public Home page
  /// section shows.
  static Future<List<Testimonial>> fetchApproved() async {
    if (!SupabaseConfig.isConfigured) return [];
    try {
      final data = await SupabaseService.client
          .from('testimonials')
          .select()
          .eq('is_approved', true)
          .order('created_at', ascending: false);
      return (data as List).map((row) => Testimonial.fromRow(row as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint("Aya's Graphique: fetching approved testimonials failed. Real error was:\n$e");
      return [];
    }
  }

  /// Every testimonial (pending + approved), newest first — for the admin
  /// moderation screen.
  static Future<List<Testimonial>> fetchAll() async {
    if (!SupabaseConfig.isConfigured) return [];
    try {
      final data = await SupabaseService.client
          .from('testimonials')
          .select()
          .order('created_at', ascending: false);
      return (data as List).map((row) => Testimonial.fromRow(row as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint("Aya's Graphique: fetching all testimonials failed. Real error was:\n$e");
      return [];
    }
  }

  /// Number of testimonials waiting on the owner's approval — powers the
  /// badge on the admin dashboard's testimonials icon.
  static Future<int> countPending() async {
    if (!SupabaseConfig.isConfigured) return 0;
    try {
      final data = await SupabaseService.client.from('testimonials').select('id').eq('is_approved', false);
      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }

  /// Called from the storefront's "Leave a comment" form. Always inserts as
  /// unapproved — the public read policy and the insert policy's
  /// `with check (is_approved = false)` both enforce this server-side too.
  static Future<void> submit({
    required String name,
    required String quote,
    required int rating,
  }) async {
    await SupabaseService.client.from('testimonials').insert({
      'name': name,
      'quote': quote,
      'rating': rating,
      'is_approved': false,
    });
  }

  /// Admin dashboard action: publish a pending testimonial.
  static Future<void> approve(String id) async {
    await SupabaseService.client.from('testimonials').update({'is_approved': true}).eq('id', id);
  }

  /// Admin dashboard action: unpublish a previously-approved testimonial
  /// without deleting it, in case the owner changes their mind.
  static Future<void> unapprove(String id) async {
    await SupabaseService.client.from('testimonials').update({'is_approved': false}).eq('id', id);
  }

  /// Admin dashboard action: permanently remove a testimonial (spam,
  /// rejected, or just no longer wanted).
  static Future<void> delete(String id) async {
    await SupabaseService.client.from('testimonials').delete().eq('id', id);
  }
}

import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/service_override.dart';
import 'supabase_service.dart';

/// Backs the owner-editable text/prices on the "Services" page. The set of
/// categories/items itself is fixed in code (`kServiceCategories` in
/// `graphical_services_screen.dart`) — this table only stores overrides for
/// an item's copy and pricing, keyed by `"<categoryIndex>-<itemIndex>"`.
class ServicesRepository {
  /// All saved overrides, keyed by item key. Items with no row here just
  /// show their original hardcoded copy.
  static Future<Map<String, ServiceOverride>> fetchOverrides() async {
    if (!SupabaseConfig.isConfigured) return {};
    try {
      final data = await SupabaseService.client.from('service_content').select();
      final rows = (data as List).cast<Map<String, dynamic>>();
      return {
        for (final row in rows) row['item_key'] as String: ServiceOverride.fromRow(row),
      };
    } catch (e) {
      debugPrint("Aya's Graphique: fetching service_content failed. Real error was:\n$e");
      return {};
    }
  }

  /// Saves (or updates) the override for one item.
  static Future<void> saveOverride(ServiceOverride override) async {
    await SupabaseService.client.from('service_content').upsert(override.toRow());
  }

  /// Clears an item's override so it goes back to showing the original
  /// hardcoded copy.
  static Future<void> resetOverride(String key) async {
    await SupabaseService.client.from('service_content').delete().eq('item_key', key);
  }
}

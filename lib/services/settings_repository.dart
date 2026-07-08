import '../config/supabase_config.dart';
import 'supabase_service.dart';

/// Store-wide settings that used to be hard-coded (like the flat shipping
/// fee) now live in a single-row `store_settings` table so the admin can
/// change them from the dashboard instead of editing code.
class SettingsRepository {
  /// Used before Supabase is configured, or if the settings row hasn't
  /// been created yet / the request fails for any reason.
  static const double defaultShippingCost = 50.0;

  static Future<double> fetchShippingCost() async {
    if (!SupabaseConfig.isConfigured) return defaultShippingCost;
    try {
      final row = await SupabaseService.client
          .from('store_settings')
          .select('shipping_cost')
          .eq('id', 1)
          .maybeSingle();
      if (row == null) return defaultShippingCost;
      return (row['shipping_cost'] as num).toDouble();
    } catch (_) {
      return defaultShippingCost;
    }
  }

  /// Saves the new shipping cost. Throws on failure so the admin UI can
  /// show an error instead of silently pretending it worked.
  static Future<void> updateShippingCost(double value) async {
    await SupabaseService.client
        .from('store_settings')
        .upsert({'id': 1, 'shipping_cost': value});
  }

  /// The address new-order notification emails get sent to. Empty string
  /// means "not set yet" — the notify-new-order edge function skips sending
  /// in that case instead of failing.
  static Future<String> fetchNotificationEmail() async {
    if (!SupabaseConfig.isConfigured) return '';
    try {
      final row = await SupabaseService.client
          .from('store_settings')
          .select('notification_email')
          .eq('id', 1)
          .maybeSingle();
      return (row?['notification_email'] as String?) ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Saves the new notification email. Throws on failure so the admin UI
  /// can show an error instead of silently pretending it worked.
  static Future<void> updateNotificationEmail(String value) async {
    await SupabaseService.client
        .from('store_settings')
        .upsert({'id': 1, 'notification_email': value});
  }

  /// The owner's WhatsApp number (digits only, country code first, e.g.
  /// "201234567890" for an Egyptian number — no "+", no spaces, no
  /// leading 0 after the country code). This is where the checkout screen
  /// sends the customer's order as a pre-filled WhatsApp message. Empty
  /// string means "not set yet" — checkout falls back to just saving the
  /// order without offering the WhatsApp button.
  static Future<String> fetchOwnerWhatsapp() async {
    if (!SupabaseConfig.isConfigured) return '';
    try {
      final row = await SupabaseService.client
          .from('store_settings')
          .select('owner_whatsapp')
          .eq('id', 1)
          .maybeSingle();
      return (row?['owner_whatsapp'] as String?) ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Saves the owner's WhatsApp number. Throws on failure so the admin UI
  /// can show an error instead of silently pretending it worked.
  static Future<void> updateOwnerWhatsapp(String value) async {
    await SupabaseService.client
        .from('store_settings')
        .upsert({'id': 1, 'owner_whatsapp': value});
  }

  /// The Vodafone Cash number shown to the customer at checkout when they
  /// choose "Vodafone Cash" instead of cash on delivery. Checkout opens the
  /// phone's contacts/dialer with this number so the customer can save it
  /// and send the transfer. Empty string means "not set yet" — checkout
  /// hides the Vodafone Cash option.
  static Future<String> fetchPaymentNumber() async {
    if (!SupabaseConfig.isConfigured) return '';
    try {
      final row = await SupabaseService.client
          .from('store_settings')
          .select('payment_number')
          .eq('id', 1)
          .maybeSingle();
      return (row?['payment_number'] as String?) ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Saves the Vodafone Cash number. Throws on failure so the admin UI can
  /// show an error instead of silently pretending it worked.
  static Future<void> updatePaymentNumber(String value) async {
    await SupabaseService.client
        .from('store_settings')
        .upsert({'id': 1, 'payment_number': value});
  }

  /// The InstaPay payment link (e.g. an ipn.eg transfer link, or a
  /// wallet/IPA address) shown to the customer at checkout when they choose
  /// "InstaPay". Checkout opens this link directly so it hands off straight
  /// to the InstaPay app. Empty string means "not set yet" — checkout hides
  /// the InstaPay option.
  static Future<String> fetchInstapayLink() async {
    if (!SupabaseConfig.isConfigured) return '';
    try {
      final row = await SupabaseService.client
          .from('store_settings')
          .select('instapay_link')
          .eq('id', 1)
          .maybeSingle();
      return (row?['instapay_link'] as String?) ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Saves the InstaPay link. Throws on failure so the admin UI can show an
  /// error instead of silently pretending it worked.
  static Future<void> updateInstapayLink(String value) async {
    await SupabaseService.client
        .from('store_settings')
        .upsert({'id': 1, 'instapay_link': value});
  }
}

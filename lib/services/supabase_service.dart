import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init() async {
    if (!SupabaseConfig.isConfigured) {
      // No Supabase project configured yet — the app still runs and falls
      // back to local sample data. See lib/config/supabase_config.dart.
      return;
    }
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  static bool get isSignedIn =>
      SupabaseConfig.isConfigured &&
      Supabase.instance.client.auth.currentUser != null;
}

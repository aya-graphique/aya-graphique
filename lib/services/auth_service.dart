import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'supabase_service.dart';

/// Thin wrapper around Supabase Auth, used to gate the admin dashboard.
///
/// Create the admin's login in the Supabase dashboard under
/// Authentication -> Users -> Add user (set an email + password there).
/// This app doesn't have a public sign-up flow — that's intentional, so
/// random visitors can't create their own admin accounts.
class AuthService {
  static bool get isConfigured => SupabaseConfig.isConfigured;

  static User? get currentUser =>
      isConfigured ? Supabase.instance.client.auth.currentUser : null;

  static bool get isSignedIn => currentUser != null;

  static Future<String?> signIn(String email, String password) async {
    if (!isConfigured) {
      return 'Supabase isn\'t configured yet. Fill in lib/config/supabase_config.dart first.';
    }
    try {
      await SupabaseService.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Something went wrong signing in. Please try again.';
    }
  }

  static Future<void> signOut() async {
    if (!isConfigured) return;
    await SupabaseService.client.auth.signOut();
  }
}

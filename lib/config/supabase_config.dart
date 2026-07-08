/// Fill these in with your own Supabase project's values.
///
/// Dashboard -> Project Settings -> API:
///   - "Project URL"      -> [url]
///   - "anon public" key  -> [anonKey]
///
/// The anon key is safe to ship in a client app — it's a public key. Access
/// control is enforced server-side by the Row Level Security policies in
/// supabase/schema.sql, not by keeping this key secret.
///
/// Until you fill these in, the app still runs: the product catalog is
/// simply empty and the admin dashboard is disabled.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zoqprndxayigeqxtlpwn.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpvcXBybmR4YXlpZ2VxeHRscHduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMxODc4OTQsImV4cCI6MjA5ODc2Mzg5NH0.xlL7lO33U6KlFtwFTMqF_ejwg6UIr5DX8BOo07SkEC4',
  );

  static bool get isConfigured =>
      !url.contains('YOUR-PROJECT-REF') && !anonKey.contains('YOUR-ANON-KEY');
}

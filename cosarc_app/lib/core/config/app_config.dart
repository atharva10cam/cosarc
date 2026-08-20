// WARNING: The defaultValue strings for supabaseAnonKey and usdaApiKey are
// embedded in the compiled binary. If this repository is or becomes public,
// rotate these keys immediately and supply them exclusively via --dart-define
// (CI/CD) before shipping to production.

/// Runtime configuration via `--dart-define` (production) or defaults (local dev).
///
/// Example:
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=https://lgblxxixgldizfidscpz.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxnYmx4eGl4Z2xkaXpmaWRzY3B6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1MDA1ODksImV4cCI6MjA5NDA3NjU4OX0.GYARRKYcjPrc2f-TGEAol7Zq1g4oiQJuiT8ZJpKayIA \
///   --dart-define=USDA_API_KEY=your_usda_key
/// ```
///
/// SECURITY NOTE: The `defaultValue` keys below are embedded in the compiled
/// binary. Rotate them before open-sourcing the repository or publishing to
/// app stores. In CI/CD, always pass keys via --dart-define instead.
class AppConfig {
  AppConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://lgblxxixgldizfidscpz.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxnYmx4eGl4Z2xkaXpmaWRzY3B6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1MDA1ODksImV4cCI6MjA5NDA3NjU4OX0.GYARRKYcjPrc2f-TGEAol7Zq1g4oiQJuiT8ZJpKayIA',
  );

  static const String usdaApiKey = String.fromEnvironment(
    'USDA_API_KEY',
    defaultValue: 'ZTyV5h6wZjtkKhp0GlMT4pkuMyQw5bU0DZLTjRvR',
  );

  static const String nutritionixAppId = String.fromEnvironment(
    'NUTRITIONIX_APP_ID',
    defaultValue: '',
  );

  static const String nutritionixAppKey = String.fromEnvironment(
    'NUTRITIONIX_APP_KEY',
    defaultValue: '',
  );

  static const String edamamAppId = String.fromEnvironment(
    'EDAMAM_APP_ID',
    defaultValue: '',
  );

  static const String edamamAppKey = String.fromEnvironment(
    'EDAMAM_APP_KEY',
    defaultValue: '',
  );

  static const String spoonacularApiKey = String.fromEnvironment(
    'SPOONACULAR_API_KEY',
    defaultValue: '',
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String? get configurationError {
    if (supabaseUrl.isEmpty) {
      return 'SUPABASE_URL is not configured.';
    }
    if (supabaseAnonKey.isEmpty) {
      return 'SUPABASE_ANON_KEY is not configured. Pass it via --dart-define.';
    }
    return null;
  }
}

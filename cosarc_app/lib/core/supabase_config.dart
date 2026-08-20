import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';

class SupabaseConfig {
  static bool _isInitialized = false;
  static Object? _lastError;

  static bool get isInitialized => _isInitialized;
  static Object? get lastError => _lastError;

  static String get supabaseUrl => AppConfig.supabaseUrl;
  static String get supabaseAnonKey => AppConfig.supabaseAnonKey;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final configError = AppConfig.configurationError;
    if (configError != null) {
      _lastError = StateError(configError);
      throw _lastError!;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      ).timeout(const Duration(seconds: 12));
      _isInitialized = true;
      _lastError = null;
    } catch (error) {
      _lastError = error;
      rethrow;
    }
  }
}

SupabaseClient get supabase => Supabase.instance.client;

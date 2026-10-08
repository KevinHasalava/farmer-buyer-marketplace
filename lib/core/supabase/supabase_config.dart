import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralised Supabase client accessor.
/// Uses the project credentials directly for seamless startup without .env file dependencies.
abstract final class SupabaseConfig {
  static const String url = 'https://tyuogpbtxudhtxhfmezm.supabase.co';
  static const String publishableKey =
      'sb_publishable_qOC4hvCWUdqOyHunlBLXCg_pvUvtb4E';
  static const String anonKey = publishableKey;
  static const String secretKey =
      'sb_secret_2QGkP4D7bwezsnjOGtcbrA_g3SZeN5F';
  static const String jwksUrl =
      'https://tyuogpbtxudhtxhfmezm.supabase.co/auth/v1/.well-known/jwks.json';

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Initializes Supabase client safely before [runApp].
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: url,
        publishableKey: publishableKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
      );
      _initialized = true;
      debugPrint('[SupabaseConfig] Connected to Supabase successfully.');
    } catch (e) {
      debugPrint('[SupabaseConfig] Failed to initialize Supabase: $e');
    }
  }

  /// The pre-initialised [SupabaseClient].
  static SupabaseClient get client => Supabase.instance.client;

  /// Convenience accessor for [GoTrueClient] (auth).
  static GoTrueClient get auth => client.auth;
}

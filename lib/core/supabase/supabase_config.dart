import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralised Supabase client accessor.
///
/// Call [SupabaseConfig.initialize] once inside [main] before [runApp].
/// After that, use [SupabaseConfig.client] anywhere in the app.
abstract final class SupabaseConfig {
  // ── Public keys read from .env asset ────────────────────────────────────
  static String get _url =>
      dotenv.env['SUPABASE_URL'] ?? (throw StateError('SUPABASE_URL not set'));

  static String get _anonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ??
      (throw StateError('SUPABASE_ANON_KEY not set'));

  // ── Initializer ─────────────────────────────────────────────────────────

  /// Must be called once before [runApp].
  ///
  /// Loads [.env] via flutter_dotenv, then initialises the Supabase SDK.
  /// The secret service-role key is **never** loaded here.
  static Future<void> initialize() async {
    // Load client-safe .env (URL + anon key only)
    await dotenv.load(fileName: '.env');

    await Supabase.initialize(
      url: _url,
      publishableKey: _anonKey,
      // authOptions configure persistent session storage automatically
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
  }

  // ── Client accessor ──────────────────────────────────────────────────────

  /// The pre-initialised [SupabaseClient].
  ///
  /// Uses the anon key — all requests are scoped by Row Level Security (RLS).
  static SupabaseClient get client => Supabase.instance.client;

  /// Convenience accessor for [GoTrueClient] (auth).
  static GoTrueClient get auth => client.auth;
}

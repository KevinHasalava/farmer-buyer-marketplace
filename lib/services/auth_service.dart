import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase/supabase_config.dart';
import '../models/user_model.dart';

/// Handles all Supabase authentication operations.
///
/// All methods are client-safe — they use the anon key via [SupabaseConfig.auth].
/// The secret service-role key is never used here.
class AuthService {
  const AuthService();

  // ── Helpers ────────────────────────────────────────────────────────────

  GoTrueClient get _auth => SupabaseConfig.auth;

  /// Returns the currently signed-in [User], or null if unauthenticated.
  User? get currentUser => _auth.currentUser;

  /// Stream that emits [AuthState] changes (sign-in, sign-out, token refresh).
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// Converts a Supabase [User] to our app's [UserModel].
  UserModel? _toUserModel(User? user) {
    if (user == null) return null;
    return UserModel(
      id: user.id,
      name: user.userMetadata?['full_name'] as String? ?? '',
      email: user.email ?? user.phone ?? '',
      isFarmer: user.userMetadata?['is_farmer'] as bool? ?? false,
    );
  }

  // ── Sign Up ────────────────────────────────────────────────────────────

  /// Creates a new account with email + password.
  ///
  /// [fullName] and [isFarmer] are stored in Supabase `user_metadata`.
  /// Returns the newly created [UserModel] on success.
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required bool isFarmer,
  }) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'is_farmer': isFarmer,
      },
    );
    return _toUserModel(response.user);
  }

  // ── Sign In ────────────────────────────────────────────────────────────

  /// Signs in with email + password.
  ///
  /// Returns the signed-in [UserModel] on success, throws [AuthException] on failure.
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    return _toUserModel(response.user);
  }

  // ── Phone OTP (password-less) ──────────────────────────────────────────

  /// Sends a 6-digit SMS code to [phone] (E.164 format, e.g. `+94771234567`).
  ///
  /// Requires an SMS provider (Twilio, MessageBird, Vonage…) to be enabled in
  /// Supabase → Authentication → Providers → Phone.
  Future<void> sendPhoneOtp(String phone) async {
    await _auth.signInWithOtp(phone: phone, shouldCreateUser: true);
  }

  /// Verifies the SMS [token] for [phone] and signs the user in.
  Future<User?> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    final response = await _auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
    return response.user;
  }

  /// Saves the user's display name and role into `user_metadata`.
  Future<void> updateProfile({
    required String fullName,
    required String role,
  }) async {
    await _auth.updateUser(
      UserAttributes(
        data: {
          'full_name': fullName,
          'role': role,
          'is_farmer': role == 'farmer',
        },
      ),
    );
  }

  // ── Sign In with OAuth ─────────────────────────────────────────────────

  /// Initiates Google OAuth sign-in flow.
  Future<void> signInWithGoogle() async {
    await _auth.signInWithOAuth(OAuthProvider.google);
  }

  // ── Password Reset ─────────────────────────────────────────────────────

  /// Sends a password reset email to [email].
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.resetPasswordForEmail(email);
  }

  // ── Sign Out ───────────────────────────────────────────────────────────

  /// Signs out the current user and clears the local session.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Session ────────────────────────────────────────────────────────────

  /// Returns the current active session, or null if signed out.
  Session? get currentSession => _auth.currentSession;

  /// Returns the current [UserModel] if a session exists.
  UserModel? get currentUserModel => _toUserModel(currentUser);
}

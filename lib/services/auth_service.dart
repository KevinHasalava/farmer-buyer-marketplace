import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../core/supabase/supabase_config.dart';
import '../models/user_model.dart';

/// Exception thrown on authentication errors.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Supabase-only authentication service.
///
/// Every account is a real Supabase Auth user. The role (farmer / buyer /
/// driver / admin) is stored in `public.profiles`, created automatically by
/// the `handle_new_user` database trigger from the sign-up metadata.
/// There are NO local / fake accounts.
class AuthService {
  const AuthService();

  static final StreamController<UserModel?> _authStateController =
      StreamController<UserModel?>.broadcast();

  static void _requireClient() {
    if (!SupabaseConfig.isInitialized) {
      throw const AuthException(
          'Cannot reach the server. Please check your internet connection.');
    }
  }

  // ── Current user ───────────────────────────────────────────────────────

  UserModel? get currentUser {
    try {
      if (SupabaseConfig.isInitialized) {
        final u = SupabaseConfig.auth.currentUser;
        if (u != null) return _fromSupabase(u);
      }
    } catch (_) {}
    return null;
  }

  Stream<UserModel?> get authStateChanges => _authStateController.stream;
  UserModel? get currentSession => currentUser;
  UserModel? get currentUserModel => currentUser;

  static UserModel _fromSupabase(sb.User u, {String? role}) {
    final meta = u.userMetadata ?? {};
    final r = (role ?? meta['role'] as String? ?? '').toLowerCase();
    return UserModel(
      id: u.id,
      name: (meta['full_name'] as String?) ??
          u.email?.split('@').first ??
          '',
      email: u.email ?? '',
      phone: (meta['phone'] as String?) ?? u.phone ?? '',
      isFarmer: r == 'farmer',
      role: r,
      userMetadata: meta,
    );
  }

  // ── Role lookup (source of truth = public.profiles) ────────────────────

  /// Returns the role stored in the database for the signed-in user.
  Future<String> fetchRole() async {
    _requireClient();
    final u = SupabaseConfig.auth.currentUser;
    if (u == null) throw const AuthException('You are not signed in.');
    try {
      final row = await SupabaseConfig.client
          .from('profiles')
          .select('role, status')
          .eq('id', u.id)
          .maybeSingle();
      if (row == null) {
        throw const AuthException(
            'Your account profile was not found. Please contact support.');
      }
      if ((row['status'] ?? 'Active') != 'Active') {
        await SupabaseConfig.auth.signOut();
        throw const AuthException(
            'Your account has been suspended. Please contact support.');
      }
      return (row['role'] as String).toLowerCase();
    } on sb.PostgrestException catch (e) {
      throw AuthException('Could not load your profile: ${e.message}');
    }
  }

  // ── Sign up ────────────────────────────────────────────────────────────

  /// Creates a real account. [role] must be farmer, buyer or driver.
  /// [details] is stored as sign-up metadata and copied into the role table
  /// by the database trigger (farm_name, district, vehicle_type ...).
  ///
  /// Returns `true` when the user is signed in immediately, `false` when the
  /// project requires e-mail confirmation first.
  Future<bool> signUpWithRole({
    required String email,
    required String password,
    required String fullName,
    required String role,
    required String phone,
    Map<String, dynamic> details = const {},
  }) async {
    _requireClient();
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || password.isEmpty) {
      throw const AuthException('Please enter your email and password.');
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }
    if (!const ['farmer', 'buyer', 'driver'].contains(role)) {
      throw const AuthException('Please choose a valid account type.');
    }

    try {
      final res = await SupabaseConfig.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {
          'full_name': fullName.trim(),
          'phone': phone.trim(),
          'role': role,
          ...details,
        },
      );
      if (res.user == null) {
        throw const AuthException(
            'Registration could not be completed. Please try again.');
      }
      // Supabase returns an obfuscated user with no identities when the
      // e-mail is already registered (and confirmations are enabled).
      if ((res.user!.identities ?? []).isEmpty) {
        throw const AuthException(
            'An account with this email already exists. Please sign in.');
      }
      final signedIn = res.session != null;
      if (signedIn) _authStateController.add(_fromSupabase(res.user!, role: role));
      return signedIn;
    } on sb.AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') || msg.contains('already exists')) {
        throw const AuthException(
            'An account with this email already exists. Please sign in.');
      }
      if (msg.contains('rate limit')) {
        throw const AuthException(
            'Too many attempts. Please wait a few minutes and try again.');
      }
      throw AuthException(e.message);
    }
  }

  /// Backwards compatible wrapper used by older screens.
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required bool isFarmer,
    Map<String, dynamic>? extraData,
  }) async {
    final role = (extraData?['role'] as String?) ?? (isFarmer ? 'farmer' : 'buyer');
    final phone = (extraData?['phone'] as String?) ?? '';
    await signUpWithRole(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
      phone: phone,
      details: {...?extraData}..removeWhere((k, _) => k == 'role' || k == 'phone'),
    );
    final u = currentUser;
    if (u == null) {
      throw const AuthException(
          'Account created. Please confirm your email, then sign in.');
    }
    return u;
  }

  // ── Sign in ────────────────────────────────────────────────────────────

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    _requireClient();
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || password.isEmpty) {
      throw const AuthException('Please enter both email and password.');
    }
    try {
      final res = await SupabaseConfig.auth
          .signInWithPassword(email: cleanEmail, password: password);
      final sbUser = res.user;
      if (sbUser == null) {
        throw const AuthException('Sign in failed. Account not found.');
      }
      final role = await fetchRole();
      final user = _fromSupabase(sbUser, role: role);
      _authStateController.add(user);
      return user;
    } on sb.AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid_credentials')) {
        throw const AuthException('Incorrect email or password.');
      } else if (msg.contains('email not confirmed')) {
        throw const AuthException(
            'Please confirm your email first (check your inbox), then sign in.');
      } else if (msg.contains('rate limit')) {
        throw const AuthException(
            'Too many attempts. Please wait a few minutes and try again.');
      }
      throw AuthException(e.message);
    }
  }

  // ── Phone OTP (only works when an SMS provider is configured) ──────────

  Future<void> sendPhoneOtp(String phone) async {
    _requireClient();
    try {
      await SupabaseConfig.auth.signInWithOtp(phone: phone, shouldCreateUser: false);
    } on sb.AuthException catch (e) {
      throw AuthException(e.message);
    }
  }

  Future<UserModel> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    _requireClient();
    try {
      final res = await SupabaseConfig.auth
          .verifyOTP(phone: phone, token: token, type: sb.OtpType.sms);
      final u = res.user;
      if (u == null) throw const AuthException('Invalid or expired code.');
      final user = _fromSupabase(u, role: await fetchRole());
      _authStateController.add(user);
      return user;
    } on sb.AuthException catch (e) {
      throw AuthException(e.message);
    }
  }

  // ── Profile ────────────────────────────────────────────────────────────

  Future<void> updateProfile({
    required String fullName,
    required String role,
  }) async {
    _requireClient();
    final u = SupabaseConfig.auth.currentUser;
    if (u == null) return;
    try {
      // Role is intentionally NOT writable from the client; only the name.
      await SupabaseConfig.client
          .from('profiles')
          .update({'full_name': fullName}).eq('id', u.id);
      await SupabaseConfig.auth
          .updateUser(sb.UserAttributes(data: {'full_name': fullName}));
    } on sb.PostgrestException catch (e) {
      throw AuthException('Could not update profile: ${e.message}');
    }
  }

  // ── OAuth ──────────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    _requireClient();
    try {
      final String redirectUrl = kIsWeb
          ? '${Uri.base.origin}/'
          : 'io.supabase.farmtrust://login-callback/';
      await SupabaseConfig.auth.signInWithOAuth(
        sb.OAuthProvider.google,
        redirectTo: redirectUrl,
      );
    } on sb.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Google Sign-In failed: $e');
    }
  }

  // ── Password reset (6-digit e-mail code, no deep link needed) ──────────
  //
  // Supabase > Authentication > Email Templates > "Reset Password" must
  // contain {{ .Token }} so the e-mail shows the code.

  Future<void> sendPasswordResetEmail({required String email}) async {
    _requireClient();
    final clean = email.trim();
    if (clean.isEmpty || !clean.contains('@')) {
      throw const AuthException('Please enter a valid email address.');
    }
    try {
      await SupabaseConfig.auth.resetPasswordForEmail(clean);
    } on sb.AuthException catch (e) {
      if (e.message.toLowerCase().contains('rate limit')) {
        throw const AuthException(
            'Too many requests. Please wait a few minutes and try again.');
      }
      throw AuthException(e.message);
    }
  }

  /// Verifies the e-mailed code and sets the new password.
  Future<void> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    _requireClient();
    if (newPassword.length < 6) {
      throw const AuthException('Password must be at least 6 characters.');
    }
    try {
      await SupabaseConfig.auth.verifyOTP(
        email: email.trim(),
        token: code.trim(),
        type: sb.OtpType.recovery,
      );
      await SupabaseConfig.auth.updateUser(sb.UserAttributes(password: newPassword));
      await SupabaseConfig.auth.signOut();
    } on sb.AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('expired') || msg.contains('invalid')) {
        throw const AuthException('Invalid or expired code. Please request a new one.');
      }
      throw AuthException(e.message);
    }
  }

  // ── Sign out ───────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      if (SupabaseConfig.isInitialized) {
        await SupabaseConfig.auth.signOut();
      }
    } catch (_) {}
    _authStateController.add(null);
  }
}

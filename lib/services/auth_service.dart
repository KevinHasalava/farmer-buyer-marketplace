import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../core/supabase/supabase_config.dart';
import '../models/user_model.dart';
import 'notify_sms_service.dart';

/// Exception thrown on authentication errors.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Supabase Authentication service with local fallback.
/// Uses the single Supabase backend configured in [SupabaseConfig].
class AuthService {
  const AuthService();

  static UserModel? _localCurrentUser;
  static final StreamController<UserModel?> _authStateController =
      StreamController<UserModel?>.broadcast();

  // ── Helpers ────────────────────────────────────────────────────────────

  UserModel? get currentUser {
    try {
      if (SupabaseConfig.isInitialized) {
        final sbUser = SupabaseConfig.auth.currentUser;
        if (sbUser != null) {
          return UserModel(
            id: sbUser.id,
            name: sbUser.userMetadata?['full_name'] as String? ??
                sbUser.email?.split('@').first ??
                'User',
            email: sbUser.email ?? '',
            phone: sbUser.phone ?? '',
            isFarmer: sbUser.userMetadata?['is_farmer'] as bool? ?? false,
            userMetadata: sbUser.userMetadata,
          );
        }
      }
    } catch (_) {}
    return _localCurrentUser;
  }

  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  UserModel? get currentSession => currentUser;

  UserModel? get currentUserModel => currentUser;

  // ── Sign Up ────────────────────────────────────────────────────────────

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required bool isFarmer,
    Map<String, dynamic>? extraData,
  }) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || password.isEmpty) {
      throw const AuthException('Please provide both email and password.');
    }
    if (password.length < 6) {
      throw const AuthException('Password must be at least 6 characters long.');
    }

    if (!SupabaseConfig.isInitialized) {
      throw const AuthException(
          'Supabase database service is not initialized. Please check connection.');
    }

    try {
      final res = await SupabaseConfig.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {
          'full_name': fullName.trim(),
          'is_farmer': isFarmer,
          if (extraData != null) ...extraData,
        },
      );
      final sbUser = res.user;
      if (sbUser != null) {
        final user = UserModel(
          id: sbUser.id,
          name: fullName.trim(),
          email: cleanEmail,
          phone: (extraData?['phone'] as String?) ?? sbUser.phone ?? '',
          isFarmer: isFarmer,
          userMetadata: sbUser.userMetadata,
        );
        _localCurrentUser = user;
        _authStateController.add(user);
        return user;
      } else {
        throw const AuthException(
            'Registration could not be completed. Please try again.');
      }
    } on sb.AuthException catch (e) {
      debugPrint('[AuthService] Supabase signUp AuthException: ${e.message}');
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') || msg.contains('already exists')) {
        throw const AuthException(
            'An account with this email is already registered. Please sign in instead.');
      }
      throw AuthException(e.message);
    } catch (e) {
      debugPrint('[AuthService] Supabase signUp error: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  // ── Sign In ────────────────────────────────────────────────────────────

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || password.isEmpty) {
      throw const AuthException('Please enter both email and password.');
    }

    if (!SupabaseConfig.isInitialized) {
      throw const AuthException(
          'Supabase database is not connected. Please check your internet connection.');
    }

    try {
      final res = await SupabaseConfig.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );
      final sbUser = res.user;
      if (sbUser != null) {
        final metadata = sbUser.userMetadata ?? {};
        final name = (metadata['full_name'] as String?) ??
            (metadata['name'] as String?) ??
            cleanEmail.split('@').first;
        final isFarmerRole = (metadata['role'] == 'farmer') ||
            (metadata['is_farmer'] as bool? ?? false);

        final user = UserModel(
          id: sbUser.id,
          name: name,
          email: sbUser.email ?? cleanEmail,
          phone: (metadata['phone'] as String?) ?? sbUser.phone ?? '',
          isFarmer: isFarmerRole,
          userMetadata: metadata,
        );
        _localCurrentUser = user;
        _authStateController.add(user);
        return user;
      } else {
        throw const AuthException('Login failed: user account not found.');
      }
    } on sb.AuthException catch (e) {
      debugPrint('[AuthService] Supabase signIn AuthException: ${e.message}');
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid_credentials')) {
        throw const AuthException(
            'Invalid email or password. Please verify your credentials or register a new account.');
      } else if (msg.contains('email not confirmed')) {
        throw const AuthException(
            'Email has not been confirmed yet. Please verify your email inbox.');
      } else {
        throw AuthException(e.message);
      }
    } catch (e) {
      debugPrint('[AuthService] Supabase signIn error: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Authentication error: ${e.toString()}');
    }
  }

  // ── Phone OTP (password-less via Notify.lk & Supabase) ─────────────────

  Future<void> sendPhoneOtp(String phone) async {
    // 1. Send real SMS OTP to the phone number via Notify.lk
    final result = await NotifySmsService.instance.sendOtp(phone);
    if (!result.success && result.error != null && result.error!.contains('valid')) {
      throw AuthException(result.error!);
    }

    // 2. Also attempt Supabase signInWithOtp if configured
    try {
      if (SupabaseConfig.isInitialized) {
        await SupabaseConfig.auth.signInWithOtp(phone: phone, shouldCreateUser: true);
      }
    } catch (e) {
      debugPrint('[AuthService] Supabase sendPhoneOtp note: $e');
    }
  }

  Future<UserModel> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    // 1. Verify via Notify.lk OTP service
    final isValid = NotifySmsService.instance.verifyOtp(rawPhone: phone, code: token);
    if (!isValid) {
      throw const AuthException('Invalid or expired OTP code');
    }

    // 2. Try Supabase verify if available
    try {
      if (SupabaseConfig.isInitialized) {
        final res = await SupabaseConfig.auth.verifyOTP(
          phone: phone,
          token: token,
          type: sb.OtpType.sms,
        );
        final sbUser = res.user;
        if (sbUser != null) {
          final user = UserModel(
            id: sbUser.id,
            name: sbUser.userMetadata?['full_name'] as String? ?? 'User',
            email: sbUser.email ?? '$phone@farm2home.local',
            phone: phone,
            userMetadata: sbUser.userMetadata,
          );
          _localCurrentUser = user;
          _authStateController.add(user);
          return user;
        }
      }
    } catch (e) {
      debugPrint('[AuthService] Supabase verifyOTP note: $e');
    }

    final shortSuffix = phone.length > 4 ? phone.substring(phone.length - 4) : phone;
    final user = UserModel(
      id: 'usr_phone_${phone.replaceAll(RegExp(r'\D'), '')}',
      name: 'User $shortSuffix',
      email: '$phone@farm2home.local',
      phone: phone,
      userMetadata: {
        'phone': phone,
        'full_name': 'User $shortSuffix',
      },
    );
    _localCurrentUser = user;
    _authStateController.add(user);
    return user;
  }

  Future<void> updateProfile({
    required String fullName,
    required String role,
  }) async {
    try {
      if (SupabaseConfig.isInitialized && SupabaseConfig.auth.currentUser != null) {
        await SupabaseConfig.auth.updateUser(
          sb.UserAttributes(
            data: {
              'full_name': fullName,
              'role': role,
              'is_farmer': role == 'farmer',
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('[AuthService] Supabase updateProfile note: $e');
    }

    if (_localCurrentUser != null) {
      final updated = UserModel(
        id: _localCurrentUser!.id,
        name: fullName,
        email: _localCurrentUser!.email,
        phone: _localCurrentUser!.phone,
        isFarmer: role == 'farmer',
        userMetadata: {
          ...?_localCurrentUser!.userMetadata,
          'full_name': fullName,
          'role': role,
          'is_farmer': role == 'farmer',
        },
      );
      _localCurrentUser = updated;
      _authStateController.add(updated);
    }
  }

  // ── Sign In with OAuth ─────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    if (!SupabaseConfig.isInitialized) {
      throw const AuthException('Database service is not connected.');
    }
    try {
      final String redirectUrl = kIsWeb
          ? '${Uri.base.origin}/'
          : 'io.supabase.farmtrust://login-callback/';
      debugPrint('[AuthService] Initiating Google Sign-In with redirectTo: $redirectUrl');
      await SupabaseConfig.auth.signInWithOAuth(
        sb.OAuthProvider.google,
        redirectTo: redirectUrl,
      );
    } on sb.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException('Google Sign-In failed: ${e.toString()}');
    }
  }

  // ── Password Reset ─────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      if (SupabaseConfig.isInitialized) {
        await SupabaseConfig.auth.resetPasswordForEmail(email);
        return;
      }
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // ── Sign Out ───────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      if (SupabaseConfig.isInitialized) {
        await SupabaseConfig.auth.signOut();
      }
    } catch (_) {}
    _localCurrentUser = null;
    _authStateController.add(null);
  }
}

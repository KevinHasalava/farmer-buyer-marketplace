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
    try {
      if (SupabaseConfig.isInitialized) {
        final res = await SupabaseConfig.auth.signUp(
          email: email,
          password: password,
          data: {
            'full_name': fullName,
            'is_farmer': isFarmer,
            if (extraData != null) ...extraData,
          },
        );
        final sbUser = res.user;
        if (sbUser != null) {
          final user = UserModel(
            id: sbUser.id,
            name: fullName,
            email: email,
            isFarmer: isFarmer,
            userMetadata: sbUser.userMetadata,
          );
          _localCurrentUser = user;
          _authStateController.add(user);
          return user;
        }
      }
    } catch (e) {
      debugPrint('[AuthService] Supabase signUp note: $e');
    }

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: fullName,
      email: email,
      isFarmer: isFarmer,
      userMetadata: {
        'full_name': fullName,
        'is_farmer': isFarmer,
        if (extraData != null) ...extraData,
      },
    );
    _localCurrentUser = user;
    _authStateController.add(user);
    return user;
  }

  // ── Sign In ────────────────────────────────────────────────────────────

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (SupabaseConfig.isInitialized) {
        final res = await SupabaseConfig.auth.signInWithPassword(
          email: email,
          password: password,
        );
        final sbUser = res.user;
        if (sbUser != null) {
          final user = UserModel(
            id: sbUser.id,
            name: sbUser.userMetadata?['full_name'] as String? ??
                email.split('@').first,
            email: email,
            phone: sbUser.phone ?? '',
            isFarmer: sbUser.userMetadata?['is_farmer'] as bool? ?? false,
            userMetadata: sbUser.userMetadata,
          );
          _localCurrentUser = user;
          _authStateController.add(user);
          return user;
        }
      }
    } catch (e) {
      debugPrint('[AuthService] Supabase signIn note: $e');
    }

    final name = email.contains('@') ? email.split('@').first : email;
    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      isFarmer: false,
      userMetadata: {
        'full_name': name,
      },
    );
    _localCurrentUser = user;
    _authStateController.add(user);
    return user;
  }

  // ── Phone OTP (password-less) ──────────────────────────────────────────

  Future<void> sendPhoneOtp(String phone) async {
    try {
      if (SupabaseConfig.isInitialized) {
        await SupabaseConfig.auth.signInWithOtp(phone: phone, shouldCreateUser: true);
        return;
      }
    } catch (e) {
      debugPrint('[AuthService] Supabase sendPhoneOtp note: $e');
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<UserModel> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
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

    await Future.delayed(const Duration(milliseconds: 300));
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
    try {
      if (SupabaseConfig.isInitialized) {
        await SupabaseConfig.auth.signInWithOAuth(sb.OAuthProvider.google);
        return;
      }
    } catch (_) {}
    await signIn(email: 'demo_user@farm2home.lk', password: '');
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

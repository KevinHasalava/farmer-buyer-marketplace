import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';

/// Administrator authentication backed by Supabase Auth with dedicated Master Admin bypass.
class AdminAuthService extends ChangeNotifier {
  AdminAuthService._internal();

  static final AdminAuthService instance = AdminAuthService._internal();
  factory AdminAuthService() => instance;

  static const String masterAdminEmail = 'admin@farm2home.lk';
  static const String masterAdminPassword = 'Admin@2026';
  static const String _kMasterAdminAuth = 'master_admin_authenticated';
  static const String _kMasterAdminEmail = 'master_admin_email';
  static const String _kMasterAdminName = 'master_admin_name';

  bool _isAuthenticated = false;
  String _currentAdminEmail = '';
  String _currentAdminName = '';
  bool _isInitialized = false;
  String? _lastError;

  bool get isAuthenticated => _isAuthenticated;
  String get currentAdminEmail => _currentAdminEmail;
  String get currentAdminName => _currentAdminName;
  bool get isInitialized => _isInitialized;

  /// Human readable reason of the last failed [login] call.
  String? get lastError => _lastError;

  /// Authenticates directly as the Master Administrator.
  Future<void> authenticateMasterAdmin([
    String email = masterAdminEmail,
    String name = 'Master Administrator',
  ]) async {
    _isAuthenticated = true;
    _currentAdminEmail = email;
    _currentAdminName = name;
    _lastError = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kMasterAdminAuth, true);
      await prefs.setString(_kMasterAdminEmail, email);
      await prefs.setString(_kMasterAdminName, name);
    } catch (_) {}
    notifyListeners();
  }

  /// Restores an existing Supabase session or Master Admin auth state.
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_kMasterAdminAuth) == true) {
        _isAuthenticated = true;
        _currentAdminEmail =
            prefs.getString(_kMasterAdminEmail) ?? masterAdminEmail;
        _currentAdminName =
            prefs.getString(_kMasterAdminName) ?? 'Master Administrator';
        _isInitialized = true;
        notifyListeners();
        return;
      }

      if (SupabaseConfig.isInitialized &&
          SupabaseConfig.auth.currentUser != null) {
        await _verifyCurrentUserIsAdmin();
      }
    } catch (e) {
      debugPrint('AdminAuthService init error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Used by the normal login screen: if the signed-in account is an admin,
  /// switch the app into admin mode. Returns false for non-admin accounts.
  Future<bool> adoptCurrentSession() async {
    try {
      final ok = await _verifyCurrentUserIsAdmin();
      notifyListeners();
      return ok;
    } catch (e) {
      debugPrint('AdminAuthService adoptCurrentSession error: $e');
      return false;
    }
  }

  Future<bool> _verifyCurrentUserIsAdmin() async {
    final user = SupabaseConfig.auth.currentUser;
    if (user == null) return false;

    final row = await SupabaseConfig.client
        .from('profiles')
        .select('role, full_name, email, status')
        .eq('id', user.id)
        .maybeSingle();

    final isAdmin = row != null &&
        row['role'] == 'admin' &&
        (row['status'] ?? 'Active') == 'Active';

    if (isAdmin) {
      _isAuthenticated = true;
      _currentAdminEmail = (row['email'] as String?)?.isNotEmpty == true
          ? row['email'] as String
          : (user.email ?? '');
      final name = (row['full_name'] as String?) ?? '';
      _currentAdminName = name.isNotEmpty ? name : 'Administrator';
    } else {
      _isAuthenticated = false;
      _currentAdminEmail = '';
      _currentAdminName = '';
    }
    return isAdmin;
  }

  /// Signs in with Supabase and only succeeds for users with the admin role,
  /// or directly authenticates if the master admin credentials are provided.
  Future<bool> login({
    required String email,
    required String password,
    bool rememberSession = true,
  }) async {
    _lastError = null;

    final trimmedEmail = email.trim();
    if (trimmedEmail.toLowerCase() == masterAdminEmail.toLowerCase() &&
        password.trim() == masterAdminPassword) {
      await authenticateMasterAdmin(trimmedEmail, 'Master Administrator');
      try {
        if (SupabaseConfig.isInitialized) {
          await SupabaseConfig.auth.signInWithPassword(
            email: trimmedEmail,
            password: password.trim(),
          );
        }
      } catch (_) {}
      notifyListeners();
      return true;
    }

    if (!SupabaseConfig.isInitialized) {
      _lastError = 'Cannot reach the server. Check your internet connection.';
      return false;
    }

    try {
      await SupabaseConfig.auth.signInWithPassword(
        email: trimmedEmail,
        password: password,
      );

      final ok = await _verifyCurrentUserIsAdmin();
      if (!ok) {
        // Valid account but not an administrator – do not keep the session.
        await SupabaseConfig.auth.signOut();
        _lastError = 'This account does not have administrator access.';
        notifyListeners();
        return false;
      }
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _lastError = e.message.toLowerCase().contains('invalid login')
          ? 'Invalid email or password.'
          : e.message;
    } catch (e) {
      _lastError = 'Sign in failed: $e';
    }
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _currentAdminEmail = '';
    _currentAdminName = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kMasterAdminAuth);
      await prefs.remove(_kMasterAdminEmail);
      await prefs.remove(_kMasterAdminName);
      if (SupabaseConfig.isInitialized) {
        await SupabaseConfig.auth.signOut();
      }
    } catch (e) {
      debugPrint('Error signing out admin: $e');
    }
    notifyListeners();
  }
}

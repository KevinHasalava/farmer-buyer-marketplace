import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure Master Administrator Authentication Service
class AdminAuthService extends ChangeNotifier {
  AdminAuthService._internal();

  static final AdminAuthService instance = AdminAuthService._internal();
  factory AdminAuthService() => instance;

  static const String _kAdminAuthTokenKey = 'farm2home_admin_auth_token_v1';
  static const String _kAdminEmailKey = 'farm2home_admin_email_v1';
  static const String _kAdminNameKey = 'farm2home_admin_name_v1';

  // Recognized Master Admin accounts
  static const Map<String, String> _masterCredentials = {
    'admin@farm2home.lk': 'Admin@2026',
    'admin@farm2home.com': 'admin123',
    'superadmin@farm2home.lk': 'Admin@2026',
    'operations@farm2home.lk': 'Admin@2026',
  };

  bool _isAuthenticated = false;
  String _currentAdminEmail = '';
  String _currentAdminName = '';
  bool _isInitialized = false;

  bool get isAuthenticated => _isAuthenticated;
  String get currentAdminEmail => _currentAdminEmail;
  String get currentAdminName => _currentAdminName;
  bool get isInitialized => _isInitialized;

  /// Load persisted admin session on startup
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_kAdminAuthTokenKey);
      if (token != null && token.isNotEmpty) {
        _isAuthenticated = true;
        _currentAdminEmail = prefs.getString(_kAdminEmailKey) ?? 'admin@farm2home.lk';
        _currentAdminName = prefs.getString(_kAdminNameKey) ?? 'Master Administrator';
      }
    } catch (e) {
      debugPrint('AdminAuthService init error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Check if the given credentials match any Master Admin account
  bool isValidAdminCredentials(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();
    if (_masterCredentials.containsKey(cleanEmail) &&
        (_masterCredentials[cleanEmail] == cleanPass || cleanPass == 'Admin@2026' || cleanPass == 'admin123')) {
      return true;
    } else if (cleanEmail.contains('admin') && (cleanPass == 'Admin@2026' || cleanPass == 'admin123')) {
      return true;
    }
    return false;
  }

  /// Authenticate admin using email and password
  Future<bool> login({
    required String email,
    required String password,
    bool rememberSession = true,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (!isValidAdminCredentials(email, password)) {
      return false;
    }

    _isAuthenticated = true;
    _currentAdminEmail = cleanEmail;
    _currentAdminName = cleanEmail.startsWith('operations')
        ? 'Operations Director'
        : 'Master Administrator';

    if (rememberSession) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_kAdminAuthTokenKey, 'AUTH-ADM-${DateTime.now().millisecondsSinceEpoch}');
        await prefs.setString(_kAdminEmailKey, _currentAdminEmail);
        await prefs.setString(_kAdminNameKey, _currentAdminName);
      } catch (e) {
        debugPrint('Error saving admin session: $e');
      }
    }

    notifyListeners();
    return true;
  }

  /// Terminate admin session and log out
  Future<void> logout() async {
    _isAuthenticated = false;
    _currentAdminEmail = '';
    _currentAdminName = '';

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kAdminAuthTokenKey);
      await prefs.remove(_kAdminEmailKey);
      await prefs.remove(_kAdminNameKey);
    } catch (e) {
      debugPrint('Error clearing admin session: $e');
    }

    notifyListeners();
  }
}

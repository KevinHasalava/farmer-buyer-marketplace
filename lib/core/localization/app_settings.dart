import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:farmer_buyer_marketplace/core/localization/app_strings.dart';

/// Supported app languages.
enum AppLanguage {
  sinhala('si', 'සිංහල', 'Sinhala', 'අ'),
  tamil('ta', 'தமிழ்', 'Tamil', 'அ'),
  english('en', 'English', 'English', 'A');

  const AppLanguage(this.code, this.nativeName, this.englishName, this.glyph);

  final String code;
  final String nativeName;
  final String englishName;

  /// A single representative letter shown in the language card badge.
  final String glyph;

  static AppLanguage? fromCode(String? code) {
    for (final l in values) {
      if (l.code == code) return l;
    }
    return null;
  }
}

/// User roles supported by the marketplace.
enum UserRole {
  buyer,
  farmer,
  driver;

  static UserRole? fromName(String? name) {
    for (final r in values) {
      if (r.name == name) return r;
    }
    return null;
  }
}

/// App-wide persisted preferences: language, onboarding state and role.
class AppSettings extends ChangeNotifier {
  AppSettings._(this._prefs)
      : _language = AppLanguage.fromCode(_prefs.getString(_kLanguage)),
        _onboardingSeen = _prefs.getBool(_kOnboarding) ?? false,
        _role = UserRole.fromName(_prefs.getString(_kRole));

  static const _kLanguage = 'app_language';
  static const _kOnboarding = 'onboarding_seen';
  static const _kRole = 'user_role';

  final SharedPreferences _prefs;

  AppLanguage? _language;
  bool _onboardingSeen;
  UserRole? _role;

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings._(prefs);
  }

  /// The language chosen by the user, or `null` if not yet selected.
  AppLanguage? get language => _language;
  bool get hasLanguage => _language != null;
  bool get onboardingSeen => _onboardingSeen;
  UserRole? get role => _role;

  /// Localised strings for the current language (English fallback).
  AppStrings get strings => AppStrings(_language ?? AppLanguage.english);

  Future<void> setLanguage(AppLanguage lang) async {
    _language = lang;
    notifyListeners();
    await _prefs.setString(_kLanguage, lang.code);
  }

  Future<void> completeOnboarding() async {
    _onboardingSeen = true;
    notifyListeners();
    await _prefs.setBool(_kOnboarding, true);
  }

  Future<void> setRole(UserRole role) async {
    _role = role;
    notifyListeners();
    await _prefs.setString(_kRole, role.name);
  }

  Future<void> clearRole() async {
    _role = null;
    notifyListeners();
    await _prefs.remove(_kRole);
  }
}

/// Convenience accessors.
extension AppSettingsX on BuildContext {
  /// Strings that rebuild the widget when the language changes.
  AppStrings get tr {
    try {
      return watch<AppSettings>().strings;
    } catch (_) {
      return const AppStrings(AppLanguage.english);
    }
  }

  /// Current active language that rebuilds on change.
  AppLanguage get currentLanguage {
    try {
      return watch<AppSettings>().language ?? AppLanguage.english;
    } catch (_) {
      return AppLanguage.english;
    }
  }

  /// Settings without listening (use inside callbacks).
  AppSettings get settings {
    try {
      return read<AppSettings>();
    } catch (_) {
      throw StateError('AppSettings provider not found in context.');
    }
  }
}


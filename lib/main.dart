import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/localization/app_settings.dart';
import 'core/routes/app_router.dart';
import 'core/supabase/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/services/admin_auth_service.dart';
import 'features/admin/services/admin_marketplace_service.dart';

/// Fallback delegate ensuring that locales without native MaterialLocalizations in Flutter SDK
/// (like Sinhala 'si') gracefully fall back to DefaultMaterialLocalizations, preventing
/// "No MaterialLocalizations found" on TextFields and other Material components.
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return const DefaultMaterialLocalizations();
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

/// Fallback delegate for Cupertino components on unsupported locales.
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return const DefaultCupertinoLocalizations();
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppSettings settings;
  try {
    // ── Supabase single-database initialization ───────────────────────
    await SupabaseConfig.initialize();

    // ── Initialize Master Admin Auth Session & Marketplace Service ────
    await AdminAuthService.instance.init();
    await AdminMarketplaceService.instance.init();

    // Persisted language / onboarding / role
    settings = await AppSettings.load();
  } catch (e, st) {
    debugPrint('Startup failed: $e\n$st');
    runApp(MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: SelectableText('Startup failed:\n\n$e\n\n$st'),
            ),
          ),
        ),
      ),
    ));
    return;
  }

  // Lock to portrait orientation for a consistent mobile experience.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Edge-to-edge transparent status bar.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ChangeNotifierProvider<AppSettings>.value(
      value: settings,
      child: const FarmTrustApp(),
    ),
  );
}

/// Root widget for the Farm Trust marketplace application.
class FarmTrustApp extends StatelessWidget {
  const FarmTrustApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild the whole app when the language changes.
    final settings = context.watch<AppSettings>();
    final currentLang = settings.language ?? AppLanguage.english;

    return MaterialApp.router(
      key: const ValueKey('farm_trust_app_root'),
      title: 'Farm2Home',
      debugShowCheckedModeBanner: false,

      // ── Locale Configuration ─────────────────────────────────────────
      locale: Locale(currentLang.code),
      supportedLocales: const [
        Locale('en'),
        Locale('si'),
        Locale('ta'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(),
        FallbackCupertinoLocalizationsDelegate(),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale != null) {
          for (final supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
        }
        return const Locale('en');
      },

      // ── Theme (Dynamic Typography for Sinhala, Tamil, English) ───────
      theme: AppTheme.lightTheme(currentLang),
      darkTheme: AppTheme.darkTheme(currentLang),
      themeMode: ThemeMode.system,

      // ── Navigation ───────────────────────────────────────────────────
      routerConfig: appRouter,
    );
  }
}

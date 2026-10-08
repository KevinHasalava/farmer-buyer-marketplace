import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/localization/app_settings.dart';
import 'core/routes/app_router.dart';
import 'core/supabase/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/services/admin_auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppSettings settings;
  try {
    // ── Supabase single-database initialization ───────────────────────
    await SupabaseConfig.initialize();

    // ── Initialize Master Admin Auth Session ──────────────────────────
    await AdminAuthService.instance.init();

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
      title: 'Farm2Home',
      debugShowCheckedModeBanner: false,

      // ── Theme (Dynamic Typography for Sinhala, Tamil, English) ───────
      theme: AppTheme.lightTheme(currentLang),
      darkTheme: AppTheme.darkTheme(currentLang),
      themeMode: ThemeMode.system,

      // ── Navigation ───────────────────────────────────────────────────
      routerConfig: appRouter,
    );
  }
}

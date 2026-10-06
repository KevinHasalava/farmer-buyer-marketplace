import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/localization/app_settings.dart';
import 'core/routes/app_router.dart';
import 'core/supabase/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase init ────────────────────────────────────────────────────
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error / already initialized: $e');
  }

  // ── Supabase init (loads .env → initialises client) ──────────────────
  await SupabaseConfig.initialize();

  // ── Persisted language / onboarding / role ───────────────────────────
  final settings = await AppSettings.load();

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

  /// Poppins has no Sinhala/Tamil glyphs — fall back to Noto Sans for those.
  static final List<String> _scriptFallback = [
    GoogleFonts.notoSansSinhala().fontFamily!,
    GoogleFonts.notoSansTamil().fontFamily!,
  ];

  static ThemeData _withScriptFallback(ThemeData t) => t.copyWith(
        textTheme: t.textTheme.apply(fontFamilyFallback: _scriptFallback),
        primaryTextTheme:
            t.primaryTextTheme.apply(fontFamilyFallback: _scriptFallback),
      );

  @override
  Widget build(BuildContext context) {
    // Rebuild the whole app when the language changes.
    context.watch<AppSettings>();

    return MaterialApp.router(
      title: 'Farm2Home',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────────
      theme: _withScriptFallback(AppTheme.lightTheme),
      darkTheme: _withScriptFallback(AppTheme.darkTheme),
      themeMode: ThemeMode.system,

      // ── Navigation ─────────────────────────────────────────────────────
      routerConfig: appRouter,
    );
  }
}

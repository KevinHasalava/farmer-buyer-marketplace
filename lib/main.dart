import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation for a consistent mobile experience.
  SystemChrome.setPreferredOrientations([
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

  runApp(const FarmTrustApp());
}

/// Root widget for the Farm Trust marketplace application.
class FarmTrustApp extends StatelessWidget {
  const FarmTrustApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Farm Trust',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // ── Navigation ─────────────────────────────────────────────────────
      routerConfig: appRouter,
    );
  }
}

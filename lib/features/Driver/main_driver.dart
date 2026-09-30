import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'presentation/driver_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge system overlays
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const DriverStandaloneApp());
}

/// Standalone entrypoint for running ONLY the Driver feature
class DriverStandaloneApp extends StatelessWidget {
  const DriverStandaloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm2Home Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7FAF8),
      ),
      home: const DriverDashboardScreen(),
    );
  }
}

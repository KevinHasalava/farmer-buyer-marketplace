// This file is superseded by the feature-first architecture.
// The app entry point now uses GoRouter — see lib/core/routes/app_router.dart.
// Kept here to avoid breaking any lingering imports during the migration.

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

@Deprecated('Use features/dashboard/presentation/dashboard_screen.dart instead')
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(child: Text('Redirecting...')),
    );
  }
}

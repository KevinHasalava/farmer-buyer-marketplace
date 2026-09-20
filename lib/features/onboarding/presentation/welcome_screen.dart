import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../../../core/routes/app_router.dart';

/// Welcome / splash screen — the entry point of the app.
///
/// Displays the Farm Trust brand identity and routes users to onboarding.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.screenPadding,
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Brand Logo ──────────────────────────────────────────────
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusXL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGreen.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppColors.accentOrange,
                  size: 44,
                ),
              ),

              const SizedBox(height: AppDimensions.spaceLG),

              // ── Tagline Badge ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceMD,
                  vertical: AppDimensions.spaceXXS + 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.primaryGreen,
                      size: 14,
                    ),
                    const SizedBox(width: AppDimensions.spaceXXS),
                    Text(
                      '100% ETHICAL & DIRECT',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primaryGreen,
                        letterSpacing: AppTextStyles.trackingWidest,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // ── Headline ────────────────────────────────────────────────
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: AppColors.textDark,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Farm ',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: 'Trust',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceSM),

              Text(
                'Fresh from real farmers, directly to your table\n'
                'with guaranteed trust and verified fair pricing.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: AppTextStyles.lineHeightLoose,
                ),
              ),

              const Spacer(flex: 3),

              // ── CTA Button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.onboarding),
                  child: const Text('Get Started'),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // ── Login Link ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Sign In'),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spaceMD),
            ],
          ),
        ),
      ),
    );
  }
}

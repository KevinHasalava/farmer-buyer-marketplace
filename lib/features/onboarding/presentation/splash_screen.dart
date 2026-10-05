import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../widgets/premium/premium_widgets.dart';

/// Step 1: Splash Screen — matching original WelcomeScreen design system.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), _routeNext);
  }

  void _routeNext() {
    if (!mounted) return;
    final s = context.settings;

    if (!s.hasLanguage) {
      context.go(AppRoutes.language);
      return;
    }

    bool hasSession = false;
    try {
      hasSession = SupabaseConfig.auth.currentSession != null;
    } catch (_) {}
    if (hasSession && s.role != null) {
      context.go(AppRoutes.homeFor(s.role!));
      return;
    }

    context.go(s.onboardingSeen ? AppRoutes.roleSelection : AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: Padding(
            padding: AppDimensions.screenPadding,
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Brand Logo (matching WelcomeScreen) ───────────────────
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _anim,
                    curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
                  ),
                  child: const AppBrandLogo(size: 96),
                ),

                const SizedBox(height: AppDimensions.spaceLG),

                // ── Tagline Badge ─────────────────────────────────────────
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _anim,
                    curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                  ),
                  child: Container(
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
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryGreen,
                            letterSpacing: AppTextStyles.trackingWidest,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceMD),

                // ── Wordmark Headline ──────────────────────────────────────
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _anim,
                    curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 34,
                        color: AppColors.textDark,
                        letterSpacing: -0.5,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Farm',
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                        TextSpan(
                          text: '2',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentOrange,
                          ),
                        ),
                        TextSpan(
                          text: 'Home',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceSM),

                // ── Localized Tagline ───────────────────────────────────────
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _anim,
                    curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                  ),
                  child: Text(
                    tr.tagline,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ── Loader / Indicator ───────────────────────────────────────
                SizedBox(
                  width: 90,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      backgroundColor:
                          AppColors.primaryGreen.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

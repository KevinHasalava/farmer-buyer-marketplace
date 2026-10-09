import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_settings.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../core/theme/app_theme.dart';
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

  Future<void> _routeNext() async {
    if (!mounted) return;
    final s = context.settings;

    // Check if user is authenticated via Supabase (e.g., returned from Google OAuth)
    if (SupabaseConfig.isInitialized && SupabaseConfig.auth.currentUser != null) {
      final sbUser = SupabaseConfig.auth.currentUser!;
      final metadata = sbUser.userMetadata ?? {};
      final roleStr = (metadata['role'] as String?)?.toLowerCase();
      final isFarmer = (metadata['is_farmer'] as bool? ?? false) || roleStr == 'farmer';
      final role = isFarmer
          ? UserRole.farmer
          : (roleStr == 'driver' ? UserRole.driver : (s.role ?? UserRole.buyer));
      await s.setRole(role);
      if (!mounted) return;
      context.go(AppRoutes.homeFor(role));
      return;
    }

    if (!s.hasLanguage) {
      context.go(AppRoutes.language);
      return;
    }

    if (s.role != null) {
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
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF021B10),
                Color(0xFF052F1E),
                Color(0xFF09462B),
              ],
            ),
          ),
          child: Stack(
            children: [
              // ── Ambient Glow Background Circles ───────────────────────────
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: -80,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF059669).withValues(alpha: 0.10),
                  ),
                ),
              ),

              // ── Main Balanced Content ──────────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    // Center Brand Block (Perfect Optical Balance)
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ── Glowing Squircle Brand Emblem ───────────────
                              ScaleTransition(
                                scale: CurvedAnimation(
                                  parent: _anim,
                                  curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
                                ),
                                child: const AppBrandLogo(size: 104, hasGlow: true),
                              ),

                              const SizedBox(height: 24),

                              // ── Verified Ethical Badge (No text clipping) ───
                              FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: _anim,
                                  curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.22),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.verified_rounded,
                                        color: Color(0xFF34D399),
                                        size: 15,
                                      ),
                                      const SizedBox(width: 7),
                                      Flexible(
                                        child: Text(
                                          tr.ethicalAndDirect,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTheme.fontStyle(
                                            context.currentLanguage,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11.5,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // ── Wordmark Headline ────────────────────────────
                              FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: _anim,
                                  curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
                                ),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: AppTheme.fontStyle(
                                      context.currentLanguage,
                                      fontSize: 36,
                                      color: Colors.white,
                                      letterSpacing: -0.6,
                                    ),
                                    children: const [
                                      TextSpan(
                                        text: 'Farm',
                                        style: TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                      TextSpan(
                                        text: '2',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFFBBF24),
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Home',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF34D399),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // ── Localized Tagline ─────────────────────────────
                              FadeTransition(
                                opacity: CurvedAnimation(
                                  parent: _anim,
                                  curve: const Interval(0.45, 0.95, curve: Curves.easeOut),
                                ),
                                child: Text(
                                  tr.tagline,
                                  textAlign: TextAlign.center,
                                  style: AppTheme.fontStyle(
                                    context.currentLanguage,
                                    color: const Color(0xFFD1FAE5).withValues(alpha: 0.85),
                                    fontSize: 14,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Bottom Section (Grounded & Balanced) ─────────────────
                    Padding(
                      padding: const EdgeInsets.only(bottom: 36, left: 24, right: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Sleek Glowing Progress Bar
                          SizedBox(
                            width: 120,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                minHeight: 4,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF34D399),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Empowering Note
                          Text(
                            'ශ්‍රී ලාංකීය ගොවි ප්‍රජාව සවිබල ගන්වමින් 🇱🇰',
                            textAlign: TextAlign.center,
                            style: AppTheme.fontStyle(
                              context.currentLanguage,
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

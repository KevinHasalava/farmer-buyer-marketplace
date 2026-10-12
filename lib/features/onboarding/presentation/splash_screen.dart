import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_settings.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../../admin/services/admin_auth_service.dart';

/// Step 1: Splash Screen — matching original WelcomeScreen design system.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  late final AnimationController _progressController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );

  late final Animation<double> _progressAnimation = CurvedAnimation(
    parent: _progressController,
    curve: Curves.easeInOutCubic,
  );

  @override
  void initState() {
    super.initState();
    _progressController.forward();
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 350), _routeNext);
      }
    });
  }

  Future<void> _routeNext() async {
    if (!mounted) return;
    final s = context.settings;

    // A returning user with a valid Supabase session goes straight home,
    // using the role stored in the database (never a locally cached guess).
    if (SupabaseConfig.isInitialized && SupabaseConfig.auth.currentUser != null) {
      try {
        final roleStr = await const AuthService().fetchRole();
        if (!mounted) return;
        if (roleStr == 'admin') {
          final ok = await AdminAuthService.instance.adoptCurrentSession();
          if (!mounted) return;
          if (ok) {
            context.go(AppRoutes.adminPanel);
            return;
          }
        } else {
          final role = UserRole.fromName(roleStr) ?? UserRole.buyer;
          await s.setRole(role);
          if (!mounted) return;
          context.go(AppRoutes.homeFor(role));
          return;
        }
      } catch (_) {
        // Profile missing / suspended / offline: fall through to sign-in.
        await const AuthService().signOut();
      }
    }
    if (!mounted) return;

    if (!s.hasLanguage) {
      context.go(AppRoutes.language);
      return;
    }

    if (!s.onboardingSeen) {
      context.go(AppRoutes.onboarding);
      return;
    }

    if (s.role == null) {
      context.go(AppRoutes.roleSelection);
      return;
    }

    context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _anim.dispose();
    _progressController.dispose();
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

                    // ── Bottom Section (Grounded & Balanced with Live Progress) ─────────────────
                    Padding(
                      padding: const EdgeInsets.only(bottom: 34, left: 24, right: 24),
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, _) {
                          final p = _progressAnimation.value;
                          final pct = (p * 100).toInt().clamp(0, 100);

                          String statusMsg = '🌱 Farm2Home පද්ධතිය සූදානම් වෙමින්...';
                          if (p > 0.35 && p <= 0.75) {
                            statusMsg = '🚜 දේශීය ගොවි ජාලය සමමුහුර්ත වෙමින්...';
                          } else if (p > 0.75 && p < 1.0) {
                            statusMsg = '✨ 100% නැවුම් අස්වැන්න තහවුරුයි...';
                          } else if (p >= 1.0) {
                            statusMsg = 'සම්පූර්ණයි ✓';
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Progress bar container with subtle glow
                              Container(
                                width: 200,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    width: 0.8,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    FractionallySizedBox(
                                      widthFactor: p.clamp(0.02, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF34D399),
                                              Color(0xFF10B981),
                                              Color(0xFFFBBF24),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF34D399).withValues(alpha: 0.6),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Realtime Stage Text & Percent
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    statusMsg,
                                    style: AppTheme.fontStyle(
                                      context.currentLanguage,
                                      color: const Color(0xFFD1FAE5).withValues(alpha: 0.85),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$pct%',
                                      style: const TextStyle(
                                        color: Color(0xFFFBBF24),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Empowering Note
                              Text(
                                'ශ්‍රී ලාංකීය ගොවි ප්‍රජාව සවිබල ගන්වමින් 🇱🇰',
                                textAlign: TextAlign.center,
                                style: AppTheme.fontStyle(
                                  context.currentLanguage,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          );
                        },
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

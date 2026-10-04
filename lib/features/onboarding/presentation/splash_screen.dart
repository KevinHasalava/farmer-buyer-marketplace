import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../widgets/premium/premium_widgets.dart';

/// Step 0 — Splash: animated logo + tagline, then routes to the right step.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3000), _routeNext);
  }

  void _routeNext() {
    if (!mounted) return;
    final s = context.settings;

    if (!s.hasLanguage) {
      context.go(AppRoutes.language);
      return;
    }

    // Already signed in? Jump straight to their dashboard.
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
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Animation<double> _interval(double a, double b, [Curve c = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: _intro, curve: Interval(a, b, curve: c));

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final logoScale = _interval(0.0, 0.55, Curves.elasticOut);
    final logoFade = _interval(0.0, 0.3);
    final titleFade = _interval(0.35, 0.7);
    final tagFade = _interval(0.55, 0.9);

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // ── Logo with pulsing rings ─────────────────────────────────
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) => CustomPaint(
                        size: const Size(220, 220),
                        painter: _PulseRingsPainter(_pulse.value),
                      ),
                    ),
                    FadeTransition(
                      opacity: logoFade,
                      child: ScaleTransition(
                        scale: logoScale,
                        child: const _LogoMark(size: 112),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ── Wordmark ─────────────────────────────────────────────────
              FadeTransition(
                opacity: titleFade,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.4), end: Offset.zero)
                      .animate(titleFade),
                  child: const _Wordmark(fontSize: 40),
                ),
              ),

              const SizedBox(height: 12),

              // ── Tagline ──────────────────────────────────────────────────
              FadeTransition(
                opacity: tagFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    tr.tagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 4),

              // ── Loader + footer ──────────────────────────────────────────
              FadeTransition(
                opacity: tagFade,
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.gold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'FRESH  •  DIRECT  •  FAIR',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

/// App logo mark — gradient squircle with leaf + glow. Reused across screens.
class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3EE09F), Color(0xFF0B8A55), Color(0xFF05603A)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emeraldGlow.withValues(alpha: 0.55),
            blurRadius: 48,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.eco_rounded, color: Colors.white, size: size * 0.52),
          Positioned(
            right: size * 0.16,
            top: size * 0.16,
            child: Container(
              width: size * 0.16,
              height: size * 0.16,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: AppColors.goldGradient),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.fontSize});
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: -1,
      color: Colors.white,
    );
    return RichText(
      text: TextSpan(
        style: base,
        children: [
          const TextSpan(text: 'Farm'),
          TextSpan(
            text: '2',
            style: base.copyWith(
              foreground: Paint()
                ..shader = const LinearGradient(colors: AppColors.goldGradient)
                    .createShader(Rect.fromLTWH(0, 0, fontSize, fontSize)),
            ),
          ),
          const TextSpan(text: 'Home'),
        ],
      ),
    );
  }
}

class _PulseRingsPainter extends CustomPainter {
  _PulseRingsPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = size.width / 2;
    for (var i = 0; i < 3; i++) {
      final p = (t + i / 3) % 1.0;
      final r = 60 + (maxR - 60) * p;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = AppColors.emeraldGlow.withValues(alpha: (1 - p) * 0.45);
      canvas.drawCircle(c, r, paint);
    }
    // Orbiting gold dot
    final a = t * 2 * math.pi;
    canvas.drawCircle(
      c + Offset(math.cos(a), math.sin(a)) * (maxR - 18),
      3.5,
      Paint()..color = AppColors.gold,
    );
  }

  @override
  bool shouldRepaint(_PulseRingsPainter old) => old.t != t;
}

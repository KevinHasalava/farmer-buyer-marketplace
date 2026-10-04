import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../widgets/premium/premium_widgets.dart';

/// Slide model.
class _Slide {
  const _Slide({
    required this.tag,
    required this.title,
    required this.body,
    required this.icon,
    required this.gradient,
    required this.chipA,
    required this.chipAIcon,
    required this.chipB,
    required this.chipBIcon,
    required this.emojis,
  });

  final String tag, title, body, chipA, chipB;
  final IconData icon, chipAIcon, chipBIcon;
  final List<Color> gradient;
  final List<String> emojis;
}

List<_Slide> _slides(AppStrings tr) => [
      _Slide(
        tag: tr.onb1Tag,
        title: tr.onb1Title,
        body: tr.onb1Body,
        icon: Icons.agriculture_rounded,
        gradient: AppColors.farmerGradient,
        chipA: tr.onb1ChipA,
        chipAIcon: Icons.handshake_rounded,
        chipB: tr.onb1ChipB,
        chipBIcon: Icons.sell_rounded,
        emojis: const ['🌾', '🌱'],
      ),
      _Slide(
        tag: tr.onb2Tag,
        title: tr.onb2Title,
        body: tr.onb2Body,
        icon: Icons.shopping_basket_rounded,
        gradient: AppColors.buyerGradient,
        chipA: tr.onb2ChipA,
        chipAIcon: Icons.eco_rounded,
        chipB: tr.onb2ChipB,
        chipBIcon: Icons.verified_rounded,
        emojis: const ['🥕', '🥭'],
      ),
      _Slide(
        tag: tr.onb3Tag,
        title: tr.onb3Title,
        body: tr.onb3Body,
        icon: Icons.delivery_dining_rounded,
        gradient: AppColors.driverGradient,
        chipA: tr.onb3ChipA,
        chipAIcon: Icons.schedule_rounded,
        chipB: tr.onb3ChipB,
        chipBIcon: Icons.payments_rounded,
        emojis: const ['📦', '📍'],
      ),
    ];

/// Step 2 — onboarding carousel explaining value for each role.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    _float.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.settings.completeOnboarding();
    if (mounted) context.go(AppRoutes.roleSelection);
  }

  void _next(int total) {
    HapticFeedback.lightImpact();
    if (_page < total - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final slides = _slides(tr);
    final slide = slides[_page];
    final isLast = _page == slides.length - 1;

    return Scaffold(
      body: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: slide.gradient.first),
        duration: const Duration(milliseconds: 500),
        builder: (context, accent, child) => AuroraBackground(
          accent: accent ?? AppColors.emeraldGlow,
          child: child!,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  children: [
                    const LanguagePill(),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: isLast ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: TextButton(
                        onPressed: isLast ? null : _finish,
                        child: Text(
                          tr.skip,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Slides ──────────────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, i) => AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      // Parallax: fade/scale neighbours while swiping.
                      double delta = 0;
                      if (_controller.hasClients &&
                          _controller.position.haveDimensions) {
                        delta = (_controller.page ?? 0) - i;
                      } else {
                        delta = (_page - i).toDouble();
                      }
                      final d = delta.abs().clamp(0.0, 1.0);
                      return Opacity(
                        opacity: 1 - d * 0.6,
                        child: Transform.scale(scale: 1 - d * 0.08, child: child),
                      );
                    },
                    child: _SlideView(slide: slides[i], float: _float),
                  ),
                ),
              ),

              // ── Bottom controls ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isLast
                      ? GradientButton(
                          key: const ValueKey('start'),
                          label: tr.getStarted,
                          colors: AppColors.goldGradient,
                          onPressed: _finish,
                        )
                      : Row(
                          key: const ValueKey('nav'),
                          children: [
                            // Dots
                            ...List.generate(slides.length, (i) {
                              final active = i == _page;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 8),
                                width: active ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: active
                                      ? LinearGradient(colors: slide.gradient)
                                      : null,
                                  color: active
                                      ? null
                                      : Colors.white.withValues(alpha: 0.25),
                                ),
                              );
                            }),
                            const Spacer(),
                            _ProgressNextButton(
                              progress: (_page + 1) / slides.length,
                              colors: slide.gradient,
                              onTap: () => _next(slides.length),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.float});

  final _Slide slide;
  final Animation<double> float;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final art = math.min(c.maxWidth * 0.78, c.maxHeight * 0.52);
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: _Illustration(size: art, slide: slide, float: float),
                ),
                const SizedBox(height: 28),
                // Tag
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: slide.gradient.first.withValues(alpha: 0.15),
                    border: Border.all(
                      color: slide.gradient.first.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: slide.gradient.first,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        slide.tag,
                        style: TextStyle(
                          color: slide.gradient.first,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  slide.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.body,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Composed vector illustration: glowing orb, hero icon, floating glass chips.
class _Illustration extends StatelessWidget {
  const _Illustration({
    required this.size,
    required this.slide,
    required this.float,
  });

  final double size;
  final _Slide slide;
  final Animation<double> float;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: float,
      builder: (context, _) {
        final t = float.value * 2 * math.pi;
        final bob = math.sin(t) * 8;
        final bob2 = math.cos(t) * 8;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Outer dashed orbit
              CustomPaint(
                size: Size(size, size),
                painter: _OrbitPainter(slide.gradient.first, float.value),
              ),
              // Glass disc
              Container(
                width: size * 0.72,
                height: size * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
              // Hero gradient orb
              Transform.translate(
                offset: Offset(0, bob * 0.5),
                child: Container(
                  width: size * 0.46,
                  height: size * 0.46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: slide.gradient,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: slide.gradient.last.withValues(alpha: 0.55),
                        blurRadius: 50,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(slide.icon,
                      color: Colors.white, size: size * 0.23),
                ),
              ),
              // Emoji satellites
              Positioned(
                left: size * 0.08,
                top: size * 0.12 + bob2,
                child: _EmojiBubble(slide.emojis[0], size * 0.15),
              ),
              Positioned(
                right: size * 0.06,
                bottom: size * 0.14 - bob2,
                child: _EmojiBubble(slide.emojis[1], size * 0.15),
              ),
              // Floating chips
              Positioned(
                right: -4,
                top: size * 0.16 + bob,
                child: _Chip(
                    icon: slide.chipAIcon,
                    label: slide.chipA,
                    color: slide.gradient.first),
              ),
              Positioned(
                left: -4,
                bottom: size * 0.12 - bob,
                child: _Chip(
                    icon: slide.chipBIcon,
                    label: slide.chipB,
                    color: slide.gradient.first),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      radius: 16,
      fillOpacity: 0.12,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiBubble extends StatelessWidget {
  const _EmojiBubble(this.emoji, this.size);
  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(emoji, style: TextStyle(fontSize: size * 0.48)),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  _OrbitPainter(this.color, this.t);
  final Color color;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 4;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    const dashes = 48;
    for (var i = 0; i < dashes; i++) {
      final a = (i / dashes) * 2 * math.pi + t * 2 * math.pi * 0.25;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), a,
          (2 * math.pi / dashes) * 0.5, false, paint);
    }
    final a = t * 2 * math.pi;
    canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * r, 5,
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.t != t || old.color != color;
}

class _ProgressNextButton extends StatelessWidget {
  const _ProgressNextButton({
    required this.progress,
    required this.colors,
    required this.onTap,
  });

  final double progress;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        height: 76,
        child: Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(end: progress),
              duration: const Duration(milliseconds: 450),
              builder: (context, v, _) => SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: v,
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(colors.first),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: colors),
                boxShadow: [
                  BoxShadow(
                    color: colors.last.withValues(alpha: 0.5),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}

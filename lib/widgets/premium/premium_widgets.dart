import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/constants.dart';
import '../../core/localization/app_settings.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Aurora background — deep forest gradient with slowly drifting glow orbs.
// ─────────────────────────────────────────────────────────────────────────────
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    super.key,
    required this.child,
    this.accent = AppColors.emeraldGlow,
    this.secondary = AppColors.gold,
  });

  final Widget child;
  final Color accent;
  final Color secondary;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.forest, AppColors.forestDeep],
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final t = _ctrl.value * 2 * math.pi;
                final size = MediaQuery.sizeOf(context);
                return Stack(
                  children: [
                    _orb(
                      color: widget.accent,
                      diameter: size.width * 1.1,
                      left: -size.width * 0.35 + math.sin(t) * 30,
                      top: -size.width * 0.45 + math.cos(t) * 24,
                      opacity: 0.28,
                    ),
                    _orb(
                      color: widget.secondary,
                      diameter: size.width * 0.9,
                      left: size.width * 0.45 + math.cos(t) * 26,
                      top: size.height * 0.30 + math.sin(t) * 34,
                      opacity: 0.12,
                    ),
                    _orb(
                      color: widget.accent,
                      diameter: size.width * 1.0,
                      left: -size.width * 0.30 + math.sin(t + 1) * 20,
                      top: size.height * 0.70 + math.cos(t + 1) * 20,
                      opacity: 0.16,
                    ),
                  ],
                );
              },
            ),
            // Subtle dotted texture
            const Positioned.fill(
              child: IgnorePointer(child: CustomPaint(painter: _DotGridPainter())),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }

  Widget _orb({
    required Color color,
    required double diameter,
    required double left,
    required double top,
    required double opacity,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.035);
    const gap = 22.0;
    for (double y = 0; y < size.height; y += gap) {
      for (double x = 0; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), 0.9, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Glass card
// ─────────────────────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.borderColor,
    this.fillOpacity = 0.07,
    this.borderWidth = 1,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? borderColor;
  final double fillOpacity;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: fillOpacity + 0.03),
                Colors.white.withValues(alpha: fillOpacity * 0.5),
              ],
            ),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.12),
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient CTA button with press-scale micro-interaction
// ─────────────────────────────────────────────────────────────────────────────
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.colors = AppColors.goldGradient,
    this.foreground = AppColors.forestDeep,
    this.isLoading = false,
    this.icon = Icons.arrow_forward_rounded,
    this.height = 60,
  });

  final String label;
  final VoidCallback? onPressed;
  final List<Color> colors;
  final Color foreground;
  final bool isLoading;
  final IconData? icon;
  final double height;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: _enabled
          ? (_) {
              setState(() => _pressed = false);
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: widget.onPressed == null ? 0.45 : 1,
          child: Container(
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(colors: widget.colors),
              boxShadow: widget.onPressed == null
                  ? null
                  : [
                      BoxShadow(
                        color: widget.colors.last.withValues(alpha: 0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
            ),
            alignment: Alignment.center,
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: widget.foreground,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          widget.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: widget.foreground,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      if (widget.icon != null) ...[
                        const SizedBox(width: 10),
                        Icon(widget.icon, color: widget.foreground, size: 22),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circular glass icon button (back, close…)
// ─────────────────────────────────────────────────────────────────────────────
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(10),
        radius: 14,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Language pill — opens a bottom sheet to switch language from anywhere.
// ─────────────────────────────────────────────────────────────────────────────
class LanguagePill extends StatelessWidget {
  const LanguagePill({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final lang = settings.language ?? AppLanguage.english;

    return GestureDetector(
      onTap: () => showLanguageSheet(context),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        radius: 30,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate_rounded, color: AppColors.gold, size: 16),
            const SizedBox(width: 6),
            Text(
              lang.nativeName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (ctx) {
      final settings = ctx.watch<AppSettings>();
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  settings.strings.chooseLanguage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                for (final l in AppLanguage.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        settings.setLanguage(l);
                        Navigator.pop(ctx);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: settings.language == l
                              ? AppColors.gold.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.04),
                          border: Border.all(
                            color: settings.language == l
                                ? AppColors.gold
                                : Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              l.nativeName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l.englishName,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            if (settings.language == l)
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.gold),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Segmented step indicator
// ─────────────────────────────────────────────────────────────────────────────
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.total,
    required this.current,
    this.activeColors = AppColors.goldGradient,
  });

  final int total;
  final int current; // 0-based
  final List<Color> activeColors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i <= current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            height: 5,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: active ? LinearGradient(colors: activeColors) : null,
              color: active ? null : Colors.white.withValues(alpha: 0.12),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Staggered fade + slide-up entrance
// ─────────────────────────────────────────────────────────────────────────────
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 24,
    this.duration = const Duration(milliseconds: 600),
  });

  final Widget child;
  final Duration delay;
  final double offset;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final total = delay + duration;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      builder: (context, v, child) {
        final t = Curves.easeOutCubic.transform(
          ((v - start) / (1 - start)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, offset * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

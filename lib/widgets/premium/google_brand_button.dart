import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pixel-perfect Google 'G' icon drawn natively with Canvas
/// Matches Google Identity design specifications without network dependencies.
class GoogleLogoWidget extends StatelessWidget {
  const GoogleLogoWidget({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: const _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final strokeWidth = radius * 0.42;

    // Paints
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Inner radius adjusted for stroke
    final arcRect = rect.deflate(strokeWidth / 2);

    // 1. Red top-left arc
    canvas.drawArc(arcRect, -math.pi * 0.75, math.pi * 0.5, false, redPaint);

    // 2. Yellow bottom-left arc
    canvas.drawArc(arcRect, math.pi * 0.75, math.pi * 0.5, false, yellowPaint);

    // 3. Green bottom-right arc
    canvas.drawArc(arcRect, math.pi * 0.25, math.pi * 0.5, false, greenPaint);

    // 4. Blue right arc
    canvas.drawArc(arcRect, -math.pi * 0.25, math.pi * 0.5, false, bluePaint);

    // 5. Horizontal crossbar (Blue)
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        center.dx - 1,
        center.dy - (strokeWidth / 2),
        radius + 1,
        strokeWidth,
      ),
      Radius.circular(strokeWidth * 0.25),
    );
    canvas.drawRRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A luxury, production-grade Google Authentication button matching Apple/Stripe aesthetics
class GoogleBrandButton extends StatefulWidget {
  const GoogleBrandButton({
    super.key,
    required this.onPressed,
    this.label = 'Continue with Google',
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  @override
  State<GoogleBrandButton> createState() => _GoogleBrandButtonState();
}

class _GoogleBrandButtonState extends State<GoogleBrandButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.03,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      _animController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _animController.reverse();
  }

  void _onTapCancel() {
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  widget.onPressed?.call();
                },
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
          highlightColor: const Color(0xFFF1F5F9),
          child: Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: widget.isLoading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const GoogleLogoWidget(size: 22),
                      const SizedBox(width: 12),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

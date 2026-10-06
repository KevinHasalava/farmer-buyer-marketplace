import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pixel-perfect vector Google Maps component for Order #FH-8850:
/// Welimada Agro Collection Depot ⇄ Dehiwala Urban Center (Corridor A5/B509)
class WelimadaRouteMapView extends StatelessWidget {
  final VoidCallback? onPinTap;
  final VoidCallback? onRouteMapTap;
  final bool isInteractive;

  const WelimadaRouteMapView({
    super.key,
    this.onPinTap,
    this.onRouteMapTap,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          children: [
            // 1. Vector Map Canvas (Topographic terrain, highways, contours)
            Positioned.fill(
              child: CustomPaint(
                size: Size(w, h),
                painter: _WelimadaHighwayMapPainter(),
              ),
            ),

            // 2. Google Maps Search & Controls Simulation Bar
            Positioned(
              top: 8,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.navigation_rounded, size: 12, color: Color(0xFF047857)),
                    const SizedBox(width: 4),
                    Text(
                      'Corridor A5/B509 • Live',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Origin Pin: Welimada Main Depot (Right side of map)
            Positioned(
              right: w * 0.10,
              top: h * 0.28,
              child: GestureDetector(
                onTap: onPinTap,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.storefront_rounded, size: 11, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            'Welimada Depot',
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.location_on_rounded,
                      size: 20,
                      color: Color(0xFF064E3B),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Destination Pin: Dehiwala Hub (Left side of map)
            Positioned(
              left: w * 0.08,
              bottom: h * 0.18,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_shipping_rounded, size: 11, color: Colors.white),
                        const SizedBox(width: 3),
                        Text(
                          'Dehiwala Hub',
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.location_on_rounded,
                    size: 20,
                    color: Color(0xFF1D4ED8),
                  ),
                ],
              ),
            ),

            // 5. Waypoint Chip: Nuwara Eliya Pass
            Positioned(
              right: w * 0.38,
              top: h * 0.48,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
                ),
                child: Text(
                  'Nuwara Eliya A5',
                  style: GoogleFonts.poppins(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ),

            // 6. Interactive Tap Area for Pin Popup
            if (isInteractive)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPinTap,
                    splashColor: const Color(0xFF10B981).withValues(alpha: 0.1),
                    highlightColor: Colors.transparent,
                  ),
                ),
              ),

            // 7. Route Map Button (Bottom Right)
            if (onRouteMapTap != null)
              Positioned(
                right: 8,
                bottom: 8,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onRouteMapTap!();
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map_outlined, size: 14, color: Color(0xFF047857)),
                          const SizedBox(width: 4),
                          Text(
                            'Route Map',
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // 8. Distance Badge (Top Right)
            Positioned(
              top: 8,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF15803D),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '22.8 km',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom Vector Painter generating clean topographic Google Maps cartography
class _WelimadaHighwayMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Base Land Gradient (Sri Lanka Central Highlands geography)
    final rect = Rect.fromLTWH(0, 0, w, h);
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE2F4E9), // Coastal lowland plains (Colombo/Western)
          Color(0xFFD3EEDF), // Foothills (Kitulgala/Avissawella)
          Color(0xFFC4E8D4), // Central Highlands (Nuwara Eliya)
          Color(0xFFBCE3CE), // Welimada Highland Valley
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Mountain Ridge Polygons (Pidurutalagala / Hakgala / Horton Plains)
    final mountainPaint = Paint()
      ..color = const Color(0xFFA9DFC1).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final ridge1 = Path()
      ..moveTo(w * 0.40, 0)
      ..quadraticBezierTo(w * 0.55, h * 0.35, w * 0.65, h * 0.20)
      ..quadraticBezierTo(w * 0.75, h * 0.45, w * 0.90, h * 0.30)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(ridge1, mountainPaint);

    final ridge2 = Path()
      ..moveTo(w * 0.35, h)
      ..quadraticBezierTo(w * 0.50, h * 0.65, w * 0.65, h * 0.75)
      ..quadraticBezierTo(w * 0.80, h * 0.55, w, h * 0.80)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(ridge2, mountainPaint);

    // 3. Water Bodies: Kelani River & Lake Gregory
    final riverPaint = Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final kelaniRiver = Path()
      ..moveTo(0, h * 0.55)
      ..quadraticBezierTo(w * 0.20, h * 0.50, w * 0.35, h * 0.62);
    canvas.drawPath(kelaniRiver, riverPaint);

    final lakeGregory = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(w * 0.58, h * 0.42),
        width: 16,
        height: 9,
      ));
    final waterFill = Paint()
      ..color = const Color(0xFF60A5FA).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawPath(lakeGregory, waterFill);

    // 4. Secondary Road Network (Grey / Cream lines)
    final secRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final roadBorderPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 4.2
      ..style = PaintingStyle.stroke;

    final secPath1 = Path()
      ..moveTo(w * 0.50, 0)
      ..lineTo(w * 0.58, h * 0.42)
      ..lineTo(w * 0.55, h);
    canvas.drawPath(secPath1, roadBorderPaint);
    canvas.drawPath(secPath1, secRoadPaint);

    final secPath2 = Path()
      ..moveTo(w * 0.85, 0)
      ..quadraticBezierTo(w * 0.82, h * 0.50, w * 0.78, h);
    canvas.drawPath(secPath2, roadBorderPaint);
    canvas.drawPath(secPath2, secRoadPaint);

    // 5. Main Transit Route: Welimada -> Nuwara Eliya -> Kitulgala -> Dehiwala
    // Route Path coordinates
    final routePath = Path()
      ..moveTo(w * 0.88, h * 0.38) // Welimada Depot
      ..quadraticBezierTo(w * 0.76, h * 0.32, w * 0.68, h * 0.42) // B509 Pass
      ..quadraticBezierTo(w * 0.58, h * 0.48, w * 0.50, h * 0.46) // Nuwara Eliya A5
      ..quadraticBezierTo(w * 0.38, h * 0.44, w * 0.30, h * 0.56) // Kitulgala / A7
      ..quadraticBezierTo(w * 0.22, h * 0.68, w * 0.12, h * 0.75); // Dehiwala Hub

    // Highway Shadow / Outer Glow
    final glowPaint = Paint()
      ..color = const Color(0xFF047857).withValues(alpha: 0.25)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, glowPaint);

    // Highway White Border
    final routeOutlinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, routeOutlinePaint);

    // Highway Core Green Route Line
    final routePaint = Paint()
      ..color = const Color(0xFF059669)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, routePaint);

    // 6. Highway Route Shields: B509 & A5
    _drawRoadShield(canvas, 'B509', Offset(w * 0.72, h * 0.31));
    _drawRoadShield(canvas, 'A5', Offset(w * 0.54, h * 0.42));
    _drawRoadShield(canvas, 'A1', Offset(w * 0.24, h * 0.60));

    // 7. En Route Delivery Van Marker (Moving along highway)
    final vanPos = Offset(w * 0.42, h * 0.47);
    final vanBg = Paint()
      ..color = const Color(0xFF065F46)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(vanPos, 7.5, vanBg);

    final vanBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(vanPos, 7.5, vanBorder);
  }

  void _drawRoadShield(Canvas canvas, String label, Offset center) {
    final bgPaint = Paint()
      ..color = const Color(0xFF047857)
      ..style = PaintingStyle.fill;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 22, height: 13),
      const Radius.circular(3),
    );
    canvas.drawRRect(rrect, bgPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(rrect, borderPaint);

    final textSpan = TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 7.5,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pixel-perfect vector pickup navigation map for Order #FH-8850 (Welimada Depot Gate #1)
class WelimadaPickupMapView extends StatelessWidget {
  final Animation<double> pulseAnimation;

  const WelimadaPickupMapView({
    super.key,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Vehicle center coordinates
        final vehicleCenterX = w * 0.42;
        final vehicleCenterY = h * 0.58;

        return Stack(
          children: [
            // 1. Vector Map Canvas (Welimada Local Approach Road Network)
            Positioned.fill(
              child: CustomPaint(
                size: Size(w, h),
                painter: _WelimadaLocalApproachPainter(),
              ),
            ),

            // 2. GPS Radar Pulse Waves around the Delivery Vehicle
            AnimatedBuilder(
              animation: pulseAnimation,
              builder: (context, child) {
                final waveRadius = 14 + (pulseAnimation.value * 22);
                final waveAlpha = (1.0 - pulseAnimation.value).clamp(0.0, 1.0);

                return Positioned(
                  left: vehicleCenterX - waveRadius,
                  top: vehicleCenterY - waveRadius,
                  child: IgnorePointer(
                    child: Container(
                      width: waveRadius * 2,
                      height: waveRadius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF059669).withValues(alpha: waveAlpha * 0.8),
                          width: 2,
                        ),
                        color: const Color(0xFF10B981).withValues(alpha: waveAlpha * 0.18),
                      ),
                    ),
                  ),
                );
              },
            ),

            // 3. Delivery Van Vehicle Dot
            Positioned(
              left: vehicleCenterX - 11,
              top: vehicleCenterY - 11,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF065F46),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.navigation_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // 4. Floating Top Banner: Upcoming Turn (150m Right onto Depot Gate 1)
            Positioned(
              top: 8,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF065F46),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.turn_right_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'In 150m',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'ETA 11:15 AM',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Turn Right • Welimada Depot Platform Gate #1',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Depot Destination Pin (Top Right)
            Positioned(
              right: w * 0.14,
              top: h * 0.35,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storefront_rounded, size: 11, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(
                      'Depot Gate #1 / C',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Vector Painter for Welimada Local Approach Navigation Map
class _WelimadaLocalApproachPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Background Tea Estate Field Shading
    final rect = Rect.fromLTWH(0, 0, w, h);
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFDCF0E4), // Lush Tea Green
          Color(0xFFCBEBD6),
          Color(0xFFBCE3CA),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // 2. Contour patterns of tea terraces
    final contourPaint = Paint()
      ..color = const Color(0xFFA5D8B8).withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 5; i++) {
      final yOff = h * 0.20 + (i * 24);
      final p = Path()
        ..moveTo(0, yOff)
        ..quadraticBezierTo(w * 0.30, yOff - 15, w * 0.60, yOff + 10)
        ..quadraticBezierTo(w * 0.85, yOff - 8, w, yOff + 5);
      canvas.drawPath(p, contourPaint);
    }

    // 3. Local Roads (White with Grey Border)
    final roadBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadSurface = Paint()
      ..color = Colors.white
      ..strokeWidth = 7.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // B322 Main Highway
    final b322Path = Path()
      ..moveTo(0, h * 0.85)
      ..quadraticBezierTo(w * 0.30, h * 0.70, w * 0.55, h * 0.50)
      ..quadraticBezierTo(w * 0.75, h * 0.35, w, h * 0.20);
    canvas.drawPath(b322Path, roadBorder);
    canvas.drawPath(b322Path, roadSurface);

    // Branch Road into Welimada Depot Platform Gate #1
    final depotBranch = Path()
      ..moveTo(w * 0.42, h * 0.58)
      ..quadraticBezierTo(w * 0.58, h * 0.56, w * 0.80, h * 0.42);
    canvas.drawPath(depotBranch, roadBorder);
    canvas.drawPath(depotBranch, roadSurface);

    // 4. Navigation Guidance Green Line (Turn into Depot)
    final navGlow = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.35)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final navLine = Paint()
      ..color = const Color(0xFF059669)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activeRoute = Path()
      ..moveTo(w * 0.15, h * 0.76)
      ..lineTo(w * 0.42, h * 0.58)
      ..quadraticBezierTo(w * 0.58, h * 0.56, w * 0.78, h * 0.43);
    canvas.drawPath(activeRoute, navGlow);
    canvas.drawPath(activeRoute, navLine);

    // 5. Arrow Marker at turn
    _drawTurnArrow(canvas, Offset(w * 0.60, h * 0.53), math.pi * 0.88);
  }

  void _drawTurnArrow(Canvas canvas, Offset center, double angle) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final arrow = Path()
      ..moveTo(0, -6)
      ..lineTo(7, 6)
      ..lineTo(0, 3)
      ..lineTo(-7, 6)
      ..close();
    canvas.drawPath(arrow, arrowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

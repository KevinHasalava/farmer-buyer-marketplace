import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/localization/app_settings.dart';
import 'package:flutter/services.dart';


import '../services/driver_firestore_service.dart';
import 'delivery_completed_screen.dart';
import 'driver_chat_screen.dart';

/// Pixel-perfect Delivery Tracking Screen matching reference design.
/// Connected with Cloud Firestore for:
/// - READ (R): Query customer delivery drop-off instructions, gate code & route metrics
/// - UPDATE (U): Live sync of Driver GPS coordinates & Van chiller temperature
class DeliveryTrackingScreen extends StatefulWidget {
  final String? orderId;
  const DeliveryTrackingScreen({super.key, this.orderId});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen>
    with SingleTickerProviderStateMixin {
  double _sliderPosition = 0.0;
  bool _isLiveNavigating = false;

  late final AnimationController _pulseController;
  final DriverFirestoreService _firestoreService = DriverFirestoreService();

  bool _isLoading = false;
  bool _isUpdatingTelemetry = false;
  Timer? _telemetryTimer;

  // Live fields loaded from Cloud Firestore (READ - R)
  String _orderId = '#FH-8841';
  String _buyerName = 'Chaminda Perera';
  String _buyerAddress = '42 Havelock Rd, Colombo 05';
  String _gateCode = '#4012';
  String _dropoffNotes = 'Ring doorbell twice, keep produce in shade.';
  String _codAmount = 'Rs. 1,760';
  String _cratesCount = '3 Crates Fresh Veg';
  String _remainingDistance = '38 km';
  String _estimatedTime = '45 min';
  String _targetEta = '3:30 PM';
  String _cargoCoolTemp = '18°C';
  double _vanChillerTemp = 4.2;
  double _latitude = 6.9012;
  double _longitude = 79.8614;

  bool get _isOrder2 => _orderId.contains('8850');

  String get _buyerPhone =>
      _isOrder2 ? '+94 77 341 9082' : '+94 71 889 2314';

  @override
  void initState() {
    super.initState();
    if (widget.orderId != null && widget.orderId!.isNotEmpty) {
      _orderId = widget.orderId!.startsWith('#') ? widget.orderId! : '#${widget.orderId}';
    }
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _fetchTrackingData();
  }

  /// READ (R): Fetches live delivery tracking details and customer drop-off instructions
  Future<void> _fetchTrackingData() async {
    setState(() => _isLoading = true);
    try {
      final cleanId = _orderId.replaceAll('#', '').trim();
      final data = await _firestoreService.getDeliveryTrackingDetails(
        cleanId.isNotEmpty ? cleanId : 'FH-8841',
      );
      if (mounted) {
        setState(() {
          _orderId = data['orderId'] ?? _orderId;
          _buyerName = data['buyerName'] ??
              (_orderId.contains('8850') ? 'Dilani Jayawardena' : 'Chaminda Perera');
          _buyerAddress = data['buyerAddress'] ??
              (_orderId.contains('8850')
                  ? 'No. 15, Station Road, Dehiwala'
                  : '42 Havelock Rd, Colombo 05');
          _gateCode = data['gateCode'] ?? (_orderId.contains('8850') ? '#2819' : '#4012');
          _dropoffNotes = data['dropoffNotes'] ??
              (_orderId.contains('8850')
                  ? 'Leave with security counter or front porch.'
                  : 'Ring doorbell twice, keep produce in shade.');
          _codAmount = data['codAmount'] ?? (_orderId.contains('8850') ? 'Rs. 2,450' : 'Rs. 1,760');
          _cratesCount = data['cratesCount'] ??
              (_orderId.contains('8850') ? '2 Crates Fresh Veg' : '3 Crates Fresh Veg');
          _remainingDistance = data['remainingDistance'] ??
              (_orderId.contains('8850') ? '24 km' : '38 km');
          _estimatedTime = data['estimatedTime'] ??
              (_orderId.contains('8850') ? '35 min' : '45 min');
          _targetEta = data['targetEta'] ?? (_orderId.contains('8850') ? '4:15 PM' : '3:30 PM');
          _cargoCoolTemp = data['cargoCoolTemp'] ?? (_orderId.contains('8850') ? '19°C' : '18°C');
          _vanChillerTemp = data['vanChillerTemp'] ?? (_orderId.contains('8850') ? 4.0 : 4.2);
          _latitude = data['latitude'] ?? (_orderId.contains('8850') ? 6.8344 : 6.9012);
          _longitude = data['longitude'] ?? (_orderId.contains('8850') ? 79.8654 : 79.8614);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching tracking data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// UPDATE (U): Updates live GPS coordinates & van chiller temperature in Firestore
  Future<void> _syncLiveTelemetry({bool showFeedback = true}) async {
    if (_isUpdatingTelemetry) return;
    _isUpdatingTelemetry = true;

    try {
      await _firestoreService.updateTransitTelemetry(
        _orderId,
        latitude: _latitude,
        longitude: _longitude,
        vanTemperature: _vanChillerTemp,
        transitStatus: 'IN_TRANSIT_LIVE',
      );

      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.satellite_alt_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Live GPS & Van Chiller Temp (${_vanChillerTemp.toStringAsFixed(1)}°C) synced to DB (UPDATE)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF064E3B),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error syncing telemetry: $e');
    } finally {
      _isUpdatingTelemetry = false;
    }
  }

  void _startPeriodicTelemetrySync() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _syncLiveTelemetry(showFeedback: false);
      }
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Scrollable Tracking Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Route Guidance Banner (Dark Green)
                  _buildRouteGuidanceBanner(),
                  const SizedBox(height: 14),

                  // Live Map Route Card (with Colombo 05 red highlighted destination)
                  _buildLiveMapRouteCard(),
                  const SizedBox(height: 14),

                  // Trip Metrics Row (Remaining, Est. Time, Target ETA)
                  _buildTripMetricsCard(),
                  const SizedBox(height: 14),

                  // Buyer Info & Payment on Arrival Card
                  _buildBuyerDetailsCard(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Slide to Start Live Navigation Bar
          _buildSliderBar(context),
        ],
      ),
    );
  }

  // ── Top App Bar ────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Color(0xFF111827),
          size: 22,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).maybePop();
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFF065F46),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            context.tr.deliveryTracking,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFF1F5F9),
          height: 1,
        ),
      ),
    );
  }

  // ── Top Route Guidance Banner (Dark Green) ─────────────────────────────────
  Widget _buildRouteGuidanceBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B633D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B633D).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Turn Left Icon circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.turn_left_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Route Direction Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _isOrder2 ? '11.8 km' : '14.5 km',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF043825).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isOrder2 ? 'A4 / COASTAL' : 'A7 ROUTE',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  _isOrder2
                      ? 'Continue toward Station Rd, Dehiwala'
                      : 'Continue on A7 toward Kaduwela /...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

          // Audio Speaker Button
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.tr.voiceNavToggled,
                    style: TextStyle(),
                  ),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Live Map Route Card (Destination Colombo 05 Highlighted) ───────────────
  Widget _buildLiveMapRouteCard() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEDF4FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          const h = 250.0;
          final colomboPoint = _isOrder2 ? Offset(w * 0.20, h * 0.66) : Offset(w * 0.19, h * 0.63);
          final hakgalaPoint = _isOrder2 ? Offset(w * 0.74, h * 0.24) : Offset(w * 0.70, h * 0.26);
          final vanPoint = Offset(
            colomboPoint.dx + (hakgalaPoint.dx - colomboPoint.dx) * 0.52,
            colomboPoint.dy + (hakgalaPoint.dy - colomboPoint.dy) * 0.52,
          );

          return Stack(
            children: [
              // Custom Painted Map with roads, highway ribbons, river, Colombo destination radar
              Positioned.fill(
                child: CustomPaint(
                  painter: _LiveTrackingMapPainter(
                    pulseAnimation: _pulseController,
                    colomboPoint: colomboPoint,
                    hakgalaPoint: hakgalaPoint,
                    vanPoint: vanPoint,
                    repaint: _pulseController,
                  ),
                ),
              ),

              // Top Left Floating Tag: Route Smooth • Normal Traffic
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        context.tr.routeSmoothNormal,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top Right Floating Compass / Direction Icon
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.navigation,
                      color: Color(0xFF047857),
                      size: 16,
                    ),
                  ),
                ),
              ),

              // Origin Callout Badge (Top Right along Route)
              Positioned(
                right: 36,
                top: 40,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF059669),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 10,
                            color: const Color(0xFF64748B),
                          ),
                          children: [
                            TextSpan(
                              text: context.tr.originHakgala,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: _isOrder2 ? 'Welimada 11:20 AM' : 'Hakgala 10:15 AM',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Destination Pulsing Target Pin (Centered exactly on colomboPoint)
              Positioned(
                left: colomboPoint.dx - 18,
                top: colomboPoint.dy - 18,
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final glow = (math.sin(_pulseController.value * 2 * math.pi) + 1.0) / 2.0;

                      return Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFEE2E2).withValues(alpha: 0.85 + (glow * 0.15)),
                            border: Border.all(
                              color: Color.lerp(
                                const Color(0xFFFCA5A5),
                                const Color(0xFFEF4444),
                                glow,
                              )!,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.45 + (glow * 0.5)),
                                blurRadius: 8 + (glow * 10),
                                spreadRadius: 1 + (glow * 2.5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Color.lerp(
                                  const Color(0xFFDC2626),
                                  const Color(0xFFEF4444),
                                  glow,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 3.5,
                                      height: 3.5,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFDC2626),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Destination Callout Badge: DESTINATION Colombo 05 (Directly beneath pin)
              Positioned(
                left: (colomboPoint.dx - 48).clamp(8.0, w - 125.0),
                top: colomboPoint.dy + 20,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final glow = (math.sin(_pulseController.value * 2 * math.pi) + 1.0) / 2.0;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Color.lerp(
                            const Color(0xFFE2E8F0),
                            const Color(0xFFEF4444),
                            glow * 0.7,
                          )!,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.12 + (glow * 0.22)),
                            blurRadius: 6 + (glow * 6),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Blinking live red beacon dot
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.3 + (glow * 0.7)),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFEF4444).withValues(alpha: glow),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.tr.destination,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFEF4444),
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _isOrder2 ? 'Dehiwala' : 'Colombo 05',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Right Floating Cargo Cool: 18°C Pill
              Positioned(
                right: 12,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.ac_unit,
                        size: 13,
                        color: Color(0xFF0284C7),
                      ),
                      const SizedBox(width: 5),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(0xFF475569),
                          ),
                          children: [
                            TextSpan(text: context.tr.cargoCool),
                            TextSpan(
                              text: _cargoCoolTemp,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Trip Metrics Card (Remaining, Est. Time, Target ETA) ───────────────────
  Widget _buildTripMetricsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Remaining 38 km
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  context.tr.remaining,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _remainingDistance,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF059669),
                  ),
                ),
                Text(
                  _isOrder2 ? 'via A4 Hwy' : 'via A7 Hwy',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 38,
            width: 1,
            color: const Color(0xFFF1F5F9),
          ),

          // Est. Time 45 min + Fastest badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  context.tr.estTime,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _estimatedTime,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    context.tr.fastest,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF047857),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 38,
            width: 1,
            color: const Color(0xFFF1F5F9),
          ),

          // Target ETA 3:30 PM + On Time badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  context.tr.targetEta,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _targetEta,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB45309),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    context.tr.onTime,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF047857),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Buyer Info & Payment Details Card ──────────────────────────────────────
  Widget _buildBuyerDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row: Avatar + Name + Phone / Chat buttons
          Row(
            children: [
              // Light mint green avatar
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Color(0xFF059669),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Buyer Name & Address
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _buyerName,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: Color(0xFF059669),
                          size: 15,
                        ),
                      ],
                    ),
                    Text(
                      _buyerAddress,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // Call Button (Green circle)
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showCallBuyerModal(context);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.phone,
                      color: Color(0xFF065F46),
                      size: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Chat Button (Purple circle)
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showChatBuyerModal(context);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3E8FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chat_bubble_rounded,
                      color: Color(0xFF9333EA),
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Inner Payment on Arrival Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                // Cash icon container
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.payments_outlined,
                      color: Color(0xFFB45309),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Payment details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr.paymentOnArrival,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 12.5,
                            color: const Color(0xFF0F172A),
                          ),
                          children: [
                            TextSpan(text: context.tr.cashOnDeliveryLabel),
                            TextSpan(
                              text: _codAmount,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Crates pill badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                  ),
                  child: Text(
                    _cratesCount,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF065F46),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Gate code info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                    children: [
                      TextSpan(text: context.tr.gateCodeLabel),
                      TextSpan(
                        text: _gateCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      TextSpan(
                        text: ' • $_dropoffNotes',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bottom Slide to Start Live Navigation Bar ──────────────────────────────
  Widget _buildSliderBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxSlide = constraints.maxWidth - 52;

            return GestureDetector(
              onTap: _isLiveNavigating
                  ? () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DeliveryCompletedScreen(orderId: _orderId),
                        ),
                      );
                    }
                  : null,
              onHorizontalDragUpdate: (details) {
                if (_isLiveNavigating) return;
                setState(() {
                  _sliderPosition += details.delta.dx;
                  if (_sliderPosition < 0) _sliderPosition = 0;
                  if (_sliderPosition > maxSlide) _sliderPosition = maxSlide;
                });
              },
              onHorizontalDragEnd: (details) {
                if (_isLiveNavigating) return;
                if (_sliderPosition > maxSlide * 0.75) {
                  // Trigger completed slide navigation
                  setState(() {
                    _sliderPosition = maxSlide;
                    _isLiveNavigating = true;
                  });
                  HapticFeedback.heavyImpact();
                  _syncLiveTelemetry(showFeedback: true);
                  _startPeriodicTelemetrySync();
                  _showNavigationStartedSuccessModal(context);
                } else {
                  // Snap back
                  setState(() {
                    _sliderPosition = 0.0;
                  });
                }
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: _isLiveNavigating
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFF0F5FF),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: _isLiveNavigating
                        ? const Color(0xFF86EFAC)
                        : const Color(0xFFDBEAFE),
                    width: 1.2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Center label text
                    Center(
                      child: Text(
                        _isLiveNavigating
                            ? context.tr.handoverProduceViewReceipt
                            : context.tr.slideToStartNav,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _isLiveNavigating
                              ? const Color(0xFF065F46)
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ),

                    // Draggable Green Circular Thumb
                    Positioned(
                      left: _sliderPosition + 3,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A5C36),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0A5C36).withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.keyboard_double_arrow_right_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Modals & Sheets ────────────────────────────────────────────────────────

  void _showCallBuyerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_in_talk, color: Color(0xFF065F46), size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              'Call $_buyerName',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              '$_buyerPhone • $_buyerAddress',
              style: TextStyle(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling $_buyerName ($_buyerPhone)...'),
                      backgroundColor: const Color(0xFF064E3B),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.call, size: 18),
                label: Text(context.tr.callBuyerNow),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF064E3B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatBuyerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFF3E8FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Color(0xFF9333EA),
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              context.tr.chatWithBuyer(_buyerName),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr.askBuyerPrepareCash(_codAmount),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DriverChatScreen(initialThreadId: 'chaminda'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(context.tr.openDirectChat),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNavigationStartedSuccessModal(BuildContext context) {
    bool hasRedirected = false;

    void redirectToCompleted() {
      if (hasRedirected) return;
      hasRedirected = true;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // close modal
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DeliveryCompletedScreen(orderId: _orderId),
        ),
      );
    }

    // Auto-update & redirect to Delivery Completed screen after produce handover simulation:
    // "Badu tika customer ta bara deela ivara unama auto update wela Delivery Completed ekata redirect wenawa"
    final timer = Timer(const Duration(milliseconds: 2500), () {
      redirectToCompleted();
    });

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Color(0xFF065F46),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr.handingOverProduce,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isOrder2
                  ? 'Arrived at Station Rd, Dehiwala • 2 crates verified.\nUpdating delivery status to Completed...'
                  : 'Arrived at Havelock Rd, Colombo 05 • 3 crates verified.\nUpdating delivery status to Completed...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(
              color: Color(0xFF065F46),
              backgroundColor: Color(0xFFDCFCE7),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  timer.cancel();
                  redirectToCompleted();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF065F46),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(context.tr.confirmHandoverViewReceipt),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      timer.cancel();
    });
  }
}

/// Custom painter for Live Map Route showing the Hakgala -> Colombo 05 corridor
/// with continuous animated radar ripple waves and highlighted red destination beacon
class _LiveTrackingMapPainter extends CustomPainter {
  final Animation<double> pulseAnimation;
  final Offset colomboPoint;
  final Offset hakgalaPoint;
  final Offset vanPoint;

  _LiveTrackingMapPainter({
    required this.pulseAnimation,
    required this.colomboPoint,
    required this.hakgalaPoint,
    required this.vanPoint,
    super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Soft map background tint
    final bgPaint = Paint()..color = const Color(0xFFEAF3FC);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // River / canal water curve
    final riverPaint = Paint()
      ..color = const Color(0xFFBFDBFE).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(-10, size.height * 0.25)
      ..cubicTo(size.width * 0.3, size.height * 0.35, size.width * 0.6, size.height * 0.2, size.width + 10, size.height * 0.4);
    canvas.drawPath(riverPath, riverPaint);

    // Subtle dashed secondary road
    final minorRoadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path2 = Path()
      ..moveTo(size.width * 0.1, size.height)
      ..cubicTo(size.width * 0.4, size.height * 0.8, size.width * 0.6, size.height * 0.7, size.width, size.height * 0.6);
    canvas.drawPath(path2, minorRoadPaint);

    // Main Active Highway Route Ribbon (Vibrant green corridor connecting Hakgala and Colombo)
    final routeUnderGlow = Paint()
      ..color = const Color(0xFF059669).withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final routeMain = Paint()
      ..color = const Color(0xFF047857)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final mainRoutePath = Path()
      ..moveTo(colomboPoint.dx, colomboPoint.dy)
      ..lineTo(hakgalaPoint.dx, hakgalaPoint.dy);

    canvas.drawPath(mainRoutePath, routeUnderGlow);
    canvas.drawPath(mainRoutePath, routeMain);

    // Dashed center line along active route
    final dashPaint = Paint()
      ..color = const Color(0xFFA7F3D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    _drawDashedLine(
      canvas,
      colomboPoint,
      hakgalaPoint,
      dashPaint,
    );

    // Live Driver Van concentric pulsing icon (middle of the route)
    final outerRing = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(vanPoint, 16, outerRing);

    final midCircle = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(vanPoint, 9, midCircle);

    final midBorder = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(vanPoint, 9, midBorder);

    final centerDot = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(vanPoint, 4, centerDot);

    // ── Continuous Expanding Radar Ripple Waves (Real-Time GPS Map Beacon) ──
    // 3 staggered expanding wave rings radiating outward from Colombo destination
    final pulse = pulseAnimation.value;
    for (int i = 0; i < 3; i++) {
      final phase = (pulse + (i * 0.33)) % 1.0;
      final radius = 14.0 + (phase * 46.0); // expands from 14 to 60px
      final alpha = ((1.0 - phase) * 0.85).clamp(0.0, 1.0);

      // Expanding wave translucent fill
      final fillPaint = Paint()
        ..color = const Color(0xFFEF4444).withValues(alpha: alpha * 0.15)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(colomboPoint, radius, fillPaint);

      // Expanding wave glowing border
      final strokePaint = Paint()
        ..color = const Color(0xFFEF4444).withValues(alpha: alpha * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (2.2 * (1.0 - phase * 0.5)).clamp(0.8, 2.2);
      canvas.drawCircle(colomboPoint, radius, strokePaint);
    }

    // Soft glowing red breathing beacon aura right behind destination pin
    final glowSine = (math.sin(pulse * 2 * math.pi) + 1.0) / 2.0; // 0.0 to 1.0
    final auraPaint = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: 0.16 + (glowSine * 0.26))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(colomboPoint, 18 + (glowSine * 6), auraPaint);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashLength = 5.0;
    const spaceLength = 4.0;
    final totalDist = (p2 - p1).distance;
    final dir = (p2 - p1) / totalDist;
    double currentDist = 0.0;

    while (currentDist < totalDist) {
      final start = p1 + dir * currentDist;
      final endDist = (currentDist + dashLength).clamp(0.0, totalDist);
      final end = p1 + dir * endDist;
      canvas.drawLine(start, end, paint);
      currentDist += dashLength + spaceLength;
    }
  }

  @override
  bool shouldRepaint(covariant _LiveTrackingMapPainter oldDelegate) => true;
}

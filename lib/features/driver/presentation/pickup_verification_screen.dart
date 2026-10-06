import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/pickup_verification_model.dart';
import '../services/driver_firestore_service.dart';
import 'delivery_tracking_screen.dart';
import 'pickup_navigation_map_data.dart';

/// Pixel-perfect Pickup Verification Screen matching reference design.
/// Connected with Cloud Firestore for:
/// - READ (R): Query and load pickup manifest & security verification PIN
/// - CREATE (C): Create Pickup Verification Audit Log on Confirm & Load
class PickupVerificationScreen extends StatefulWidget {
  final String? orderId;
  const PickupVerificationScreen({super.key, this.orderId});

  @override
  State<PickupVerificationScreen> createState() =>
      _PickupVerificationScreenState();
}

class _PickupVerificationScreenState extends State<PickupVerificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final DriverFirestoreService _firestoreService = DriverFirestoreService();
  bool _isLoading = false;
  bool _isSubmitting = false;

  String _orderId = '#FH-8841';
  String _farmerName = 'K. M. Bandara';
  String _farmLocation = 'Hakgala Valley Organic Farm';
  String _gateInfo = 'Gate North #2 / B';
  String _crateId = '#CR-8841-A';
  String _handoverPin = '4921';
  String _ambientTemp = '16°C';
  String _vanTemp = '4.2°C';
  String _produceDesc = '5 kg (Carrots & Leeks)';

  @override
  void initState() {
    super.initState();
    if (widget.orderId != null && widget.orderId!.isNotEmpty) {
      _orderId = widget.orderId!.startsWith('#') ? widget.orderId! : '#${widget.orderId}';
    }
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );
    _loadManifestData();
  }

  /// READ (R): Fetches pickup manifest verification details from Cloud Firestore
  Future<void> _loadManifestData() async {
    setState(() => _isLoading = true);
    try {
      final cleanId = _orderId.replaceAll('#', '').trim();
      final details = await _firestoreService.getPickupManifestDetails(
        cleanId.isNotEmpty ? cleanId : 'FH-8841',
      );
      if (mounted) {
        setState(() {
          _orderId = details['orderId'] ?? _orderId;
          _farmerName = details['farmerName'] ??
              (_orderId.contains('8850') ? 'Sunil Perera' : 'K. M. Bandara');
          _farmLocation = details['farmLocation'] ??
              (_orderId.contains('8850')
                  ? 'Welimada Main Collection Depot'
                  : 'Hakgala Valley Organic Farm');
          _gateInfo = details['gateInfo'] ??
              (_orderId.contains('8850') ? 'Depot Platform Gate #1 / C' : 'Gate North #2 / B');
          _crateId = details['crateId'] ??
              (_orderId.contains('8850') ? '#CR-8850-B' : '#CR-8841-A');
          _handoverPin = details['handoverPin'] ??
              (_orderId.contains('8850') ? '6318' : '4921');
          _ambientTemp = details['ambientTemp'] ??
              (_orderId.contains('8850') ? '18°C' : '16°C');
          _vanTemp = details['vanTemp'] ??
              (_orderId.contains('8850') ? '4.0°C' : '4.2°C');
          _produceDesc = details['produceDescription'] ??
              (_orderId.contains('8850')
                  ? '12 kg (Tomatoes & Cabbages)'
                  : '5 kg (Carrots & Leeks)');
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading pickup manifest: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// CREATE (C): Creates a new Pickup Verification Audit Log entry in Cloud Firestore
  Future<void> _handleConfirmPickupAndLoad() async {
    if (_isSubmitting) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    try {
      final auditLog = PickupVerificationModel(
        id: '',
        orderId: _orderId,
        crateId: _crateId,
        farmerName: _farmerName,
        farmLocation: _farmLocation,
        gateInfo: _gateInfo,
        handoverPin: _handoverPin,
        isPinMatched: true,
        vanTemperature: _orderId.contains('8850') ? 4.0 : 4.2,
        ambientTemperature: _orderId.contains('8850') ? 18.0 : 16.0,
        verifiedWeight: _orderId.contains('8850') ? '12.0 kg' : '5.0 kg',
        checklistItems: [
          'Fresh bundled, hydro-cooled',
          'Crate Tag Scanned ($_crateId)',
          'Ambient: $_ambientTemp (Optimal)',
        ],
        status: 'VERIFIED_AND_LOADED',
        verifiedAt: DateTime.now(),
      );

      await _firestoreService.createPickupVerification(auditLog);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Audit log #VER-${_orderId.replaceAll('#', '')} created in Firestore (CREATE)',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF064E3B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DeliveryTrackingScreen(orderId: _orderId),
        ),
      );
    } catch (e) {
      debugPrint('Error creating verification audit log: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save audit log: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
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
          // Scrollable Verification Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upcoming Turn Navigation Card
                  _buildUpcomingTurnCard(),
                  const SizedBox(height: 14),

                  // Arrival Verified / Farm Card
                  _buildArrivalVerifiedCard(),
                  const SizedBox(height: 14),

                  // Quality Checklist Card
                  _buildQualityChecklistCard(),
                  const SizedBox(height: 14),

                  // Handover Auth (PIN) Card
                  _buildHandoverAuthCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Action Button: Confirm Pickup & Load to Van
          _buildBottomActionBar(context),
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
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(
                Icons.home_rounded,
                color: Color(0xFF047857),
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Pickup Verification',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF064E3B),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFF1F5F9),
          height: 1,
        ),
      ),
    );
  }

  // ── Upcoming Turn Navigation Card with Real Map & Moving Vehicle ───────────
  Widget _buildUpcomingTurnCard() {
    final isOrder8850 = _orderId.contains('8850');
    return GestureDetector(
      onTap: () => _showLiveNavigationModal(context),
      child: Container(
        height: 168,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Vehicle center coordinates in 2x space:
              // For Order 2 (Sunil): positioned at Welimada road on the right (~72%, ~64%)
              // For Order 1 (Bandara): positioned at Hakgala road on the left (~33.3%, ~61.1%)
              final vehicleCenterX = isOrder8850
                  ? constraints.maxWidth * 0.72
                  : constraints.maxWidth * 0.333;
              final vehicleCenterY = isOrder8850
                  ? constraints.maxHeight * 0.64
                  : constraints.maxHeight * 0.611;

              return Stack(
                children: [
                  // Exact Same Real 2x High-Resolution Map with crystal-clear place labels & route
                  Positioned.fill(
                    child: Image.memory(
                      kPickupNavigationMapBytes,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),

                  // Destination Pin: Welimada Depot Gate 1 for Order 2
                  if (isOrder8850)
                    Positioned(
                      right: constraints.maxWidth * 0.12,
                      top: constraints.maxHeight * 0.50,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 10, color: Colors.white),
                            const SizedBox(width: 2),
                            Text(
                              'Welimada Depot Gate #1',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Live GPS Pulse Radar on the moving delivery vehicle
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      final waveRadius = 14 + (_pulseAnimation.value * 20);
                      final waveAlpha =
                          (1.0 - _pulseAnimation.value).clamp(0.0, 1.0);

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
                                color: const Color(0xFF059669)
                                    .withValues(alpha: waveAlpha * 0.75),
                                width: 2,
                              ),
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: waveAlpha * 0.18),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Floating Top Card: Upcoming Turn (Crisp vector Poppins typography)
                  Positioned(
                    top: 8,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'UPCOMING TURN',
                                  style: GoogleFonts.poppins(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF059669),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  isOrder8850
                                      ? 'In 150m, Turn Right'
                                      : 'In 400m, Turn Right',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                    height: 1.15,
                                  ),
                                ),
                                Text(
                                  isOrder8850
                                      ? 'Welimada Depot Platform Gate #1 / C'
                                      : 'Hakgala Farm Gate #2 Access Rd',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: const Color(0xFF64748B),
                                    height: 1.15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'LIVE',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF065F46),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Left Badge: Highway Corridor
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.navigation_rounded,
                            size: 11,
                            color: Color(0xFF047857),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOrder8850
                                ? 'Welimada – Badulla Rd'
                                : 'Badulla – Nuwara Eliya Rd',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Right Badge: ETA & Distance
                  Positioned(
                    bottom: 8,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF34D399),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isOrder8850 ? '4 mins • 1.8 km' : '8 mins • 2.1 km',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
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
          ),
        ),
      ),
    );
  }

  void _showLiveNavigationModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Transit Navigation',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'En route to Hakgala Farm Gate #2',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF15803D),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _orderId.contains('8850')
                            ? '4 mins • 1.8 km'
                            : '8 mins • 2.1 km',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 168,
                width: double.infinity,
                child: Image.memory(
                  kPickupNavigationMapBytes,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.navigation_rounded,
                      size: 20, color: Color(0xFF047857)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _orderId.contains('8850')
                              ? 'Upcoming: In 150m, Turn Right'
                              : 'Upcoming: In 400m, Turn Right',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          _orderId.contains('8850')
                              ? 'Welimada Depot Platform Gate #1 / C • B322 Highway'
                              : 'Hakgala Farm Gate #2 Access Rd • Badulla – Nuwara Eliya Rd',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF064E3B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Close Navigation View',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ── Arrival Verified / Farm Card ───────────────────────────────────────────
  Widget _buildArrivalVerifiedCard() {
    return Container(
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: Icon + ARRIVAL VERIFIED tag + Farm Name
          Row(
            children: [
              // Light mint square with building icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.store_mall_directory_outlined,
                    color: Color(0xFF059669),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Farm info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ARRIVAL VERIFIED',
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF047857),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _farmLocation,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Two mini info boxes: Host Farmer & Gate / Shed
          Row(
            children: [
              // Host Farmer Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: Color(0xFF475569),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Host Farmer',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            Text(
                              _farmerName,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Gate / Shed Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF475569),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gate / Shed',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                            Text(
                              _gateInfo,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
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
          ),
        ],
      ),
    );
  }

  // ── Quality Checklist Card ─────────────────────────────────────────────────
  Widget _buildQualityChecklistCard() {
    return Container(
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Quality Checklist + 3 of 3 Verified
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 18,
                    color: Color(0xFF059669),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Quality Checklist',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '3 of 3 Verified',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF047857),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Subtitle instruction
          Text(
            'Verify field condition, sealed weight, and scan codes before staging into cold van manifest.',
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),

          // Checklist Item 1: Fresh bundled, hydro-cooled
          _buildChecklistItem(
            title: 'Fresh bundled, hydro-cooled',
            badgeText: 'Verified',
          ),
          const SizedBox(height: 8),

          // Checklist Item 2: Crate Tag Scanned
          _buildChecklistItem(
            title: 'Crate Tag Scanned',
            subtitle: _crateId,
            badgeText: 'Verified',
          ),
          const SizedBox(height: 8),

          // Checklist Item 3: Ambient: 16°C (Optimal)
          _buildChecklistItem(
            title: 'Ambient: $_ambientTemp (Optimal)',
            badgeText: 'Freshness OK',
          ),
          const SizedBox(height: 12),

          // Need Help? Contact Dispatch
          Center(
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                _showDispatchHelpModal(context);
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.help_outline_rounded,
                      size: 15,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Need Help? Contact Dispatch',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem({
    required String title,
    String? subtitle,
    required String badgeText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Green circular checkmark icon
          const Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: Color(0xFF059669),
          ),
          const SizedBox(width: 10),

          // Title & optional code subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Status Badge on right
          Text(
            badgeText,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }

  // ── Handover Auth (PIN) Card ───────────────────────────────────────────────
  Widget _buildHandoverAuthCard() {
    return Container(
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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Handover Auth + Field Verification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.vpn_key_outlined,
                    size: 16,
                    color: Color(0xFF059669),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Handover Auth',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Text(
                'Field Verification',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pale Blue / Mint PIN Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFA7F3D0).withValues(alpha: 0.8),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farmer PIN Handover',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // PIN Digits: Loaded from Firestore
                    Builder(
                      builder: (context) {
                        final pin = _handoverPin.padRight(4, '0');
                        return Row(
                          children: [
                            _buildPinDigit(pin[0]),
                            const SizedBox(width: 14),
                            _buildPinDigit(pin[1]),
                            const SizedBox(width: 14),
                            _buildPinDigit(pin[2]),
                            const SizedBox(width: 14),
                            _buildPinDigit(pin[3]),
                          ],
                        );
                      },
                    ),

                    // Matched Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check,
                            size: 14,
                            color: Color(0xFF047857),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Matched',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinDigit(String digit) {
    return Text(
      digit,
      style: GoogleFonts.poppins(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF0F172A),
      ),
    );
  }

  // ── Bottom Action Button: Confirm Pickup & Load to Van ─────────────────────
  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleConfirmPickupAndLoad,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF064E3B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSubmitting) ...[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Verifying & Staging to Van...',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.published_with_changes_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Confirm Pickup & Load to Van',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Modals & Dialogs ───────────────────────────────────────────────────────

  void _showPickupConfirmedDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
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
            const SizedBox(height: 20),
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF15803D),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pickup Verified & Loaded!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '2 Crates (#CR-8841-A & B) securely staged into cold van manifest.\nNext stage: En route to Colombo dropoff.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF064E3B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Back to Driver Dashboard',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDispatchHelpModal(BuildContext context) {
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
              child: const Icon(
                Icons.support_agent_rounded,
                color: Color(0xFF065F46),
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Agri-Dispatch Hotline',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Direct line for corridor re-routing or crate issues.',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Dialing Dispatch Central Hotline...',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: const Color(0xFF064E3B),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.call, size: 18),
                label: const Text('Call Dispatch (1920)'),
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
}

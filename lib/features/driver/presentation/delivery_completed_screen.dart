import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/driver_firestore_service.dart';
import 'delivery_details_screen.dart';
import 'dropoff_photo_data.dart';

/// Pixel-perfect Delivery Completed Screen matching the user reference mockup.
/// Connected with Cloud Firestore for:
/// - READ (R): Fetch completed order payout breakdown & buyer rating
/// - UPDATE (U): Mark order as COMPLETED & settle driver wallet earnings
class DeliveryCompletedScreen extends StatefulWidget {
  final String? orderId;
  const DeliveryCompletedScreen({super.key, this.orderId});

  @override
  State<DeliveryCompletedScreen> createState() =>
      _DeliveryCompletedScreenState();
}

class _DeliveryCompletedScreenState extends State<DeliveryCompletedScreen> {
  final DriverFirestoreService _firestoreService = DriverFirestoreService();
  bool _isLoading = false;
  bool _isSubmitting = false;

  String _orderId = '#FH-8841';
  String _buyerName = 'Chaminda Perera';
  String _buyerAddress = 'Havelock Rd. Colombo 05';
  String _totalEarned = 'Rs. 1,450';
  String _baseTransit = 'Rs. 1,200';
  String _terrainBonus = '+Rs. 250';
  String _directTip = '+Rs. 200';
  String _dailyWalletTotal = 'Rs. 9,300';
  String _deliveryTime = 'Today, 3:15 PM';
  String _earlyBadge = '15 mins early ⚡';
  String _handoverType = 'Cash on Delivery';
  String _collectedAmount = 'Rs. 1,760 Collected & Pocketed';
  double _ratingStars = 5.0;

  @override
  void initState() {
    super.initState();
    if (widget.orderId != null && widget.orderId!.isNotEmpty) {
      _orderId = widget.orderId!;
    }
    if (_orderId.contains('8850')) {
      _buyerName = 'Dilani Jayawardena';
      _buyerAddress = 'No. 15, Station Road, Dehiwala';
      _totalEarned = 'Rs. 1,800';
      _baseTransit = 'Rs. 1,500';
      _terrainBonus = '+Rs. 300';
      _directTip = '+Rs. 250';
      _dailyWalletTotal = 'Rs. 9,650';
      _deliveryTime = 'Today, 4:10 PM';
      _earlyBadge = '20 mins early ⚡';
      _collectedAmount = 'Rs. 2,450 Collected & Pocketed';
    }
    _fetchCompletedDetails();
  }

  /// READ (R): Fetches completed delivery payout breakdown and buyer summary from Firestore
  Future<void> _fetchCompletedDetails() async {
    setState(() => _isLoading = true);
    try {
      final cleanId = _orderId.replaceAll('#', '').trim();
      final data = await _firestoreService.getCompletedDeliveryDetails(
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
                  : 'Havelock Rd. Colombo 05');
          _totalEarned = data['totalEarned'] ?? 'Rs. 1,450';
          _baseTransit = data['baseTransit'] ?? 'Rs. 1,200';
          _terrainBonus = data['terrainBonus'] ?? '+Rs. 250';
          _directTip = data['directTip'] ?? '+Rs. 200';
          _dailyWalletTotal = data['dailyWalletTotal'] ?? 'Rs. 9,300';
          _deliveryTime = data['deliveryTime'] ?? 'Today, 3:15 PM';
          _earlyBadge = data['earlyBadge'] ?? '15 mins early ⚡';
          _handoverType = data['handoverType'] ?? 'Cash on Delivery';
          _collectedAmount = data['collectedAmount'] ?? 'Rs. 1,760 Collected & Pocketed';
          _ratingStars = (data['ratingStars'] as num?)?.toDouble() ?? 5.0;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading completed details: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// UPDATE (U): Settles order completion and updates driver wallet in Firestore
  Future<void> _handleFinalizeAndTakeNextOrder() async {
    if (_isSubmitting) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    try {
      final cleanAmountStr = _totalEarned.replaceAll(RegExp(r'[^\d.]'), '');
      final payout = double.tryParse(cleanAmountStr) ?? 1450.0;

      await _firestoreService.finalizeDeliveryAndSettleEarnings(
        _orderId,
        payout,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Order $_orderId completed & Wallet settled (+Rs. ${payout.toInt()}) in DB (UPDATE)',
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

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const DeliveryDetailsScreen(
            orderId: 'FH-8850',
          ),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      debugPrint('Error finalizing order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to settle delivery: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Scrollable Completion Details
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchCompletedDetails,
              color: const Color(0xFF065F46),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  children: [
                    // 1. Delivery Completed Header & Drop-off Photo Card
                    _buildCompletedHeaderAndPhotoCard(context),
                    const SizedBox(height: 14),

                    // 2. Trip Payout Card (Light Mint Tint)
                    _buildTripPayoutCard(),
                    const SizedBox(height: 14),

                    // 3. Delivery Summary & Customer Rating Card
                    _buildDeliverySummaryCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Button: Back to Deliveries / Take Next Order ->
          _buildBottomActionButton(context),
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
          color: Color(0xFF1E293B),
          size: 22,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).maybePop();
        },
      ),
      actions: [
        // Driver Profile Circle Avatar
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFF065F46),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.person_rounded,
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

  // ── 1. Delivery Completed Header & Drop-off Photo Card ─────────────────────
  Widget _buildCompletedHeaderAndPhotoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Wiggling / Shaking Checkmark Badge with Celebration Pulse
          const _WigglingCheckmark(),
          const SizedBox(height: 14),

          // Title
          Text(
            'Delivery Completed!',
            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 3),

          // Subtitle
          Text(
            'Order $_orderId dropped off & confirmed',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),

          // Drop-off Verified Photo Banner using the user's high-resolution photo
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 165,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // High-resolution drop-off photo provided by user
                  Image.memory(
                    kDropoffPhotoBytes,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.25),
                  ),

                  // Bottom subtle gradient vignette
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.65),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Overlay Elements: Drop-off Photo Verified (Left) & Secure Handover (Right)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Camera Icon + Verified Text
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Drop-off photo verified',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Right: Secure Handover Pill Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF065F46),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            'Secure Handover',
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
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
    );
  }



  // ── 2. Trip Payout Card (Light Mint Tint) ──────────────────────────────────
  Widget _buildTripPayoutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FDF0), // Soft pastel mint
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Cash Icon + TRIP PAYOUT
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                color: Color(0xFF059669),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'TRIP PAYOUT',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF059669),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Total Earned Big Price Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _totalEarned,
                style: GoogleFonts.poppins(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF047857),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'total earned',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Inner White Breakdown Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Base Transit
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _orderId.contains('8850')
                              ? 'Base Transit (18.6 km)'
                              : 'Base Transit (14.2 km)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _baseTransit,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Highland Terrain Bonus
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.landscape_outlined,
                          size: 16,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Highland Terrain Bonus',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _terrainBonus,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Direct Tip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          size: 16,
                          color: Color(0xFF059669),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Direct Tip',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _directTip,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Daily Wallet Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: Color(0xFF475569),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Wallet Total',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              Text(
                _dailyWalletTotal,
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 3. Delivery Summary & Customer Rating Card ─────────────────────────────
  Widget _buildDeliverySummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Delivery Summary + ✓ Completed Pill Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Summary',
                style: GoogleFonts.poppins(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '✓ Completed',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Item 1: Delivered To
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF), // Light blue
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF3B82F6),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivered To',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _buyerName,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      _buyerAddress,
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
          const SizedBox(height: 14),

          // Item 2: Delivered At
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9), // Light grey
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.access_time_rounded,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivered At',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _deliveryTime.contains(',') ? '${_deliveryTime.split(',').first.trim()},' : 'Today,',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              _deliveryTime.contains(',') ? _deliveryTime.split(',').last.trim() : _deliveryTime,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        // 15 mins early pill badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _earlyBadge,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Item 3: Handover & Payment
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7), // Light amber
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.payments_rounded,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Handover & Payment',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _handoverType,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      _collectedAmount,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Item 4: Customer Rating Box (Soft Lavender/Purple Card)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF), // Soft purple/lavender
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                // Green Smiley Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.sentiment_very_satisfied_rounded,
                      color: Color(0xFF10B981),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Rating Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Rating',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Buyer rated instantly',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // 5 Gold Stars & 5.0 Star text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < _ratingStars.floor()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFFBBF24),
                          size: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_ratingStars.toStringAsFixed(1)} Star',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
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

  // ── Bottom Fixed Action Button ─────────────────────────────────────────────
  Widget _buildBottomActionButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleFinalizeAndTakeNextOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF065F46),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: _isSubmitting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Settling Wallet & Deliveries...',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Back to Deliveries / Take Next Order',
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Joyful Wiggling & Shaking Checkmark Badge with Pulse Aura
/// Celebrates successful delivery completion with periodic joyful wiggles and haptic tap response.
class _WigglingCheckmark extends StatefulWidget {
  const _WigglingCheckmark();

  @override
  State<_WigglingCheckmark> createState() => _WigglingCheckmarkState();
}

class _WigglingCheckmarkState extends State<_WigglingCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseWaveAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Scale animation: joyful spring bounce in the first 25% of cycle
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.88, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 68,
      ),
    ]).animate(_controller);

    // Rotation animation: playful shake/wiggle between 18% and 52% of cycle
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.22) // tilt left ~12.5 deg
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 6,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.22, end: 0.22) // tilt right ~12.5 deg
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 8,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.22, end: -0.12) // tilt left ~7 deg
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 7,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.12, end: 0.12) // tilt right ~7 deg
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 7,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.12, end: 0.0) // settle back to center
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 6,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0), // rest gracefully
        weight: 48,
      ),
    ]).animate(_controller);

    // Expanding celebration pulse wave
    _pulseWaveAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerJoyfulWiggle() {
    HapticFeedback.mediumImpact();
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerJoyfulWiggle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = _scaleAnimation.value;
          final rotation = _rotationAnimation.value;
          final pulseVal = _pulseWaveAnimation.value;
          final pulseAlpha = (1.0 - pulseVal).clamp(0.0, 1.0);
          final pulseRadius = 31 + (pulseVal * 18);

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Expanding celebration pulse aura ring
              Container(
                width: pulseRadius * 2,
                height: pulseRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981)
                      .withValues(alpha: pulseAlpha * 0.18),
                  border: Border.all(
                    color: const Color(0xFF059669)
                        .withValues(alpha: pulseAlpha * 0.45),
                    width: 1.5,
                  ),
                ),
              ),

              // Joyful Wiggling & Shaking Checkmark Badge
              Transform.scale(
                scale: scale,
                child: Transform.rotate(
                  angle: rotation,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Mint Green Circle with Checkmark Icon
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: const Color(0xFFA7F3D0), // Soft mint green
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF059669)
                                  .withValues(alpha: 0.22),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.done_all_rounded,
                            color: Color(0xFF047857),
                            size: 32,
                          ),
                        ),
                      ),

                      // Small brown camera badge at bottom-right corner
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF78350F), // Rich brown
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
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
}

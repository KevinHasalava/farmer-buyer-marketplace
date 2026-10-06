import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/delivery_order_model.dart';
import '../services/driver_firestore_service.dart';
import 'delivery_details_screen.dart';
import 'driver_chat_screen.dart';
import 'driver_profile_screen.dart';

/// Pixel-perfect "Assigned Deliveries" screen matching reference design.
/// Connected with Cloud Firestore for:
/// - READ (R): Query and load assigned orders according to filter chips
/// - UPDATE (U): Update order status when driver taps "Navigate to Farm"
class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  int _selectedFilterIndex = 0;
  final int _selectedNavIndex = 1; // Deliveries tab is active (index 1)

  final DriverFirestoreService _firestoreService = DriverFirestoreService();
  List<DeliveryOrderModel> _deliveries = [];
  bool _isLoading = false;
  bool _hasUnreadNotifications = true;

  List<String> get _filters {
    final totalCount = _deliveries.isNotEmpty ? _deliveries.length : 6;
    final readyCount = _deliveries.isNotEmpty
        ? _deliveries.where((d) => d.status == 'Ready for Pickup').length
        : 2;
    final transitCount = _deliveries.isNotEmpty
        ? _deliveries.where((d) => d.status == 'En Route to Pickup' || d.status == 'In Transit').length
        : 1;
    return [
      'All ($totalCount)',
      'Ready for Pickup ($readyCount)',
      'In Transit ($transitCount)',
    ];
  }

  @override
  void initState() {
    super.initState();
    _fetchDeliveries();
  }

  /// READ (R): Fetches assigned deliveries from Cloud Firestore
  Future<void> _fetchDeliveries() async {
    setState(() => _isLoading = true);
    try {
      final list = await _firestoreService.getAssignedDeliveries();
      if (mounted) {
        setState(() {
          _deliveries = list;
          // Ensure both orders are always present in the active list
          if (!_deliveries.any((d) => d.id == 'FH-8841' || d.orderNumber.contains('8841'))) {
            _deliveries.insert(0, _order1);
          }
          if (!_deliveries.any((d) => d.id == 'FH-8850' || d.orderNumber.contains('8850'))) {
            _deliveries.add(_order2);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching deliveries from Firestore: $e');
      if (mounted) {
        setState(() {
          if (!_deliveries.any((d) => d.id == 'FH-8841' || d.orderNumber.contains('8841'))) {
            _deliveries.insert(0, _order1);
          }
          if (!_deliveries.any((d) => d.id == 'FH-8850' || d.orderNumber.contains('8850'))) {
            _deliveries.add(_order2);
          }
          _isLoading = false;
        });
      }
    }
  }

  DeliveryOrderModel get _order1 {
    return _deliveries.firstWhere(
      (o) => o.id == 'FH-8841' || o.orderNumber.contains('8841'),
      orElse: () => DeliveryOrderModel(
        id: 'FH-8841',
        orderNumber: '#FH-8841',
        status: 'Ready for Pickup',
        crateCount: '1 Crate',
        pickupDueText: 'Pickup Due in 20m',
        farmerName: 'K. M. Bandara',
        farmerAddress: 'Farm Gate North #2, Nuwara Eliya',
        buyerName: 'Chaminda Perera',
        buyerAddress: 'No. 42 Havelock Rd, Colombo 05',
        produceDescription: '5 kg (Carrots & Leeks)',
        producePackageType: 'Cool storage packed',
        driverFee: 1450.0,
        isPriority: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  DeliveryOrderModel get _order2 {
    return _deliveries.firstWhere(
      (o) => o.id == 'FH-8850' || o.orderNumber.contains('8850'),
      orElse: () => DeliveryOrderModel(
        id: 'FH-8850',
        orderNumber: '#FH-8850',
        status: 'Ready for Pickup',
        crateCount: '2 Crates',
        pickupDueText: 'Pickup Due in 45m',
        farmerName: 'Sunil Perera',
        farmerAddress: 'Welimada Main Collection Depot',
        buyerName: 'Dilani Jayawardena',
        buyerAddress: 'Dehiwala Urban Center',
        produceDescription: '12 kg (Tomatoes & Cabbages)',
        producePackageType: 'Strap secured',
        driverFee: 1800.0,
        isPriority: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  bool _matchesFilter(DeliveryOrderModel order) {
    if (_selectedFilterIndex == 0) return true; // All
    if (_selectedFilterIndex == 1) return order.status == 'Ready for Pickup';
    if (_selectedFilterIndex == 2) {
      return order.status == 'En Route to Pickup' || order.status == 'In Transit';
    }
    return true;
  }

  /// UPDATE (U): Updates order status for any delivery order in Cloud Firestore
  Future<void> _updateOrderStatus(DeliveryOrderModel order) async {
    final cleanId = order.id.replaceAll('#', '').trim();
    final newStatus = order.status == 'Ready for Pickup'
        ? 'En Route to Pickup'
        : 'In Transit';

    // 1. Instantly update local state for zero-latency UI transition
    if (mounted) {
      setState(() {
        final idx = _deliveries.indexWhere(
          (d) => d.id == cleanId || d.orderNumber.contains(cleanId),
        );
        final updatedOrder = order.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        if (idx != -1) {
          _deliveries[idx] = updatedOrder;
        } else {
          _deliveries.add(updatedOrder);
        }
      });
    }

    try {
      // 2. Persist update in Cloud Firestore (UPDATE - U)
      await _firestoreService.updateDeliveryStatus(cleanId, newStatus);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Order #$cleanId status updated to "$newStatus" in Firestore (UPDATE)',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF064E3B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // Re-fetch to synchronize state live (READ - R)
      await _fetchDeliveries();
    } catch (e) {
      debugPrint('Error updating delivery status: $e');
    }
  }

  /// UPDATE (U): Updates order status to 'En Route to Pickup' in Cloud Firestore
  Future<void> _updateOrder1ToEnRoute() async {
    await _updateOrderStatus(_order1);
  }

  /// UPDATE (U): Updates order 2 status to 'En Route to Pickup' in Cloud Firestore
  Future<void> _updateOrder2ToEnRoute() async {
    await _updateOrderStatus(_order2);
  }

  /// Reset demo deliveries so Order 1 is In Transit and Order 2 is Ready for Pickup
  Future<void> _resetDemoDeliveries() async {
    setState(() => _isLoading = true);
    try {
      await _firestoreService.updateDeliveryStatus('FH-8841', 'En Route to Pickup');
      await _firestoreService.updateDeliveryStatus('FH-8850', 'Ready for Pickup');
      await _fetchDeliveries();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Manifest reset: #FH-8850 is "Ready for Pickup" & #FH-8841 is "In Transit"',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF064E3B),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error resetting demo deliveries: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showOrder1 = _matchesFilter(_order1);
    final showOrder2 = _matchesFilter(_order2);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: ACTIVE MANIFEST + Assigned Deliveries
                    _buildHeaderSection(),
                    const SizedBox(height: 12),

                    // OPTIMIZED ROUTE: Highland Express Corridor Banner
                    _buildOptimizedRouteBanner(),
                    const SizedBox(height: 14),

                    // Filter Pills: All (6), Ready for Pickup (2), In Transit (1)
                    _buildFilterPills(),
                    const SizedBox(height: 14),

                    // Order Card 1: #FH-8841 (Active Priority Card with Green Border)
                    if (showOrder1) ...[
                      _buildOrderCard1(),
                      const SizedBox(height: 14),
                    ],

                    // Order Card 2: #FH-8850 (Sunil Perera -> Dilani Jayawardena)
                    if (showOrder2) ...[
                      _buildOrderCard2(),
                      const SizedBox(height: 14),
                    ],

                    // If neither matches the active filter
                    if (!showOrder1 && !showOrder2) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 36, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 10),
                            Text(
                              'No deliveries currently ${_selectedFilterIndex == 1 ? "Ready for Pickup" : "In Transit"}',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Today's Potential Earnings Banner
                    _buildPotentialEarningsBanner(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar with Deliveries Active
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // ── Top App Bar ────────────────────────────────────────────────────────────
  Widget _buildTopAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // App Logo Icon Box
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF006B44),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.home_filled,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Brand Name
          Text(
            'Farm2Home',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 8),

          // DRIVER Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'DRIVER',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF065F46),
                letterSpacing: 0.5,
              ),
            ),
          ),

          const Spacer(),

          // Notification Bell with Badge
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              _showNotificationDialog();
            },
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF475569),
                    size: 24,
                  ),
                ),
                if (_hasUnreadNotifications)
                  Positioned(
                    top: 5,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
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

  // ── Header: ACTIVE MANIFEST + Assigned Deliveries ──────────────────────────
  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACTIVE MANIFEST',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF047857),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Assigned Deliveries',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),

        // Quick Reset Demo Button
        InkWell(
          onTap: () async {
            HapticFeedback.lightImpact();
            await _resetDemoDeliveries();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFF475569)),
                const SizedBox(width: 4),
                Text(
                  'Reset Demo',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── OPTIMIZED ROUTE: Highland Express Corridor Banner ──────────────────────
  Widget _buildOptimizedRouteBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCFCE7), width: 1),
      ),
      child: Row(
        children: [
          // Green square with route icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF006B44),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.alt_route_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Route Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'OPTIMIZED ROUTE',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Save 38 mins',
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  'Highland Express Corridor',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Nuwara Eliya → Kandy → Colombo',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Pills: All (6), Ready for Pickup (2), In Transit (1) ────────────
  Widget _buildFilterPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF064E3B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF064E3B) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Text(
                  _filters[index],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Order Card 1: #FH-8841 (Active Priority Card with Green Border) ────────
  Widget _buildOrderCard1() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFA7F3D0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF047857).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: #FH-8841 + 1 Crate | Pickup Due in 20m
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '#FH-8841',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7EF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                    ),
                    child: Text(
                      '1 Crate',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),

              // Pickup Due in 20m / En Route to Pickup Badge (Dynamic from Firestore)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: _order1.status == 'En Route to Pickup'
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _order1.status == 'En Route to Pickup'
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFDE68A),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _order1.status == 'En Route to Pickup'
                          ? Icons.navigation_rounded
                          : Icons.access_time_rounded,
                      size: 12,
                      color: _order1.status == 'En Route to Pickup'
                          ? const Color(0xFF047857)
                          : const Color(0xFFB45309),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _order1.status == 'En Route to Pickup'
                          ? 'En Route to Pickup'
                          : _order1.pickupDueText,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _order1.status == 'En Route to Pickup'
                            ? const Color(0xFF047857)
                            : const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Route Timeline: K. M. Bandara -> Chaminda Perera
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon & Dotted Line Column
              Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.location_on,
                        color: Color(0xFF059669),
                        size: 13,
                      ),
                    ),
                  ),
                  Container(
                    width: 1.5,
                    height: 24,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDBEAFE),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.priority_high_rounded,
                        color: Color(0xFF2563EB),
                        size: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              // Text details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Farmer Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'K. M. Bandara',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Farm Gate North #2, Nuwara Eliya',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Hakgala Valley Farm',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Buyer Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chaminda Perera',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'No. 42 Havelock Rd, Colombo 05',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Drop-off',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Produce & Driver Fee Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '5 kg (Carrots & Leeks)',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Cool storage packed',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Driver Fee',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      'Rs. 1,450',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons: Navigate to Farm + Details
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      // UPDATE (U): Updates delivery status in Cloud Firestore
                      await _updateOrder1ToEnRoute();
                      if (!mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DeliveryDetailsScreen(orderId: _order1.orderNumber),
                        ),
                      );
                    },
                    icon: Icon(
                      _order1.status == 'En Route to Pickup'
                          ? Icons.navigation_rounded
                          : Icons.near_me_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Navigate to Farm',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF064E3B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 42,
                width: 80,
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DeliveryDetailsScreen(orderId: _order1.orderNumber),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Details',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Order Card 2: #FH-8850 (Sunil Perera -> Dilani Jayawardena) ────────────
  Widget _buildOrderCard2() {
    final isOrder2InTransit = _order2.status == 'En Route to Pickup' || _order2.status == 'In Transit';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOrder2InTransit ? const Color(0xFFA7F3D0) : const Color(0xFFF1F5F9),
          width: isOrder2InTransit ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOrder2InTransit ? const Color(0xFF047857) : Colors.black)
                .withValues(alpha: isOrder2InTransit ? 0.04 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: #FH-8850 + 2 Crates | Pickup Due in 45m
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '#FH-8850',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
                    ),
                    child: Text(
                      '2 Crates',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4338CA),
                      ),
                    ),
                  ),
                ],
              ),

              // Pickup Due in 45m / En Route to Pickup Badge (Dynamic from Firestore)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isOrder2InTransit
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isOrder2InTransit
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOrder2InTransit
                          ? Icons.navigation_rounded
                          : Icons.access_time_rounded,
                      size: 12,
                      color: isOrder2InTransit
                          ? const Color(0xFF047857)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOrder2InTransit ? _order2.status : 'Pickup Due in 45m',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isOrder2InTransit
                            ? const Color(0xFF047857)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Route Timeline: Sunil Perera -> Dilani Jayawardena
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dots Column
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF059669),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 1.5,
                    height: 32,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Text details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Farmer Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sunil Perera',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Welimada Main Collection Depot',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Welimada Hub',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Buyer Details
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dilani Jayawardena',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Dehiwala Urban Center',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Drop-off',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Produce & Driver Fee Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '12 kg (Tomatoes & Cabbages)',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Strap secured',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Driver Fee',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      'Rs. 1,800',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons: Navigate to Farm + Details
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      // UPDATE (U): Updates delivery status in Cloud Firestore
                      await _updateOrder2ToEnRoute();
                      if (!mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DeliveryDetailsScreen(orderId: _order2.orderNumber),
                        ),
                      );
                    },
                    icon: Icon(
                      isOrder2InTransit
                          ? Icons.navigation_rounded
                          : Icons.near_me_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Navigate to Farm',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF064E3B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 42,
                width: 80,
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DeliveryDetailsScreen(orderId: _order2.orderNumber),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Details',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Today's Potential Earnings Banner ──────────────────────────────────────
  Widget _buildPotentialEarningsBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F7EF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF006B44),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.payments_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Text details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Potential Earnings",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                    children: const [
                      TextSpan(
                        text: 'Rs. 4,200 ',
                        style: TextStyle(
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: 'total from current trips'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chevron Right
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF64748B),
            size: 22,
          ),
        ],
      ),
    );
  }

  // ── Bottom Navigation Bar (Deliveries Tab is Active) ───────────────────────
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
            onTap: () {
              Navigator.of(context).maybePop();
            },
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.inventory_2_outlined,
            label: 'Deliveries',
            onTap: () {},
          ),
          _buildNavItem(
            index: 2,
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DriverChatScreen(),
                ),
              );
            },
          ),
          _buildNavItem(
            index: 3,
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DriverProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedNavIndex == index;
    const activeColor = Color(0xFF065F46);
    const inactiveColor = Color(0xFF94A3B8);

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 3),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Dialogs & Sheets ───────────────────────────────────────────────────────

  void _showNotificationDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag pill
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
                const SizedBox(height: 16),

                // Header Row
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.assignment_outlined,
                          color: Color(0xFF047857),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manifest & Dispatch Alerts',
                            style: GoogleFonts.poppins(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Pickup run sequencing & cargo verification',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_hasUnreadNotifications)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '2 NEW',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Notifications List
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildManifestAlertTile(
                        icon: Icons.alt_route_rounded,
                        iconColor: const Color(0xFF059669),
                        iconBg: const Color(0xFFD1FAE5),
                        title: 'Optimized Stop Sequence',
                        message: 'Route scheduled: Stop 1 Hakgala Farm Gate #2 (Bandara), Stop 2 Welimada Main Depot (Sunil).',
                        time: '10m ago',
                        badge: 'Manifest',
                        badgeColor: const Color(0xFF047857),
                        badgeBg: const Color(0xFFDCFCE7),
                        isUnread: true,
                        onTap: () {
                          Navigator.pop(ctx);
                        },
                      ),
                      _buildManifestAlertTile(
                        icon: Icons.mark_chat_unread_outlined,
                        iconColor: const Color(0xFF0284C7),
                        iconBg: const Color(0xFFE0F2FE),
                        title: 'Buyer Instruction • Chaminda',
                        message: 'Drop-off note: "Ring doorbell twice, keep produce in shade at 42 Havelock Rd."',
                        time: '20m ago',
                        badge: 'Buyer Note',
                        badgeColor: const Color(0xFF0369A1),
                        badgeBg: const Color(0xFFE0F2FE),
                        isUnread: true,
                        onTap: () {
                          Navigator.pop(ctx);
                        },
                      ),
                      _buildManifestAlertTile(
                        icon: Icons.payments_outlined,
                        iconColor: const Color(0xFF7C3AED),
                        iconBg: const Color(0xFFF3E8FF),
                        title: 'Cash Collection Summary',
                        message: 'COD expected on arrival: Rs. 1,760 for Order #FH-8841 and Rs. 2,450 for Order #FH-8850.',
                        time: '45m ago',
                        badge: 'COD Cash',
                        badgeColor: const Color(0xFF6B21A8),
                        badgeBg: const Color(0xFFF3E8FF),
                        isUnread: false,
                        onTap: () {
                          Navigator.pop(ctx);
                        },
                      ),
                      _buildManifestAlertTile(
                        icon: Icons.cloud_done_rounded,
                        iconColor: const Color(0xFF0D9488),
                        iconBg: const Color(0xFFCCFBF1),
                        title: 'Cloud Manifest Synced',
                        message: 'Both active orders verified and synced with Central Logistics Hub database.',
                        time: '1h ago',
                        badge: 'Database Synced',
                        badgeColor: const Color(0xFF0F766E),
                        badgeBg: const Color(0xFFCCFBF1),
                        isUnread: false,
                        onTap: () {
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Bottom button: Mark all as read / Dismiss
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasUnreadNotifications = false;
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF064E3B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _hasUnreadNotifications ? 'Mark All as Read' : 'Close Notifications',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildManifestAlertTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String message,
    required String time,
    required String badge,
    required Color badgeColor,
    required Color badgeBg,
    required bool isUnread,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFF9FDFB) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread ? const Color(0xFFA7F3D0) : const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 7,
                              height: 7,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF059669),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        message,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: const Color(0xFF475569),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: badgeColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            time,
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCallDialog(String person, String phone) {
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
                color: Color(0xFFE6F7EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_in_talk, color: Color(0xFF065F46), size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              'Call $person',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              phone,
              style: GoogleFonts.poppins(
                fontSize: 13,
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
                      content: Text('Dialing $person ($phone)...'),
                      backgroundColor: const Color(0xFF064E3B),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.call, size: 18),
                label: const Text('Call Now'),
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

  void _showOrderSummarySheet(DeliveryOrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
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
                Text(
                  'Order #${order.orderNumber.replaceAll('#', '')} Details',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF047857),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Farmer (Pickup) & Buyer (Drop-off) Container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  // Farmer Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF7ED),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.storefront_outlined, color: Color(0xFFEA580C), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Farmer (Pickup Location)',
                              style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                            ),
                            Text(
                              order.farmerName,
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                            ),
                            Text(
                              order.farmerAddress,
                              style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 10),

                  // Buyer Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on_outlined, color: Color(0xFF2563EB), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buyer (Drop-off Destination)',
                              style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
                            ),
                            Text(
                              order.buyerName,
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
                            ),
                            Text(
                              order.buyerAddress,
                              style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Cargo & Payout Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cargo', style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                        Text(order.produceDescription, style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(order.crateCount, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8FDF0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Driver Payout', style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF059669), fontWeight: FontWeight.w600)),
                        Text('Rs. ${order.driverFee.toInt()}', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFF065F46))),
                        Text('Net Settlement', style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF059669))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        if (order.status == 'Ready for Pickup') {
                          await _updateOrderStatus(order);
                        }
                        if (!mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                DeliveryDetailsScreen(orderId: order.orderNumber),
                          ),
                        );
                      },
                      icon: const Icon(Icons.near_me_outlined, size: 16),
                      label: Text(
                        'Open Delivery Details',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF064E3B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

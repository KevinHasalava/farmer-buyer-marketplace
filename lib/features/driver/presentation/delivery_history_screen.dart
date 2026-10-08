import 'package:flutter/material.dart';
import '../../../core/localization/app_settings.dart';
import 'package:flutter/services.dart';

import '../services/driver_firestore_service.dart';
import 'deliveries_screen.dart';
import 'driver_dashboard_screen.dart';
import 'driver_profile_screen.dart';

/// Pixel-perfect Delivery History Screen matching reference mockup.
///
/// Features:
/// 1. Top App Bar with Farm2Home logo & DRIVER badge
/// 2. Header with "Delivery History", "Verified Driver" badge & completed trips count
/// 3. 3-Card Summary Stats (Trips Made, On-Time %, Earnings)
/// 4. Interactive Time Filter Pills: [This Week, Last Week, This Month]
/// 5. Completed Trips List Cards (#FH-8841, #FH-8839, #FH-8812, #FH-8790)
///    with Pickup, Drop, Cargo, Time and compensation amount
/// 6. 100% Farm Fresh Assured Banner
/// 7. "Download Tax & Payment Statement (PDF)" button generating an official statement
/// 8. Bottom Navigation Bar synced with the rest of the Driver features
class DeliveryHistoryScreen extends StatefulWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  State<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends State<DeliveryHistoryScreen> {
  final DriverFirestoreService _firestoreService = DriverFirestoreService();
  bool _isLoading = false;

  // Filter Selection: 0 = This Week, 1 = Last Week, 2 = This Month
  int _selectedFilterIndex = 0;

  // Filter Data Sets
  final List<_HistoryPeriodData> _periods = [
    _HistoryPeriodData(
      label: 'This Week',
      tripsCount: 28,
      onTimeRate: '99.2%',
      earnings: 'Rs. 38.4k',
      trips: [
        _TripItem(
          orderId: 'FH-8841',
          pickupLocation: 'Hakgala Farm, Nuwara Eliya',
          dropLocation: 'Colombo 05 (Havelock Rd)',
          cargo: '5 kg Fresh Produce (Carrots, Leeks)',
          time: 'Today, 3:15 PM',
          amount: 'Rs. 1,450',
          cargoIcon: Icons.inventory_2_outlined,
        ),
        _TripItem(
          orderId: 'FH-8839',
          pickupLocation: 'Nuwara Eliya Cold Hub',
          dropLocation: 'Kandy Central Co-Op',
          cargo: '5 kg Highland Potatoes',
          time: 'Today, 11:30 AM',
          amount: 'Rs. 1,200',
          cargoIcon: Icons.grass_rounded,
        ),
        _TripItem(
          orderId: 'FH-8812',
          pickupLocation: 'Dambulla Dedicated Market',
          dropLocation: 'Colombo 07 (Cinnamon Gardens)',
          cargo: '15 kg Fresh Tomatoes',
          time: 'Yesterday, 4:20 PM',
          amount: 'Rs. 2,100',
          cargoIcon: Icons.eco_rounded,
        ),
        _TripItem(
          orderId: 'FH-8790',
          pickupLocation: 'Welimada Organic Terrace',
          dropLocation: 'Dehiwala Residential',
          cargo: '10 kg Organic Cabbage',
          time: '24 Oct, 2:00 PM',
          amount: 'Rs. 1,650',
          cargoIcon: Icons.spa_rounded,
        ),
      ],
    ),
    _HistoryPeriodData(
      label: 'Last Week',
      tripsCount: 34,
      onTimeRate: '98.8%',
      earnings: 'Rs. 46.2k',
      trips: [
        _TripItem(
          orderId: 'FH-8755',
          pickupLocation: 'Bandarawela Tea & Veg Hub',
          dropLocation: 'Nugegoda Super Center',
          cargo: '20 kg Fresh Carrots & Leeks',
          time: '18 Oct, 4:10 PM',
          amount: 'Rs. 2,350',
          cargoIcon: Icons.inventory_2_outlined,
        ),
        _TripItem(
          orderId: 'FH-8740',
          pickupLocation: 'Hakgala Organic Plots',
          dropLocation: 'Battaramulla Urban Mart',
          cargo: '12 kg Bell Peppers & Salad Greens',
          time: '17 Oct, 1:20 PM',
          amount: 'Rs. 1,850',
          cargoIcon: Icons.eco_rounded,
        ),
        _TripItem(
          orderId: 'FH-8712',
          pickupLocation: 'Nuwara Eliya Gate 3',
          dropLocation: 'Rajagiriya Residences',
          cargo: '8 kg Strawberries & Radish',
          time: '15 Oct, 11:00 AM',
          amount: 'Rs. 1,900',
          cargoIcon: Icons.grass_rounded,
        ),
        _TripItem(
          orderId: 'FH-8690',
          pickupLocation: 'Ragala Cold Transport Hub',
          dropLocation: 'Colombo 03 (Colpetty)',
          cargo: '25 kg Mixed Highland Produce',
          time: '14 Oct, 9:45 AM',
          amount: 'Rs. 2,600',
          cargoIcon: Icons.spa_rounded,
        ),
      ],
    ),
    _HistoryPeriodData(
      label: 'This Month',
      tripsCount: 112,
      onTimeRate: '99.4%',
      earnings: 'Rs. 154.8k',
      trips: [
        _TripItem(
          orderId: 'FH-8841',
          pickupLocation: 'Hakgala Farm, Nuwara Eliya',
          dropLocation: 'Colombo 05 (Havelock Rd)',
          cargo: '5 kg Fresh Produce (Carrots, Leeks)',
          time: 'Today, 3:15 PM',
          amount: 'Rs. 1,450',
          cargoIcon: Icons.inventory_2_outlined,
        ),
        _TripItem(
          orderId: 'FH-8812',
          pickupLocation: 'Dambulla Dedicated Market',
          dropLocation: 'Colombo 07 (Cinnamon Gardens)',
          cargo: '15 kg Fresh Tomatoes',
          time: 'Yesterday, 4:20 PM',
          amount: 'Rs. 2,100',
          cargoIcon: Icons.eco_rounded,
        ),
        _TripItem(
          orderId: 'FH-8755',
          pickupLocation: 'Bandarawela Tea & Veg Hub',
          dropLocation: 'Nugegoda Super Center',
          cargo: '20 kg Fresh Carrots & Leeks',
          time: '18 Oct, 4:10 PM',
          amount: 'Rs. 2,350',
          cargoIcon: Icons.grass_rounded,
        ),
        _TripItem(
          orderId: 'FH-8620',
          pickupLocation: 'Keppetipola Agro Center',
          dropLocation: 'Moratuwa Distribution Point',
          cargo: '30 kg Bulk Cabbage & Beets',
          time: '08 Oct, 10:15 AM',
          amount: 'Rs. 3,100',
          cargoIcon: Icons.spa_rounded,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchHistoryForPeriod(_selectedFilterIndex);
  }

  /// READ (R): Fetches completed trips and period KPI statistics from Cloud Firestore
  Future<void> _fetchHistoryForPeriod(int index) async {
    final periodLabel = _periods[index].label;
    setState(() => _isLoading = true);
    try {
      final data = await _firestoreService.getDeliveryHistory(period: periodLabel);
      final rawTrips = data['trips'] as List<dynamic>? ?? [];

      if (rawTrips.isNotEmpty) {
        final List<_TripItem> mappedTrips = rawTrips.map((raw) {
          final t = raw as Map<String, dynamic>;
          IconData icon = Icons.inventory_2_outlined;
          final iconType = t['iconType'] as String? ?? '';
          if (iconType == 'grass') {
            icon = Icons.grass_rounded;
          } else if (iconType == 'eco') {
            icon = Icons.eco_rounded;
          } else if (iconType == 'spa') {
            icon = Icons.spa_rounded;
          }

          return _TripItem(
            orderId: (t['orderId'] as String? ?? 'FH-8841').replaceAll('#', ''),
            pickupLocation: t['pickupLocation'] as String? ?? 'Hakgala Farm, Nuwara Eliya',
            dropLocation: t['dropLocation'] as String? ?? 'Colombo 05 (Havelock Rd)',
            cargo: t['cargo'] as String? ?? '5 kg Fresh Produce',
            time: t['time'] as String? ?? 'Today, 3:15 PM',
            amount: t['amount'] as String? ?? 'Rs. 1,450',
            cargoIcon: icon,
          );
        }).toList();

        if (mounted) {
          setState(() {
            _periods[index] = _HistoryPeriodData(
              label: periodLabel,
              tripsCount: mappedTrips.length,
              onTimeRate: data['onTimeRate'] as String? ?? _periods[index].onTimeRate,
              earnings: data['earnings'] as String? ?? _periods[index].earnings,
              trips: mappedTrips,
            );
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching history from Firestore: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// DELETE (D): Confirms and removes/archives a trip from Cloud Firestore
  Future<void> _confirmDeleteTrip(_TripItem item) async {
    HapticFeedback.lightImpact();
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Color(0xFFDC2626),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.tr.removeTripRecord,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          context.tr.removeTripRecordDesc(item.orderId),
          style: TextStyle(
            fontSize: 12.5,
            color: const Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              context.tr.cancel,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              context.tr.removeRecord,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _deleteTrip(item);
    }
  }

  Future<void> _deleteTrip(_TripItem item) async {
    HapticFeedback.mediumImpact();
    try {
      await _firestoreService.deleteDeliveryHistoryItem(item.orderId);

      if (mounted) {
        setState(() {
          final currentPeriod = _periods[_selectedFilterIndex];
          currentPeriod.trips.removeWhere((t) => t.orderId == item.orderId);
          if (currentPeriod.tripsCount > 0) {
            currentPeriod.tripsCount--;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Trip #${item.orderId} removed from history in DB (DELETE)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
      debugPrint('Error deleting trip from Firestore: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove trip: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPeriod = _periods[_selectedFilterIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: _buildTopAppBar(context),
      body: Column(
        children: [
          // Scrollable History Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _fetchHistoryForPeriod(_selectedFilterIndex),
              color: const Color(0xFF064E3B),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header: Delivery History, Verified Driver badge & Completed count
                    _buildHeaderSection(),
                    const SizedBox(height: 14),

                    // 2. 3-Card Summary Stats: Trips Made, On-Time %, Earnings
                    _buildStatsRow(currentPeriod),
                    const SizedBox(height: 14),

                    // 3. Time Filter Pills: This Week, Last Week, This Month
                    _buildFilterPills(),
                    const SizedBox(height: 16),

                    // 4. Completed Trips Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr.completedTrips,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          context.tr.recentShown(currentPeriod.trips.length),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 5. Completed Trips Cards List
                    currentPeriod.trips.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 36,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.history_toggle_off_rounded,
                                  size: 40,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  context.tr.noTripsInPeriod,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.tr.recordsArchivedOrRemoved,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: currentPeriod.trips.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, idx) {
                              return _buildTripCard(currentPeriod.trips[idx]);
                            },
                          ),
                    const SizedBox(height: 16),

                    // 6. 100% Farm Fresh Assured Banner
                    _buildAssuranceBanner(),
                    const SizedBox(height: 16),

                    // 7. Download Tax & Payment Statement (PDF) Button
                    _buildDownloadPdfButton(context, currentPeriod),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Navigation Bar
          _buildBottomNavBar(context),
        ],
      ),
    );
  }

  // ── Top App Bar ────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildTopAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          // Green Brand Icon Container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF006B44),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.home_filled,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 9),

          // Brand Name
          Text(
            'Farm2Home',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 8),

          // DRIVER Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              context.tr.roleDriverTag,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF047857),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.close_rounded,
            color: Color(0xFF64748B),
            size: 24,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).maybePop();
          },
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

  // ── 1. Header: Delivery History & Verified Driver Badge ────────────────────
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              context.tr.deliveryHistory,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF047857),
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.tr.verifiedDriver,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF047857),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              size: 14,
              color: Color(0xFFEA580C),
            ),
            const SizedBox(width: 5),
            Text(
              context.tr.completedTripsSriLanka(142),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 2. 3-Card Summary Stats Row ────────────────────────────────────────────
  Widget _buildStatsRow(_HistoryPeriodData data) {
    return Row(
      children: [
        // Trips Made Card
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_rounded,
            iconBg: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF059669),
            value: '${data.tripsCount}',
            label: context.tr.tripsMade,
          ),
        ),
        const SizedBox(width: 10),

        // On-Time % Card
        Expanded(
          child: _buildStatCard(
            icon: Icons.timelapse_rounded,
            iconBg: const Color(0xFFEDFAF3),
            iconColor: const Color(0xFF059669),
            value: data.onTimeRate,
            label: context.tr.onTimeRate,
          ),
        ),
        const SizedBox(width: 10),

        // Earnings Card
        Expanded(
          child: _buildStatCard(
            icon: Icons.receipt_long_rounded,
            iconBg: const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFEA580C),
            value: data.earnings,
            label: context.tr.navEarnings,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 17),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  String _localizedPeriodLabel(BuildContext context, String label) {
    if (label.contains('Week') && label.contains('This')) return context.tr.thisWeek;
    if (label.contains('Week') && label.contains('Last')) return context.tr.lastWeek;
    if (label.contains('Month')) return context.tr.thisMonth;
    return label;
  }

  // ── 3. Time Filter Pills Row ───────────────────────────────────────────────
  Widget _buildFilterPills() {
    return Row(
      children: List.generate(_periods.length, (idx) {
        final isSelected = _selectedFilterIndex == idx;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedFilterIndex = idx;
              });
              _fetchHistoryForPeriod(idx);
            },
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF064E3B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF064E3B) : const Color(0xFFCBD5E1),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF064E3B).withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _localizedPeriodLabel(context, _periods[idx].label),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 5),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFFA7F3D0),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── 5. Completed Trip Card Item ────────────────────────────────────────────
  Widget _buildTripCard(_TripItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID, Completed Status Pill & Amount
          Row(
            children: [
              Text(
                '#${item.orderId}',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF047857),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.tr.statusDelivered,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '+${item.amount.trAuto(context)}',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF047857),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _confirmDeleteTrip(item),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFF94A3B8),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pickup Location Row
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFEA580C), // Orange
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.pickupLocation.trAuto(context),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              Text(
                context.tr.pickup,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Drop Location Row
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF059669), // Green
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.dropLocation.trAuto(context),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              Text(
                context.tr.drop,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Cargo Breakdown & Timestamp with Arrow
          Row(
            children: [
              Icon(
                item.cargoIcon,
                size: 14,
                color: const Color(0xFFB45309),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.cargo.trAuto(context),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.time.trAuto(context),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 6. 100% Farm Fresh Assured Banner ──────────────────────────────────────
  Widget _buildAssuranceBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.verified_user_rounded,
                color: Color(0xFF047857),
                size: 17,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr.farmFreshAssured,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr.farmFreshAssuredSub,
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 7. Download Tax & Payment Statement Button ──────────────────────────────
  Widget _buildDownloadPdfButton(BuildContext context, _HistoryPeriodData currentPeriod) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showPdfStatementPreviewModal(context, currentPeriod);
        },
        icon: const Icon(
          Icons.description_outlined,
          size: 18,
          color: Colors.white,
        ),
        label: Text(
          context.tr.downloadTaxPdf,
          style: TextStyle(
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
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ── PDF Statement Modal & Download Simulation ──────────────────────────────
  void _showPdfStatementPreviewModal(BuildContext context, _HistoryPeriodData period) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(context).size.height * 0.90,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Drag Bar
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Top Header: Title & Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Color(0xFFDC2626),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tax & Payment Statement'.trAuto(context),
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '${_localizedPeriodLabel(context, period.label)} ${'Summary'.trAuto(context)} • PDF',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFF1F5F9)),

            // Realistic PDF Paper View
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PDF Letterhead
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF006B44),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.home_filled, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Farm2Home Logistics',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Agri-Transit Sri Lanka Ltd.'.trAuto(context),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'OFFICIAL STATEMENT'.trAuto(context),
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF047857),
                                    letterSpacing: 0.5,
                                  ),
                              ),
                              Text(
                                '#STMT-2026-LK',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24, thickness: 1.5, color: Color(0xFF064E3B)),

                      // Driver & Period Details Table
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DRIVER DETAILS'.trAuto(context), style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))),
                              const SizedBox(height: 2),
                              Text('Ranjith Subha Udhasanak'.trAuto(context), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              Text('Vehicle: WP NC-4982 (Cooled Agro)'.trAuto(context), style: TextStyle(fontSize: 11, color: const Color(0xFF475569))),
                              Text('Bank: Commercial Bank LK (****4198)'.trAuto(context), style: TextStyle(fontSize: 11, color: const Color(0xFF475569))),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('STATEMENT PERIOD'.trAuto(context), style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))),
                              const SizedBox(height: 2),
                              Text(_localizedPeriodLabel(context, period.label), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF064E3B))),
                              Text('Generated: 01 Oct 2026'.trAuto(context), style: TextStyle(fontSize: 11, color: const Color(0xFF475569))),
                              Text('Status: Dispatched & Cleared ✓'.trAuto(context), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF047857))),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Itemized Table of Completed Deliveries
                      Text('ITEMIZED TRANSIT LOGS'.trAuto(context), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF64748B), letterSpacing: 0.5)),
                      const SizedBox(height: 8),

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              color: const Color(0xFFF8FAFC),
                              child: Row(
                                children: [
                                  Expanded(flex: 3, child: Text('Order'.trAuto(context), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
                                  Expanded(flex: 5, child: Text('Corridor Route'.trAuto(context), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
                                  Expanded(flex: 3, child: Text('Net Pay'.trAuto(context), textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            ...period.trips.map((t) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text('#${t.orderId}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          '${t.pickupLocation.split(',').first.trAuto(context)} → ${t.dropLocation.split('(').first.trAuto(context)}',
                                          style: TextStyle(fontSize: 10.5, color: const Color(0xFF334155)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          t.amount.trAuto(context),
                                          textAlign: TextAlign.right,
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF047857)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Financial Summary Table
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Column(
                          children: [
                            _buildPdfSummaryRow('Total Trips Completed'.trAuto(context), '${period.tripsCount} ${'Deliveries'.trAuto(context)}'),
                            const SizedBox(height: 4),
                            _buildPdfSummaryRow('On-Time Arrival SLA'.trAuto(context), period.onTimeRate),
                            const SizedBox(height: 4),
                            _buildPdfSummaryRow('Direct Customer Tips Included'.trAuto(context), 'Rs. 2,800.00'.trAuto(context)),
                            const SizedBox(height: 4),
                            _buildPdfSummaryRow('Highland Eco-Transit Incentive'.trAuto(context), 'Rs. 1,500.00'.trAuto(context)),
                            const SizedBox(height: 4),
                            _buildPdfSummaryRow('Withholding Tax (WHT)'.trAuto(context), 'Rs. 0.00 (Agri Exempt)'.trAuto(context)),
                            const Divider(height: 14, color: Color(0xFF86EFAC)),
                            _buildPdfSummaryRow(
                              'TOTAL DISPATCHED PAYOUT'.trAuto(context),
                              period.earnings.trAuto(context),
                              isBold: true,
                              valueColor: const Color(0xFF064E3B),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Stamp & Signatures
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ISSUED BY'.trAuto(context), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))),
                              Text('Automated Transit Settlement'.trAuto(context), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
                              Text('Sri Lanka Agri-Board Approved'.trAuto(context), style: TextStyle(fontSize: 9.5, color: const Color(0xFF047857))),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF047857), width: 1.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              children: [
                                Text('VERIFIED & STAMPED'.trAuto(context), style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFF047857))),
                                Text('FARM2HOME 2026', style: const TextStyle(fontSize: 8, color: Color(0xFF047857))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Floating Action Button inside Modal: Download / Save PDF
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _triggerPdfDownloadAnimation(context, period);
                    },
                    icon: const Icon(Icons.download_rounded, size: 19),
                    label: Text(
                      'Save PDF Statement to Device'.trAuto(context),
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF064E3B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfSummaryRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? const Color(0xFF0F172A) : const Color(0xFF475569),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 11.5,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // ── Download Success Dialog / Toast ────────────────────────────────────────
  void _triggerPdfDownloadAnimation(BuildContext context, _HistoryPeriodData period) {
    showDialog(
      context: context,
      builder: (dlgContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.download_done_rounded, color: Color(0xFF047857), size: 34),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr.pdfDownloadedTitle,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              '${'Statement'.trAuto(context)} ${_localizedPeriodLabel(context, period.label)} ${'has been saved to your Downloads folder.'.trAuto(context)}\n${'Total:'.trAuto(context)} ${period.earnings.trAuto(context)}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: const Color(0xFF64748B), height: 1.5),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dlgContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF064E3B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(context.tr.openStatement),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Navigation Bar ──────────────────────────────────────────────────
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Dashboard
            _buildNavItem(
              index: 0,
              icon: Icons.grid_view_rounded,
              label: context.tr.dashboard,
              isSelected: false,
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const DriverDashboardScreen(),
                  ),
                  (route) => route.isFirst,
                );
              },
            ),

            // Deliveries (with green notification dot)
            _buildNavItem(
              index: 1,
              icon: Icons.inventory_2_outlined,
              label: context.tr.navDeliveries,
              isSelected: true,
              hasDot: true,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const DeliveriesScreen(),
                  ),
                );
              },
            ),

            // Chat
            _buildNavItem(
              index: 2,
              icon: Icons.chat_bubble_outline_rounded,
              label: context.tr.navChat,
              isSelected: false,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chat tab selected'.trAuto(context), style: const TextStyle())),
                );
              },
            ),

            // Profile
            _buildNavItem(
              index: 3,
              icon: Icons.person_outline_rounded,
              label: context.tr.profile,
              isSelected: false,
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const DriverProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    bool hasDot = false,
    required VoidCallback onTap,
  }) {
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? activeColor : inactiveColor,
                ),
                if (hasDot)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Models ───────────────────────────────────────────────────────────────────
class _HistoryPeriodData {
  final String label;
  int tripsCount;
  String onTimeRate;
  String earnings;
  List<_TripItem> trips;

  _HistoryPeriodData({
    required this.label,
    required this.tripsCount,
    required this.onTimeRate,
    required this.earnings,
    required this.trips,
  });

  _HistoryPeriodData copyWith({
    String? label,
    int? tripsCount,
    String? onTimeRate,
    String? earnings,
    List<_TripItem>? trips,
  }) {
    return _HistoryPeriodData(
      label: label ?? this.label,
      tripsCount: tripsCount ?? this.tripsCount,
      onTimeRate: onTimeRate ?? this.onTimeRate,
      earnings: earnings ?? this.earnings,
      trips: trips ?? this.trips,
    );
  }
}

class _TripItem {
  final String orderId;
  final String pickupLocation;
  final String dropLocation;
  final String cargo;
  final String time;
  final String amount;
  final IconData cargoIcon;

  _TripItem({
    required this.orderId,
    required this.pickupLocation,
    required this.dropLocation,
    required this.cargo,
    required this.time,
    required this.amount,
    required this.cargoIcon,
  });
}

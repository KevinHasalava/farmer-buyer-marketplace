import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/premium/premium_widgets.dart';

class _DeliveryOrder {
  const _DeliveryOrder({
    required this.id,
    required this.produce,
    required this.weightKg,
    required this.pickup,
    required this.dropoff,
    required this.km,
    required this.payout,
    required this.emoji,
  });

  final String id, produce, pickup, dropoff, emoji;
  final double weightKg, km;
  final int payout;
}

const _mockOrders = [
  _DeliveryOrder(
    id: '#F2H-1042',
    produce: 'Carrots & Leeks',
    weightKg: 25,
    pickup: 'Nuwara Eliya Farm Gate',
    dropoff: 'Kandy City Centre',
    km: 12.4,
    payout: 1250,
    emoji: '🥕',
  ),
  _DeliveryOrder(
    id: '#F2H-1043',
    produce: 'Mangoes (TJC)',
    weightKg: 18,
    pickup: 'Dambulla Economic Centre',
    dropoff: 'Kurunegala Town',
    km: 8.1,
    payout: 860,
    emoji: '🥭',
  ),
  _DeliveryOrder(
    id: '#F2H-1044',
    produce: 'Tomatoes',
    weightKg: 30,
    pickup: 'Bandarawela Farms',
    dropoff: 'Badulla Market',
    km: 15.7,
    payout: 1480,
    emoji: '🍅',
  ),
];

/// Driver Dashboard matching the exact visual style of FarmerDashboard & DashboardScreen.
class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  bool _online = true;
  int _selectedNav = 0;
  final Set<String> _accepted = {};

  String get _driverName {
    final n = const AuthService().currentUserModel?.name ?? '';
    return n.isEmpty ? 'Driver' : n.split(' ').first;
  }

  Future<void> _logout() async {
    try {
      await const AuthService().signOut();
    } catch (_) {}
    if (!mounted) return;
    await context.settings.clearRole();
    if (mounted) context.go(AppRoutes.roleSelection);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Top Bar matching FarmerDashboard ────────────────────────
              _buildTopBar(context),
              const SizedBox(height: 20),

              // ── Online / Offline Status Toggle Card ─────────────────────
              _buildStatusCard(tr),
              const SizedBox(height: 16),

              // ── Earnings Summary Card (Dark Forest Green) ───────────────
              _buildEarningsCard(tr),
              const SizedBox(height: 20),

              // ── Stats 2x2 Row ───────────────────────────────────────────
              _buildStatsRow(tr),
              const SizedBox(height: 24),

              // ── Available Delivery Orders Section ───────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr.availableOrders,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (_online)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_mockOrders.length} ${tr.nearby}',
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Orders List
              if (!_online)
                _buildOfflineNotice(tr)
              else
                ..._mockOrders.map((o) => _buildOrderCard(o, tr)),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(tr),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        // Driver Avatar with online dot
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.darkGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _online
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF9CA3AF),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),

        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good day,',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$_driverName 👋',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),

        // Language Pill
        const AppLanguagePill(isDarkHeader: false),
        const SizedBox(width: 8),

        // Logout
        GestureDetector(
          onTap: _logout,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  // ── Online / Offline Card ─────────────────────────────────────────────────
  Widget _buildStatusCard(AppStrings tr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _online ? const Color(0xFFE8F8EF) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
          color: _online
              ? AppColors.primaryGreen.withValues(alpha: 0.4)
              : const Color(0xFFD1D5DB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _online
                  ? AppColors.primaryGreen
                  : const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _online ? tr.online : tr.offline,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _online
                        ? AppColors.darkGreen
                        : AppColors.textSecondary,
                  ),
                ),
                Text(
                  _online
                      ? 'Ready to receive local farm orders'
                      : tr.offlineHint,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _online,
            activeTrackColor: AppColors.primaryGreen,
            activeThumbColor: Colors.white,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _online = v);
            },
          ),
        ],
      ),
    );
  }

  // ── Earnings Card ─────────────────────────────────────────────────────────
  Widget _buildEarningsCard(AppStrings tr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF032B1C),
            Color(0xFF063725),
            Color(0xFF0D5C38),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr.todaysEarnings,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.accentOrange,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+18%',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Rs. 4,860',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats 3 Columns ───────────────────────────────────────────────────────
  Widget _buildStatsRow(AppStrings tr) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _statCol(Icons.route_rounded, '6', tr.trips),
          Container(width: 1, height: 32, color: const Color(0xFFE5E7EB)),
          _statCol(Icons.straighten_rounded, '58 km', tr.distance),
          Container(width: 1, height: 32, color: const Color(0xFFE5E7EB)),
          _statCol(Icons.star_rounded, '4.9 ★', tr.rating),
        ],
      ),
    );
  }

  Widget _statCol(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Order Card matching Product / Order Cards in existing screens ─────────
  Widget _buildOrderCard(_DeliveryOrder order, AppStrings tr) {
    final isDone = _accepted.contains(order.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDone ? AppColors.primaryGreen : const Color(0xFFE5E7EB),
          width: isDone ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(order.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.produce,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${order.id}  •  ${order.weightKg.toInt()} kg  •  ${order.km} km',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rs. ${order.payout}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),

          // Route Timeline
          Row(
            children: [
              Column(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 10,
                    color: AppColors.primaryGreen,
                  ),
                  Container(
                    width: 2,
                    height: 18,
                    color: const Color(0xFFE5E7EB),
                  ),
                  const Icon(
                    Icons.location_on_rounded,
                    size: 13,
                    color: AppColors.accentOrange,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.pickup,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.dropoff,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Button
          SizedBox(
            height: 42,
            width: double.infinity,
            child: isDone
                ? Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8EF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tr.accepted,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _accepted.add(order.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(tr.orderAccepted),
                          backgroundColor: AppColors.darkGreen,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      tr.accept,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineNotice(AppStrings tr) {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(
            Icons.power_settings_new_rounded,
            size: 48,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 12),
          Text(
            tr.offlineHint,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Navigation matching FarmerDashboard ───────────────────────────
  Widget _buildBottomNav(AppStrings tr) {
    const activeColor = Color(0xFF1E8342);
    const inactiveColor = Color(0xFF9CA3AF);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.home_rounded, tr.navHome, activeColor, inactiveColor),
          _navItem(1, Icons.receipt_long_rounded, tr.navOrders, activeColor, inactiveColor),
          _navItem(2, Icons.account_balance_wallet_rounded, tr.navEarnings, activeColor, inactiveColor),
          _navItem(3, Icons.person_rounded, tr.navProfile, activeColor, inactiveColor),
        ],
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData icon,
    String label,
    Color activeColor,
    Color inactiveColor,
  ) {
    final isSelected = _selectedNav == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNav = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? activeColor : inactiveColor,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

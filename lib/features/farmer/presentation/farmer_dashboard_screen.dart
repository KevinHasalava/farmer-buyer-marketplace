import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/localization/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../../dashboard/presentation/farmer_profile_screen.dart';
import '../../dashboard/presentation/product_detail_screen.dart';
import '../../pre_order/presentation/pre_order_list_screen.dart';
import 'package:go_router/go_router.dart';
import '../services/farmer_profile_manager.dart';
import 'add_edit_product_screen.dart';
import 'farmer_orders_screen.dart';
import 'farmer_products_screen.dart';
import '../../../core/routes/app_router.dart';
import '../../../services/auth_service.dart';
import '../../auction/presentation/farmer/farmer_auction_list_screen.dart';
import '../../auction/presentation/farmer/create_edit_auction_screen.dart';
import '../../auction/services/auction_manager.dart';
import '../../../core/services/order_lifecycle_manager.dart';

/// Pixel-perfect Farmer Dashboard Screen matching reference design
class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen>
    with SingleTickerProviderStateMixin {
  final int _selectedNav = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  final FarmerProfileManager _profileManager = FarmerProfileManager.instance;
  FarmerData get _farmer => _profileManager.profile.toFarmerData();

  @override
  void initState() {
    super.initState();
    _profileManager.addListener(_onProfileChanged);
    _profileManager.loadProfile();
    OrderLifecycleManager.instance.addListener(_onProfileChanged);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _profileManager.removeListener(_onProfileChanged);
    OrderLifecycleManager.instance.removeListener(_onProfileChanged);
    _fadeController.dispose();
    super.dispose();
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.tr.goodMorning;
    if (hour < 17) return context.tr.goodAfternoon;
    return context.tr.goodEvening;
  }

  void _showOrdersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr.incomingOrders,
              style: AppTheme.fontStyle(
                context.currentLanguage,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            ...OrderLifecycleManager.instance.farmerOrders.map(
              (ord) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOrderCard(ord),
              ),
            ),
            const SizedBox(height: 10),
            // Pre-orders button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PreOrderListScreen(isFarmerMode: true)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.handshake_rounded),
                label: const Text(
                  'Contract Farming / Pre-Orders',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Crop Auctions / Bidding button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FarmerAuctionListScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF166534),
                  side: const BorderSide(color: Color(0xFF166534), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.gavel_rounded),
                label: const Text(
                  'Crop Auctions / Bidding System',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessagesSheet() {
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
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFF235A43),
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              context.tr.farmerDirectChat,
              style: AppTheme.fontStyle(
                context.currentLanguage,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr.farmerChatSub,
              textAlign: TextAlign.center,
              style: AppTheme.fontStyle(
                context.currentLanguage,
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF235A43),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                context.tr.close,
                style: AppTheme.fontStyle(
                  context.currentLanguage,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // ── Top Bar ───────────────────────────────────────────────
                _buildTopBar(context),
                const SizedBox(height: 18),

                // ── Greeting Header ───────────────────────────────────────
                _buildGreeting(),
                const SizedBox(height: 16),



                // ── Farmer Profile Card ───────────────────────────────────
                _buildProfileCard(context),
                const SizedBox(height: 16),

                // ── 2x2 Stats Grid (Image 2 Color Palette!) ───────────────
                _buildStatsGrid(context),
                const SizedBox(height: 18),

                // ── Add New Harvest Listing Button ────────────────────────
                _buildAddNewHarvestListingButton(),
                const SizedBox(height: 20),

                // ── Quick Actions ─────────────────────────────────────────
                _buildQuickActions(context),
                const SizedBox(height: 20),

                // ── Crop Auctions & Bidding Live Banner ───────────────────
                _buildAuctionBanner(context),
                const SizedBox(height: 24),

                // ── Recent Harvest Orders ─────────────────────────────────
                _buildRecentOrdersSection(),
                const SizedBox(height: 24),

                // ── Harvest Stock Overview (New from Image 2!) ────────────
                _buildHarvestStockOverview(),
                const SizedBox(height: 20),

                // ── Agronomist Hotline Banner ─────────────────────────────
                _buildAgronomistHotlineBanner(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ── Top App Bar (Matching Reference Header) ───────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand logo & Farmer Name
        Expanded(
          child: Row(
            children: [
              const AppBrandLogo(size: 40, hasGlow: false),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const AppBrandWordmark(fontSize: 16, isLight: false),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'FARMER',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15803D),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _farmer.name.isNotEmpty ? _farmer.name : 'Janka',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),

        // Action controls: Language pill + Notification bell
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLanguagePill(),
            const SizedBox(width: 6),

            // Notification Bell with red alert indicator
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.tr.pendingOrderAlert,
                      style: AppTheme.fontStyle(context.currentLanguage),
                    ),
                    backgroundColor: const Color(0xFF166534),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF111827),
                      size: 21,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Quick Logout button
            Tooltip(
              message: context.tr.logout,
              child: GestureDetector(
                onTap: _handleLogout,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFDC2626),
                    size: 19,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 22),
            const SizedBox(width: 8),
            Text(
              context.tr.logout,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(context.tr.logoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              context.tr.cancel,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(context.tr.logout),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await const AuthService().signOut();
    } catch (_) {}

    if (!mounted) return;
    await context.settings.clearRole();

    if (mounted) {
      context.go(AppRoutes.roleSelection);
    }
  }

  // ── Greeting Header ─────────────────────────────────────────────────────────
  Widget _buildGreeting() {
    final displayName = _farmer.name.split(' ').first;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_getGreeting()}, $displayName',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Hakgala Valley Organic Farm • Nuwara Eliya',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF16A34A),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Gate Open'.trAuto(context),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF166534),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Live Market Reception Banner ─────────────────────────────────────────────
  Widget _buildLiveMarketReception() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF86EFAC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Color(0xFF14532D),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Market Reception'.trAuto(context),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Taking express logistics pickups'.trAuto(context),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wb_sunny_outlined,
                  color: Color(0xFF15803D),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '21°C Hakgala'.trAuto(context),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Farmer Profile Card ─────────────────────────────────────────────────────
  Widget _buildProfileCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FarmerProfileScreen(farmer: _farmer),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _farmer.name,
                    style: AppTheme.fontStyle(
                      context.currentLanguage,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _farmer.role,
                    style: AppTheme.fontStyle(
                      context.currentLanguage,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 15,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _farmer.location,
                        style: AppTheme.fontStyle(
                          context.currentLanguage,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Profile photo with green ring & verified badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF22C55E),
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(
                    child: (_farmer.avatarUrl != null && _farmer.avatarUrl!.isNotEmpty)
                        ? (_farmer.avatarUrl!.startsWith('assets/')
                            ? Image.asset(
                                _farmer.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFDCFCE7),
                                  child: const Center(
                                    child: Text('👨‍🌾', style: TextStyle(fontSize: 28)),
                                  ),
                                ),
                              )
                            : Image.network(
                                _farmer.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFDCFCE7),
                                  child: const Center(
                                    child: Text('👨‍🌾', style: TextStyle(fontSize: 28)),
                                  ),
                                ),
                              ))
                        : Image.network(
                            'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=400&auto=format&fit=crop&q=80',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFDCFCE7),
                              child: const Center(
                                child: Text('👨‍🌾', style: TextStyle(fontSize: 28)),
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 19,
                    height: 19,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 11,
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

  // ── 2x2 Stats Grid (Image 2 Color Palette) ──────────────────────────────────
  Widget _buildStatsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Today's Orders (Mint Green: 0xFFDCFCE7)
            Expanded(
              child: _buildImage2MetricCard(
                title: "Today's Orders".trAuto(context),
                value: '14',
                subtitle: '+4 peak'.trAuto(context),
                bgColor: const Color(0xFFDCFCE7),
                borderColor: const Color(0xFFBBF7D0),
                textColor: const Color(0xFF14532D),
                subtextColor: const Color(0xFF15803D),
                icon: Icons.shopping_bag_rounded,
                iconColor: const Color(0xFF166534),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FarmerOrdersScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Active Orders / New Orders (Soft Blue: 0xFFEFF6FF)
            Expanded(
              child: _buildImage2MetricCard(
                title: context.tr.newOrders,
                value: '${OrderLifecycleManager.instance.pendingFarmerOrdersCount}',
                subtitle: 'Pending'.trAuto(context),
                bgColor: const Color(0xFFEFF6FF),
                borderColor: const Color(0xFFDBEAFE),
                textColor: const Color(0xFF1E40AF),
                subtextColor: const Color(0xFF2563EB),
                icon: Icons.assignment_outlined,
                iconColor: const Color(0xFF1D4ED8),
                onTap: _showOrdersSheet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Completed Orders (Warm Peach: 0xFFFFEDD5)
            Expanded(
              child: _buildImage2MetricCard(
                title: context.tr.completedOrdersFarmer,
                value: '${16 + OrderLifecycleManager.instance.completedFarmerOrdersCount}',
                subtitle: 'Delivered'.trAuto(context),
                bgColor: const Color(0xFFFFEDD5),
                borderColor: const Color(0xFFFED7AA),
                textColor: const Color(0xFF9A3412),
                subtextColor: const Color(0xFFC2410C),
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFFC2410C),
                onTap: _showOrdersSheet,
              ),
            ),
            const SizedBox(width: 12),
            // Weekly Earnings (Ice Blue: 0xFFE0F2FE)
            Expanded(
              child: _buildImage2MetricCard(
                title: context.tr.thisWeekEarnings,
                value: (8500 + OrderLifecycleManager.instance.totalFarmerEarnings).toStringAsFixed(0),
                prefix: 'Rs.'.trAuto(context),
                subtitle: 'Net income'.trAuto(context),
                bgColor: const Color(0xFFE0F2FE),
                borderColor: const Color(0xFFBAE6FD),
                textColor: const Color(0xFF0369A1),
                subtextColor: const Color(0xFF0284C7),
                icon: Icons.monetization_on_outlined,
                iconColor: const Color(0xFF0284C7),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FarmerOrdersScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImage2MetricCard({
    required String title,
    required String value,
    String prefix = '',
    required String subtitle,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 17, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (prefix.isNotEmpty)
              Text(
                prefix,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: prefix.isNotEmpty ? 20 : 25,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: subtextColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Add New Harvest Listing Button ──────────────────────────────────────────
  Widget _buildAddNewHarvestListingButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditProductScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A5C36),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              '+ Add New Harvest Listing'.trAuto(context),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick Actions ───────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr.quickActions.toUpperCase(),
          style: AppTheme.fontStyle(
            context.currentLanguage,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF374151),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildActionItem(
                icon: Icons.add_rounded,
                label: context.tr.addProduct,
                isPrimary: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionItem(
                icon: Icons.inventory_2_outlined,
                label: context.tr.myProducts,
                isPrimary: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FarmerProductsScreen()),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionItem(
                icon: Icons.assignment_outlined,
                label: context.tr.navOrders,
                isPrimary: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FarmerOrdersScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: context.tr.messages,
                isPrimary: false,
                onTap: _showMessagesSheet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isPrimary ? const Color(0xFF235A43) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isPrimary
                  ? null
                  : Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: isPrimary
                      ? const Color(0xFF235A43).withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: isPrimary ? 26 : 22,
              color: isPrimary ? Colors.white : const Color(0xFF235A43),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.fontStyle(
              context.currentLanguage,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  // ── Crop Auctions / Bidding Live Banner ─────────────────────────────────────
  Widget _buildAuctionBanner(BuildContext context) {
    return ListenableBuilder(
      listenable: AuctionManager.instance,
      builder: (context, _) {
        final activeCount = AuctionManager.instance.activeAuctionsCount;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F3822), Color(0xFF1E5E3A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E5E3A).withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4ADE80).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 12, color: Color(0xFF4ADE80)),
                        const SizedBox(width: 4),
                        Text(
                          '$activeCount LIVE LOTS OPEN'.trAuto(context),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF86EFAC),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.gavel_rounded, color: Color(0xFFFDE047), size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Crop Bidding / Auction System 🌾'.trAuto(context),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Auction bulk harvests directly to buyers. Receive competitive bids for top market value.'.trAuto(context),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFD1FAE5),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FarmerAuctionListScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F3822),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      icon: const Icon(Icons.dashboard_customize_rounded, size: 16),
                      label: Text(
                        'Manage Auctions'.trAuto(context),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateEditAuctionScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add_rounded, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'New Lot'.trAuto(context),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Recent Orders Section ───────────────────────────────────────────────────
  Widget _buildRecentOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr.recentOrders,
              style: AppTheme.fontStyle(
                context.currentLanguage,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FarmerOrdersScreen()),
                );
              },
              child: Text(
                context.tr.seeAll,
                style: AppTheme.fontStyle(
                  context.currentLanguage,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF235A43),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...OrderLifecycleManager.instance.farmerOrders.take(3).map(
          (ord) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOrderCard(ord),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(FarmerOrderItem ord) {
    final isReady = ord.status == 'Packed & Ready' || ord.status == 'Ready for Pickup';
    final isInTransit = ord.status == 'In Transit';
    final isCompleted = ord.status == 'Completed';

    final badgeBg = isCompleted
        ? const Color(0xFFECFDF5)
        : isInTransit
            ? const Color(0xFFEFF6FF)
            : isReady
                ? const Color(0xFFF0FDF4)
                : const Color(0xFFFFFBEB);
    final badgeBorder = isCompleted
        ? const Color(0xFFA7F3D0)
        : isInTransit
            ? const Color(0xFFBFDBFE)
            : isReady
                ? const Color(0xFF86EFAC)
                : const Color(0xFFFDE68A);
    final badgeText = isCompleted
        ? const Color(0xFF059669)
        : isInTransit
            ? const Color(0xFF2563EB)
            : isReady
                ? const Color(0xFF16A34A)
                : const Color(0xFFD97706);

    return InkWell(
      onTap: () => _showOrderDetailDialog(ord),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
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
            // Customer avatar photo
            ClipOval(
              child: Image.network(
                ord.avatarUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 44,
                  height: 44,
                  color: const Color(0xFFF3F4F6),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Order details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        ord.id,
                        style: AppTheme.fontStyle(
                          context.currentLanguage,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Text(
                        ' • ',
                        style: AppTheme.fontStyle(
                          context.currentLanguage,
                          fontSize: 13,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          ord.customer,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.fontStyle(
                            context.currentLanguage,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        ord.amount,
                        style: AppTheme.fontStyle(
                          context.currentLanguage,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Text(
                          'PIN: ${ord.handoverPin}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF166534),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Badge Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: badgeBorder),
              ),
              child: Text(
                ord.status,
                style: AppTheme.fontStyle(
                  context.currentLanguage,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: badgeText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetailDialog(FarmerOrderItem ord) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isPending = ord.status == 'Pending' || ord.isPending;
          final isReady = ord.status == 'Packed & Ready' || ord.status == 'Ready for Pickup';
          final isInTransit = ord.status == 'In Transit';
          final isCompleted = ord.status == 'Completed';

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ord.id,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF166534),
                          ),
                        ),
                        Text(
                          ord.preferredTime,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFFECFDF5)
                            : isInTransit
                                ? const Color(0xFFEFF6FF)
                                : isReady
                                    ? const Color(0xFFF0FDF4)
                                    : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isCompleted
                              ? const Color(0xFFA7F3D0)
                              : isInTransit
                                  ? const Color(0xFFBFDBFE)
                                  : isReady
                                      ? const Color(0xFF86EFAC)
                                      : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Text(
                        ord.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isCompleted
                              ? const Color(0xFF059669)
                              : isInTransit
                                  ? const Color(0xFF2563EB)
                                  : isReady
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Driver Handover PIN Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF166534),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.vpn_key_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Driver Handover PIN'.trAuto(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Color(0xFF166534),
                              ),
                            ),
                            Text(
                              'Provide to Rider upon crate collection'.trAuto(context),
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF166534),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          ord.handoverPin,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Customer details card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(ord.avatarUrl),
                            onBackgroundImageError: (_, __) {},
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ord.customer,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  ord.customerPhone,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            ord.amount,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              ord.deliveryAddress,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Items List
                Text(
                  'Order Items'.trAuto(context),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 8),
                ...ord.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Text(item.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name.trAuto(context),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            '${item.quantity} ${item.unit} • Rs. ${item.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),
                // Actions
                if (isPending)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF166534),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        OrderLifecycleManager.instance.onFarmerStatusUpdated(ord.id, 'Packed & Ready');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✓ Order ${ord.id} marked Packed & Ready for Driver pickup!'),
                            backgroundColor: const Color(0xFF166534),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                      label: const Text(
                        'Pack & Mark Ready for Driver',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        isReady
                            ? 'Awaiting Driver Pickup (PIN: ${ord.handoverPin})'
                            : isInTransit
                                ? 'In Transit with Rider Ranjith'
                                : 'Completed & Settled',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                          fontSize: 13,
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

  // ── Harvest Stock Overview (Matching Image 2 + Stock Summary Metrics) ───────
  Widget _buildHarvestStockOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title & Manage All
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harvest Stock Overview',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hakgala Valley Terrace Beds',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FarmerProductsScreen()),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(60, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Manage All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF166534),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Inventory Quick Summary (Total Stock, Available, Low Stock, Out of Stock)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDCFCE7)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStockSummaryPill('Total Stock', '75 kg', const Color(0xFF166534)),
              Container(width: 1, height: 24, color: const Color(0xFFBBF7D0)),
              _buildStockSummaryPill('Available', '2 items', const Color(0xFF047857)),
              Container(width: 1, height: 24, color: const Color(0xFFBBF7D0)),
              _buildStockSummaryPill('Low Stock', '1 item', const Color(0xFFC2410C)),
              Container(width: 1, height: 24, color: const Color(0xFFBBF7D0)),
              _buildStockSummaryPill('Out of Stock', '0 items', const Color(0xFF64748B)),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Product Cards from Reference Image
        Row(
          children: [
            Expanded(
              child: _buildStockItemCard(
                imageUrl:
                    'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500&auto=format&fit=crop&q=80',
                badge: 'Grade A',
                title: 'Nuwara Eliya Carrots',
                stock: '45 kg left',
                price: 'Rs. 380/kg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStockItemCard(
                imageUrl:
                    'https://images.unsplash.com/photo-1628771065518-0d82f1938462?w=500&auto=format&fit=crop&q=80',
                badge: 'Fresh Cut',
                title: 'Highland Leeks',
                stock: '30 kg left',
                price: 'Rs. 310/kg',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockSummaryPill(String label, String val, Color valColor) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: valColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStockItemCard({
    required String imageUrl,
    required String badge,
    required String title,
    required String stock,
    required String price,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 100,
                    color: const Color(0xFFE2E8F0),
                    child: const Center(
                      child: Icon(Icons.eco_rounded, color: Color(0xFF166534)),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stock,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15803D),
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

  // ── Agronomist Hotline Banner (Matching Image 2) ────────────────────────────
  Widget _buildAgronomistHotlineBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF064E3B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF047857),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Agronomist Hotline',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Nuwara Eliya Regional Support Desk',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFA7F3D0),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('\: +94 52 222 3456'),
                  backgroundColor: Color(0xFF064E3B),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_rounded,
                color: Color(0xFF064E3B),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Navigation Bar ───────────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildNavItem(
              icon: Icons.home_rounded,
              label: context.tr.navHome,
              isSelected: _selectedNav == 0,
              onTap: () => setState(() => _selectedNav == 0),
            ),
          ),
          Expanded(
            child: _buildNavItem(
              icon: Icons.assignment_outlined,
              label: context.tr.navOrders,
              hasBadge: true,
              isSelected: _selectedNav == 1,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FarmerOrdersScreen()),
                );
              },
            ),
          ),
          Expanded(
            child: _buildNavItem(
              icon: Icons.chat_bubble_outline_rounded,
              label: context.tr.navChat,
              isSelected: _selectedNav == 2,
              onTap: () {
                setState(() => _selectedNav == 2);
                _showMessagesSheet();
              },
            ),
          ),
          Expanded(
            child: _buildNavItem(
              icon: Icons.person_outline_rounded,
              label: context.tr.navProfile,
              isSelected: _selectedNav == 3,
              onTap: () {
                setState(() => _selectedNav == 3);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FarmerProfileScreen(farmer: _farmer),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    bool hasBadge = false,
    required VoidCallback onTap,
  }) {
    const activeColor = Color(0xFF235A43);
    const inactiveColor = Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? activeColor : inactiveColor,
              ),
              if (hasBadge)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTheme.fontStyle(
              context.currentLanguage,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

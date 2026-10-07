import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/localization/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../../dashboard/presentation/farmer_profile_screen.dart';
import '../../dashboard/presentation/product_detail_screen.dart';
import '../services/farmer_profile_manager.dart';
import 'add_edit_product_screen.dart';
import 'farmer_products_screen.dart';

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

  static const _recentOrders = [
    (
      id: '#F2H1025',
      customer: 'Nadeesha Fernando',
      amount: 'Rs. 950',
      status: 'Pending',
      isPending: true,
      avatarUrl:
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
    ),
    (
      id: '#F2H1024',
      customer: 'Kasun Perera',
      amount: 'Rs. 1,200',
      status: 'Confirmed',
      isPending: false,
      avatarUrl:
          'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&auto=format&fit=crop&q=80',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _profileManager.addListener(_onProfileChanged);
    _profileManager.loadProfile();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _profileManager.removeListener(_onProfileChanged);
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
            ..._recentOrders.map(
              (ord) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildOrderCard(ord),
              ),
            ),
            const SizedBox(height: 10),
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
                const SizedBox(height: 24),

                // ── Greeting Header ───────────────────────────────────────
                _buildGreeting(),
                const SizedBox(height: 20),

                // ── Farmer Profile Card ───────────────────────────────────
                _buildProfileCard(context),
                const SizedBox(height: 22),

                // ── 2x2 Stats Grid ────────────────────────────────────────
                _buildStatsGrid(context),
                const SizedBox(height: 24),

                // ── Quick Actions ─────────────────────────────────────────
                _buildQuickActions(context),
                const SizedBox(height: 24),

                // ── Recent Orders ─────────────────────────────────────────
                _buildRecentOrdersSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ── Top App Bar ─────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.tr.farmerDashboard,
          style: AppTheme.fontStyle(
            context.currentLanguage,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        Row(
          children: [
            // Quick Language Switcher Pill
            const AppLanguagePill(),
            const SizedBox(width: 8),

            // Buyer View Switcher pill button
            GestureDetector(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.tr.alreadyAtFarmerRoot,
                        style: AppTheme.fontStyle(context.currentLanguage),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.tr.buyerView,
                      style: AppTheme.fontStyle(
                        context.currentLanguage,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.swap_horiz_rounded,
                      size: 14,
                      color: Color(0xFF4B5563),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Bell Notification with green indicator dot
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.tr.pendingOrderAlert,
                      style: AppTheme.fontStyle(context.currentLanguage),
                    ),
                    backgroundColor: const Color(0xFF235A43),
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
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF111827),
                      size: 22,
                    ),
                  ),
                  Positioned(
                    top: 1,
                    right: 1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Greeting Header ─────────────────────────────────────────────────────────
  Widget _buildGreeting() {
    final displayName = _farmer.name.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getGreeting()}, $displayName 🌾',
          style: AppTheme.fontStyle(
            context.currentLanguage,
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr.farmOverview,
          style: AppTheme.fontStyle(
            context.currentLanguage,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
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
                    child: Image.network(
                      'https://images.unsplash.com/photo-1544717305-2782549b5136?w=200&auto=format&fit=crop&q=80',
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

  // ── 2x2 Stats Grid ──────────────────────────────────────────────────────────
  Widget _buildStatsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                value: '12',
                label: context.tr.activeProducts,
                icon: Icons.inventory_2_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FarmerProductsScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard(
                value: '5',
                label: context.tr.newOrders,
                icon: Icons.assignment_outlined,
                onTap: _showOrdersSheet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                value: '18',
                label: context.tr.completedOrdersFarmer,
                icon: Icons.check_circle_outline_rounded,
                onTap: _showOrdersSheet,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard(
                value: 'Rs. 8,500',
                label: context.tr.thisWeekEarnings,
                icon: Icons.monetization_on_outlined,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.tr.weeklyEarningsSummary,
                        style: AppTheme.fontStyle(context.currentLanguage),
                      ),
                      backgroundColor: const Color(0xFF235A43),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: AppTheme.fontStyle(
                      context.currentLanguage,
                      fontSize: value.startsWith('Rs') ? 17 : 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E5E3A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: const Color(0xFF10B981)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppTheme.fontStyle(
                context.currentLanguage,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionItem(
              icon: Icons.add_rounded,
              label: context.tr.addProduct,
              isPrimary: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
              ),
            ),
            _buildActionItem(
              icon: Icons.inventory_2_outlined,
              label: context.tr.myProducts,
              isPrimary: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FarmerProductsScreen()),
              ),
            ),
            _buildActionItem(
              icon: Icons.assignment_outlined,
              label: context.tr.navOrders,
              isPrimary: false,
              onTap: _showOrdersSheet,
            ),
            _buildActionItem(
              icon: Icons.chat_bubble_outline_rounded,
              label: context.tr.messages,
              isPrimary: false,
              onTap: _showMessagesSheet,
            ),
          ],
        ),
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
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isPrimary ? const Color(0xFF235A43) : Colors.white,
              borderRadius: BorderRadius.circular(18),
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
              size: isPrimary ? 28 : 24,
              color: isPrimary ? Colors.white : const Color(0xFF235A43),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.fontStyle(
              context.currentLanguage,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
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
              onTap: _showOrdersSheet,
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
        ..._recentOrders.map(
          (ord) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildOrderCard(ord),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard((
    {
      String id,
      String customer,
      String amount,
      String status,
      bool isPending,
      String avatarUrl,
    }
  ) ord) {
    final isPending = ord.isPending;
    final badgeBg = isPending
        ? const Color(0xFFFFFBEB)
        : const Color(0xFFECFDF5);
    final badgeBorder = isPending
        ? const Color(0xFFFDE68A)
        : const Color(0xFFA7F3D0);
    final badgeText = isPending
        ? const Color(0xFFD97706)
        : const Color(0xFF059669);

    return Container(
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
                Text(
                  ord.amount,
                  style: AppTheme.fontStyle(
                    context.currentLanguage,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),

          // Status Badge Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: badgeBorder),
            ),
            child: Text(
              ord.isPending ? context.tr.statusPending : context.tr.statusConfirmed,
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_rounded,
            label: context.tr.navHome,
            isSelected: _selectedNav == 0,
            onTap: () => setState(() => _selectedNav == 0),
          ),
          _buildNavItem(
            icon: Icons.assignment_outlined,
            label: context.tr.navOrders,
            hasBadge: true,
            isSelected: _selectedNav == 1,
            onTap: () {
              setState(() => _selectedNav == 1);
              _showOrdersSheet();
            },
          ),
          _buildNavItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: context.tr.navChat,
            isSelected: _selectedNav == 2,
            onTap: () {
              setState(() => _selectedNav == 2);
              _showMessagesSheet();
            },
          ),
          _buildNavItem(
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

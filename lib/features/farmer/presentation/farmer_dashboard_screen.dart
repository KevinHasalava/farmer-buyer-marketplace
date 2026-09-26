import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../dashboard/presentation/farmer_profile_screen.dart';
import '../../dashboard/presentation/product_detail_screen.dart';
import 'add_edit_product_screen.dart';
import 'farmer_products_screen.dart';

/// Premium Farmer Dashboard Screen
class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen>
    with TickerProviderStateMixin {
  int _selectedNav = 0;

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  static const _farmer = FarmerData.defaultFarmer;

  static const _recentOrders = [
    (
      id: '#F2H1025',
      customer: 'Nadeesha Fernando',
      amount: 'Rs. 950',
      status: 'Pending',
      isPending: true,
      avatarEmoji: '👩‍💼',
    ),
    (
      id: '#F2H1024',
      customer: 'Kasun Perera',
      amount: 'Rs. 1,200',
      status: 'Confirmed',
      isPending: false,
      avatarEmoji: '👨‍💼',
    ),
    (
      id: '#F2H1023',
      customer: 'Amara Silva',
      amount: 'Rs. 2,100',
      status: 'Delivered',
      isPending: false,
      avatarEmoji: '👩',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F2),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Premium Gradient Hero Header ──────────────────────────────
            SliverToBoxAdapter(child: _buildHeroHeader(context)),

            // ── Body Content ───────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),

                  // Stats Grid
                  _buildStatsGrid(context),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(context),
                  const SizedBox(height: 24),

                  // Recent Orders
                  _buildRecentOrders(context),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),

      // ── Floating Bottom Navigation ──────────────────────────────────────
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF063725), Color(0xFF1E8342), Color(0xFF2DA55A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 50,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Title + Actions
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Farmer Dashboard',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      // Buyer View Switch
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Buyer View',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.swap_horiz_rounded,
                                  size: 14, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Notification Bell
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, __) => Stack(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            Positioned(
                              right: 7,
                              top: 7,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBBF24)
                                      .withValues(alpha: _pulseAnim.value),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Greeting Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getGreeting()}, Sunil 🌾',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Here's your farm overview today",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Farmer Avatar Card
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const FarmerProfileScreen(farmer: _farmer),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFFA500)
                              ],
                            ),
                          ),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF1A5C34),
                                  Color(0xFF063725)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('👨‍🌾',
                                  style: TextStyle(fontSize: 28)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Farmer Info Card (Glassmorphism)
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const FarmerProfileScreen(farmer: _farmer),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Verified badge
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.verified_rounded,
                                color: Color(0xFF4ADE80), size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _farmer.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _farmer.role,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color:
                                        Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 13, color: Color(0xFF86EFAC)),
                              const SizedBox(width: 3),
                              Text(
                                _farmer.location,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right_rounded,
                                  size: 16, color: Colors.white54),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildStatsGrid(BuildContext context) {
    final stats = [
      (
        number: '12',
        label: 'Active\nProducts',
        icon: Icons.inventory_2_rounded,
        color1: const Color(0xFF1E8342),
        color2: const Color(0xFF0D6B35),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const FarmerProductsScreen())),
      ),
      (
        number: '5',
        label: 'New\nOrders',
        icon: Icons.receipt_long_rounded,
        color1: const Color(0xFF2563EB),
        color2: const Color(0xFF1D4ED8),
        onTap: () {},
      ),
      (
        number: '18',
        label: 'Completed\nOrders',
        icon: Icons.check_circle_rounded,
        color1: const Color(0xFF7C3AED),
        color2: const Color(0xFF6D28D9),
        onTap: () {},
      ),
      (
        number: 'Rs.\n8,500',
        label: 'This Week\nEarnings',
        icon: Icons.account_balance_wallet_rounded,
        color1: const Color(0xFFD97706),
        color2: const Color(0xFFB45309),
        onTap: () {},
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E8342), Color(0xFF4ADE80)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Performance Overview',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: stats
              .map((s) => _PremiumStatCard(
                    number: s.number,
                    label: s.label,
                    icon: s.icon,
                    color1: s.color1,
                    color2: s.color2,
                    onTap: s.onTap,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E8342), Color(0xFF4ADE80)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Quick Actions',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _PremiumQuickAction(
                icon: Icons.add_rounded,
                label: 'Add\nProduct',
                isPrimary: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddEditProductScreen()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PremiumQuickAction(
                icon: Icons.inventory_2_outlined,
                label: 'My\nProducts',
                isPrimary: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FarmerProductsScreen()),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PremiumQuickAction(
                icon: Icons.assignment_outlined,
                label: 'Orders',
                isPrimary: false,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  _premiumSnackBar('Orders view coming soon'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PremiumQuickAction(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Messages',
                isPrimary: false,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  _premiumSnackBar('Messages coming soon'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentOrders(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E8342), Color(0xFF4ADE80)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Orders',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1E8342),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                backgroundColor:
                    const Color(0xFF1E8342).withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'See All',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_recentOrders.length, (i) {
          final ord = _recentOrders[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i < _recentOrders.length - 1 ? 10 : 0),
            child: _PremiumOrderCard(
              id: ord.id,
              customer: ord.customer,
              amount: ord.amount,
              status: ord.status,
              isPending: ord.isPending,
              avatarEmoji: ord.avatarEmoji,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBtn(
            icon: Icons.home_rounded,
            label: 'Home',
            isSelected: _selectedNav == 0,
            onTap: () => setState(() => _selectedNav = 0),
          ),
          _NavBtn(
            icon: Icons.receipt_long_rounded,
            label: 'Orders',
            badgeDot: true,
            isSelected: _selectedNav == 1,
            onTap: () => setState(() => _selectedNav = 1),
          ),
          _NavBtn(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            isSelected: _selectedNav == 2,
            onTap: () => setState(() => _selectedNav = 2),
          ),
          _NavBtn(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            isSelected: _selectedNav == 3,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const FarmerProfileScreen(farmer: _farmer),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SnackBar _premiumSnackBar(String msg) {
    return SnackBar(
      content: Text(msg,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      backgroundColor: const Color(0xFF063725),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Stat Card with gradient
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumStatCard extends StatefulWidget {
  const _PremiumStatCard({
    required this.number,
    required this.label,
    required this.icon,
    required this.color1,
    required this.color2,
    required this.onTap,
  });
  final String number;
  final String label;
  final IconData icon;
  final Color color1;
  final Color color2;
  final VoidCallback onTap;

  @override
  State<_PremiumStatCard> createState() => _PremiumStatCardState();
}

class _PremiumStatCardState extends State<_PremiumStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim =
        Tween<double>(begin: 1.0, end: 0.95).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.color1, widget.color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color1.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background icon watermark
              Positioned(
                right: -8,
                bottom: -8,
                child: Icon(
                  widget.icon,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child:
                          Icon(widget.icon, size: 17, color: Colors.white),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.number,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          widget.label,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.3,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Quick Action Button
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumQuickAction extends StatefulWidget {
  const _PremiumQuickAction({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  State<_PremiumQuickAction> createState() => _PremiumQuickActionState();
}

class _PremiumQuickActionState extends State<_PremiumQuickAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: 1 - _ctrl.value * 0.06,
          child: child,
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: widget.isPrimary
                    ? const LinearGradient(
                        colors: [Color(0xFF1E8342), Color(0xFF063725)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: widget.isPrimary ? null : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: widget.isPrimary
                    ? null
                    : Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: widget.isPrimary
                        ? const Color(0xFF1E8342).withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: widget.isPrimary ? 14 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: 24,
                color: widget.isPrimary
                    ? Colors.white
                    : const Color(0xFF1E8342),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Order Card
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumOrderCard extends StatelessWidget {
  const _PremiumOrderCard({
    required this.id,
    required this.customer,
    required this.amount,
    required this.status,
    required this.isPending,
    required this.avatarEmoji,
  });
  final String id, customer, amount, status, avatarEmoji;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;
    Color statusBorder;

    if (status == 'Pending') {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFFFBEB);
      statusBorder = const Color(0xFFFDE68A);
    } else if (status == 'Confirmed') {
      statusColor = const Color(0xFF059669);
      statusBg = const Color(0xFFECFDF5);
      statusBorder = const Color(0xFFA7F3D0);
    } else {
      statusColor = const Color(0xFF2563EB);
      statusBg = const Color(0xFFEFF6FF);
      statusBorder = const Color(0xFFBFDBFE);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
            ),
            child: Center(
              child: Text(avatarEmoji,
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),

          // Order info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      id,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E8342),
                      ),
                    ),
                    Text(
                      '  •  ',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: const Color(0xFF9CA3AF)),
                    ),
                    Expanded(
                      child: Text(
                        customer,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  amount,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),

          // Status pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: statusBorder),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Nav Button
// ─────────────────────────────────────────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  const _NavBtn({
    required this.icon,
    required this.label,
    this.badgeDot = false,
    required this.isSelected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool badgeDot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E8342).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? const Color(0xFF1E8342)
                      : const Color(0xFF9CA3AF),
                ),
                if (badgeDot)
                  Positioned(
                    right: -3,
                    top: -3,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF1E8342)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

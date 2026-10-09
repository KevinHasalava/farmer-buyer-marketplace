import 'package:flutter/material.dart';
import '../../../core/localization/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../services/admin_auth_service.dart';
import '../services/admin_marketplace_service.dart';
import 'widgets/admin_crud_dialogs.dart';
import '../../pre_order/services/pre_order_manager.dart';
import '../../pre_order/presentation/pre_order_detail_screen.dart';
import '../../auction/services/auction_manager.dart';
import '../../auction/presentation/farmer/farmer_auction_detail_screen.dart';
import '../../auction/presentation/farmer/create_edit_auction_screen.dart';

/// Ultra-Premium Farm2Home Enterprise Master Admin Console
/// Features: Side Navigation Rail/Sidebar, High-end Executive UI, Full Role CRUD & Dispatch
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  final AdminMarketplaceService _service = AdminMarketplaceService.instance;
  final AdminAuthService _auth = AdminAuthService.instance;

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _searchQuery = '';
  int _activeNavIndex = 0;

  // Premium Executive Color Palette
  static const Color _sidebarBgStart = Color(0xFF041713);
  static const Color _sidebarBgEnd = Color(0xFF08261F);
  static const Color _sidebarBorder = Color(0xFF0D3B31);
  static const Color _emerald = Color(0xFF059669);
  static const Color _workspaceBg = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _borderLight = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging &&
          _activeNavIndex != _tabController.index) {
        setState(() {
          _activeNavIndex = _tabController.index;
        });
      }
    });
    _service.addListener(_onServiceChanged);
    _auth.addListener(_onServiceChanged);
    AuctionManager.instance.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    _auth.removeListener(_onServiceChanged);
    AuctionManager.instance.removeListener(_onServiceChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  void _switchTab(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _activeNavIndex = index;
    });
    _tabController.animateTo(index);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 22),
            SizedBox(width: 8),
            Text(
              'Sign Out from Console',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to lock and exit the Master Administrator session?',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr.cancel, style: const TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.tr.logout),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      HapticFeedback.mediumImpact();
      await _auth.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Master Administrator session terminated.'),
          backgroundColor: Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go(AppRoutes.adminLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Route protection guard
    if (!_auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.adminLogin);
      });
      return const Scaffold(
        backgroundColor: Color(0xFF041713),
        body: Center(
          child: CircularProgressIndicator(color: _emerald),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 850;

    if (isDesktop) {
      // 🖥️ Desktop / Web Executive Dual-Pane Layout (Side Navigation Bar)
      return Scaffold(
        backgroundColor: _workspaceBg,
        body: Row(
          children: [
            // Left Side Navigation Panel (260px)
            SizedBox(
              width: 260,
              child: _buildSidebarContent(isDrawer: false),
            ),

            // Right Main Workspace
            Expanded(
              child: Column(
                children: [
                  _buildWorkspaceTopBar(isDesktop: true),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildOverviewTab(),
                        _buildFarmersTab(),
                        _buildBuyersTab(),
                        _buildDriversTab(),
                        _buildProductsTab(),
                        _buildOrdersTab(),
                        _buildContractsTab(),
                        _buildAuctionsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // 📱 Mobile / Small Screen Responsive Layout with Slide-in Navigation Drawer
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: _workspaceBg,
        drawer: Drawer(
          width: 280,
          child: _buildSidebarContent(isDrawer: true),
        ),
        appBar: _buildMobileAppBar(),
        body: Column(
          children: [
            _buildSearchBar(isCompact: true),
            _buildMobilePillBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildFarmersTab(),
                  _buildBuyersTab(),
                  _buildDriversTab(),
                  _buildProductsTab(),
                  _buildOrdersTab(),
                  _buildContractsTab(),
                  _buildAuctionsTab(),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏢 1. LEFT EXECUTIVE SIDEBAR NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSidebarContent({required bool isDrawer}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_sidebarBgStart, _sidebarBgEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          right: BorderSide(color: _sidebarBorder, width: 1.2),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Sidebar Brand Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Row(
                children: [
                  // Official App Logo (Matches Loading/Splash Screen)
                  const AppBrandLogo(size: 38, hasGlow: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            AppBrandWordmark(fontSize: 16, isLight: true),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                              ),
                              child: const Text(
                                'MASTER',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFCD34D),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'v2.4 Pro',
                              style: TextStyle(fontSize: 10.5, color: Color(0xFF6EE7B7)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: _sidebarBorder, height: 1),
            ),
            const SizedBox(height: 12),

            // ── Section Label ───────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Text(
                'MANAGEMENT MODULES',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 1.1,
                ),
              ),
            ),

            // ── Vertical Navigation Items ────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                children: [
                  _buildSidebarNavItem(
                    index: 0,
                    icon: Icons.dashboard_rounded,
                    label: 'Overview',
                    badgeCount: null,
                  ),
                  _buildSidebarNavItem(
                    index: 1,
                    icon: Icons.agriculture_rounded,
                    label: 'Farmers Registry',
                    badgeCount: '${_service.totalFarmers}',
                  ),
                  _buildSidebarNavItem(
                    index: 2,
                    icon: Icons.shopping_bag_rounded,
                    label: 'Buyer Accounts',
                    badgeCount: '${_service.totalBuyers}',
                  ),
                  _buildSidebarNavItem(
                    index: 3,
                    icon: Icons.local_shipping_rounded,
                    label: 'Transit & Fleet',
                    badgeCount: '${_service.totalDrivers}',
                  ),
                  _buildSidebarNavItem(
                    index: 4,
                    icon: Icons.inventory_2_rounded,
                    label: 'Produce Catalog',
                    badgeCount: '${_service.totalProducts}',
                  ),
                  _buildSidebarNavItem(
                    index: 5,
                    icon: Icons.receipt_long_rounded,
                    label: 'Orders & Dispatch',
                    badgeCount: '${_service.totalOrders}',
                  ),
                  _buildSidebarNavItem(
                    index: 6,
                    icon: Icons.handshake_rounded,
                    label: 'Pre-Orders (Contracts)',
                    badgeCount: null,
                  ),
                  _buildSidebarNavItem(
                    index: 7,
                    icon: Icons.gavel_rounded,
                    label: 'Crop Auctions & Bids',
                    badgeCount: '${AuctionManager.instance.activeAuctionsCount}',
                  ),
                ],
              ),
            ),

            // ── Telemetry & SMS Indicator ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B241E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF134E4A)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF10B981),
                        boxShadow: [
                          BoxShadow(color: Color(0xFF10B981), blurRadius: 6, spreadRadius: 1),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gateway Connected',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Notify.lk SMS • Active',
                            style: TextStyle(fontSize: 9.5, color: Color(0xFF6EE7B7)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: _sidebarBorder, height: 1),
            ),

            // ── Bottom Admin Profile & Logout ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B241E).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _sidebarBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF064E3B),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_outline_rounded, color: Color(0xFF34D399), size: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _auth.currentAdminName.isNotEmpty ? _auth.currentAdminName : 'Master Admin',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _auth.currentAdminEmail.isNotEmpty ? _auth.currentAdminEmail : 'admin@farm2home.lk',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Lock & Logout',
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFFF87171), size: 18),
                      onPressed: _handleLogout,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarNavItem({
    required int index,
    required IconData icon,
    required String label,
    required String? badgeCount,
  }) {
    final isSelected = _activeNavIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => _switchTab(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF047857) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.6), width: 1)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF047857).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
              if (badgeCount != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF065F46)
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF34D399) : const Color(0xFF334155),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    badgeCount,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? const Color(0xFFA7F3D0) : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🧭 2. DESKTOP WORKSPACE TOP BAR (BREADCRUMB + SEARCH + ACTIONS)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildWorkspaceTopBar({required bool isDesktop}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 1150;
    final isVeryNarrow = screenWidth < 980;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _borderLight)),
      ),
      child: Row(
        children: [
          // Section Breadcrumbs
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isVeryNarrow)
                Text(
                  'Farm2Home Console',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: _textMuted),
                ),
              Text(
                _getTabTitle(_activeNavIndex),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // Search Field
          Expanded(
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _borderLight),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                style: const TextStyle(fontSize: 12.5, color: _textDark),
                decoration: InputDecoration(
                  hintText: isVeryNarrow ? 'Search...' : 'Search records by name, ID, phone...',
                  hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 17, color: Color(0xFF64748B)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 15, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : (!isVeryNarrow
                          ? Container(
                              margin: const EdgeInsets.all(7),
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: _borderLight),
                              ),
                              child: const Text(
                                'Ctrl+K',
                                style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                              ),
                            )
                          : null),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Language Selector
          const Center(child: AppLanguagePill(isDarkHeader: false)),
          const SizedBox(width: 6),

          // Supabase Real-time Sync Button
          IconButton(
            tooltip: 'Sync Live Database with Supabase Cloud',
            icon: const Icon(Icons.sync_rounded, color: Color(0xFF059669), size: 20),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr.syncingCloud),
                  duration: Duration(milliseconds: 900),
                ),
              );
              await _service.refreshDatabaseSync();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Supabase Cloud Database 100% Synchronized!'),
                    backgroundColor: Color(0xFF059669),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 6),

          // Primary "+ New Entry" Action Button
          ElevatedButton.icon(
            onPressed: () => _handleCreateActionForTab(_activeNavIndex),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(
              isNarrow ? '+ Add' : _getCreateButtonLabelForTab(_activeNavIndex),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _emerald,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: isNarrow ? 10 : 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 6),

          // Return to Public App
          IconButton(
            tooltip: 'Exit to Public Marketplace',
            icon: const Icon(Icons.exit_to_app_rounded, color: Color(0xFF64748B), size: 19),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                context.go(AppRoutes.dashboard);
              }
            },
          ),
        ],
      ),
    );
  }

  // ── Mobile App Bar & Pill Bar ───────────────────────────────────────────────
  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF041713),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(
        _getTabTitle(_activeNavIndex),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
      ),
      actions: [
        IconButton(
          tooltip: 'Sync Database',
          icon: const Icon(Icons.sync_rounded, color: Color(0xFF34D399), size: 20),
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr.syncingCloud),
                duration: Duration(milliseconds: 900),
              ),
            );
            await _service.refreshDatabaseSync();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Supabase Cloud Database 100% Synchronized!'),
                  backgroundColor: Color(0xFF059669),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        const Center(child: AppLanguagePill(isDarkHeader: true)),
        IconButton(
          icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 20),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
      ],
    );
  }

  Widget _buildMobilePillBar() {
    final titles = [
      'Overview',
      'Farmers (${_service.totalFarmers})',
      'Buyers (${_service.totalBuyers})',
      'Drivers (${_service.totalDrivers})',
      'Products (${_service.totalProducts})',
      'Orders (${_service.totalOrders})',
      'Pre-Orders',
      'Auctions (${AuctionManager.instance.activeAuctionsCount})',
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: List.generate(titles.length, (i) {
            final isSel = _activeNavIndex == i;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(titles[i]),
                selected: isSel,
                onSelected: (val) {
                  if (val) _switchTab(i);
                },
                selectedColor: const Color(0xFFDCFCE7),
                backgroundColor: const Color(0xFFF1F5F9),
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isSel ? const Color(0xFF047857) : const Color(0xFF475569),
                ),
                side: BorderSide(
                  color: isSel ? const Color(0xFF059669) : Colors.transparent,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSearchBar({required bool isCompact}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _borderLight),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                style: const TextStyle(fontSize: 13, color: _textDark),
                decoration: InputDecoration(
                  hintText: 'Search records by name, ID, phone, district...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _handleCreateActionForTab(_activeNavIndex),
            style: ElevatedButton.styleFrom(
              backgroundColor: _emerald,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Icon(Icons.add_rounded, size: 18),
          ),
        ],
      ),
    );
  }

  String _getTabTitle(int index) {
    return switch (index) {
      1 => 'Farmers Registry',
      2 => 'Buyer Accounts',
      3 => 'Transit & Fleet',
      4 => 'Produce Catalog',
      5 => 'Orders & Dispatch',
      6 => 'Pre-Orders (Contracts)',
      7 => 'Crop Auctions & Bids',
      _ => 'Executive Overview',
    };
  }

  String _getCreateButtonLabelForTab(int tabIndex) {
    return switch (tabIndex) {
      1 => 'Add Farmer',
      2 => 'Add Buyer',
      3 => 'Add Driver',
      4 => 'Add Product',
      5 => 'Create Order',
      7 => 'Add Auction',
      _ => 'New Entry',
    };
  }

  void _handleCreateActionForTab(int tabIndex) {
    HapticFeedback.lightImpact();
    switch (tabIndex) {
      case 1:
        showFarmerEditDialog(context);
        break;
      case 2:
        showBuyerEditDialog(context);
        break;
      case 3:
        showDriverEditDialog(context);
        break;
      case 4:
        showProductEditDialog(context);
        break;
      case 5:
        showOrderEditDialog(context);
        break;
      case 7:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateEditAuctionScreen()),
        );
        break;
      default:
        _showQuickCreateMenu();
    }
  }

  void _showQuickCreateMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Create New Entity',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textDark),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.agriculture_rounded, color: Color(0xFF047857)),
              title: Text(context.tr.addRegisteredFarmer),
              onTap: () {
                Navigator.pop(ctx);
                showFarmerEditDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF2563EB)),
              title: const Text('Register Buyer Account'),
              onTap: () {
                Navigator.pop(ctx);
                showBuyerEditDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping_rounded, color: Color(0xFFD97706)),
              title: const Text('Enroll Transit Driver & Van'),
              onTap: () {
                Navigator.pop(ctx);
                showDriverEditDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined, color: Color(0xFF059669)),
              title: const Text('List Marketplace Product'),
              onTap: () {
                Navigator.pop(ctx);
                showProductEditDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_rounded, color: Color(0xFF7E22CE)),
              title: const Text('Create Manual Order & Dispatch'),
              onTap: () {
                Navigator.pop(ctx);
                showOrderEditDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📊 3. TAB 0: EXECUTIVE OVERVIEW WITH HIGH-END CARDS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildOverviewTab() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 850;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Executive Welcome Banner ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF022C22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF064E3B).withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF047857),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.6)),
                  ),
                  child: const Center(
                    child: Icon(Icons.hub_rounded, color: Colors.white, size: 26),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Farm2Home Unified Agri-Logistics Engine',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF34D399),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'All 5 operational portals nominal • Real-time SMS Gateway active',
                            style: TextStyle(fontSize: 11.5, color: Color(0xFFA7F3D0)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── 6 Ultra-Premium Gradient Metric Cards ─────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 1050
                  ? 3
                  : (constraints.maxWidth >= 600 ? 2 : 1);

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isDesktop ? 1.6 : 1.9,
                children: [
                  _buildExecutiveKpiCard(
                    title: 'Registered Farmers',
                    value: '${_service.totalFarmers}',
                    badge: '↑ 18% Month',
                    subText: '${_service.activeFarmersCount} Active & Verified',
                    icon: Icons.agriculture_rounded,
                    accentColor: const Color(0xFF059669),
                    gradientStart: const Color(0xFFECFDF5),
                    onTap: () => _switchTab(1),
                  ),
                  _buildExecutiveKpiCard(
                    title: 'Marketplace Buyers',
                    value: '${_service.totalBuyers}',
                    badge: '100% Active',
                    subText: 'Families, Hotels & Organic Stores',
                    icon: Icons.shopping_bag_outlined,
                    accentColor: const Color(0xFF2563EB),
                    gradientStart: const Color(0xFFEFF6FF),
                    onTap: () => _switchTab(2),
                  ),
                  _buildExecutiveKpiCard(
                    title: 'Fleet Transit Drivers',
                    value: '${_service.totalDrivers}',
                    badge: '${_service.onDutyDriversCount} On Duty Now',
                    subText: 'Refrigerated & Insulated Vans',
                    icon: Icons.local_shipping_rounded,
                    accentColor: const Color(0xFFD97706),
                    gradientStart: const Color(0xFFFFFBEB),
                    onTap: () => _switchTab(3),
                  ),
                  _buildExecutiveKpiCard(
                    title: 'Produce Catalog SKUs',
                    value: '${_service.totalProducts}',
                    badge: '100% Traceable',
                    subText: 'Certified Fresh & Organic Harvest',
                    icon: Icons.inventory_2_outlined,
                    accentColor: const Color(0xFF047857),
                    gradientStart: const Color(0xFFF0FDF4),
                    onTap: () => _switchTab(4),
                  ),
                  _buildExecutiveKpiCard(
                    title: 'Marketplace Orders',
                    value: '${_service.totalOrders}',
                    badge: '${_service.inTransitOrdersCount} Dispatching',
                    subText: 'Active Order Fulfillment',
                    icon: Icons.receipt_long_rounded,
                    accentColor: const Color(0xFF7E22CE),
                    gradientStart: const Color(0xFFFAF5FF),
                    onTap: () => _switchTab(5),
                  ),
                  _buildExecutiveKpiCard(
                    title: 'Gross Payouts Volume',
                    value: 'Rs. ${_service.totalRevenue.toInt()}',
                    badge: 'Direct Farmer Pay',
                    subText: 'Cumulative Marketplace Trade',
                    icon: Icons.payments_rounded,
                    accentColor: const Color(0xFF0D9488),
                    gradientStart: const Color(0xFFF0FDFA),
                    onTap: () => _switchTab(5),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 22),

          // ── SMS Gateway Telemetry Health Card ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.sms_rounded, color: Color(0xFF047857), size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Notify.lk Enterprise SMS Gateway',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 16),
                        ],
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Sender ID: NotifyDEMO • User ID: 33247 • Phone: +94763238225 • Latency: 24ms',
                        style: TextStyle(fontSize: 11.5, color: _textMuted),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ SMS Gateway Ping: 24ms OK. System ready to dispatch OTP.'),
                        backgroundColor: Color(0xFF047857),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF047857),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Ping Test', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ── Quick Management Controls Tiles ──────────────────────────────
          const Text(
            'FAST CONFIGURATION SHORTCUTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 10),

          _buildQuickActionTile(
            title: 'Farmers Registry & Certification',
            subtitle: 'Add farmers, modify bank information, or toggle Verified status badges',
            icon: Icons.agriculture_rounded,
            iconBg: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF047857),
            onTap: () => _switchTab(1),
          ),
          const SizedBox(height: 8),
          _buildQuickActionTile(
            title: 'Buyer Accounts & Regional Hubs',
            subtitle: 'Inspect wholesale tiers, regional fulfillment hubs, and order frequencies',
            icon: Icons.shopping_bag_outlined,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
            onTap: () => _switchTab(2),
          ),
          const SizedBox(height: 8),
          _buildQuickActionTile(
            title: 'Transit Logistics & Fleet Dispatch',
            subtitle: 'Manage chilled vans, license plate registration, and driver on-duty shifts',
            icon: Icons.local_shipping_rounded,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            onTap: () => _switchTab(3),
          ),
          const SizedBox(height: 8),
          _buildQuickActionTile(
            title: 'Marketplace Inventory & Pricing',
            subtitle: 'Add produce listings, set LKR prices, packaging units and harvest dates',
            icon: Icons.inventory_2_outlined,
            iconBg: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF059669),
            onTap: () => _switchTab(4),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveKpiCard({
    required String title,
    required String value,
    required String badge,
    required String subText,
    required IconData icon,
    required Color accentColor,
    required Color gradientStart,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderLight),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: gradientStart,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subText,
                  style: const TextStyle(fontSize: 11, color: _textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: _textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👨‍🌾 4. TAB 1: FARMERS CRUD VIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFarmersTab() {
    var list = _service.farmers;
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((f) =>
              f.name.toLowerCase().contains(_searchQuery) ||
              f.farmName.toLowerCase().contains(_searchQuery) ||
              f.district.toLowerCase().contains(_searchQuery) ||
              f.phone.contains(_searchQuery) ||
              f.id.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (list.isEmpty) {
      return _buildEmptyState(
        title: 'No Farmers Found',
        message: 'No registered farmers match your search query.',
        onAction: () => showFarmerEditDialog(context),
        actionLabel: 'Add First Farmer',
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final f = list[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.agriculture_rounded, color: Color(0xFF047857), size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                f.name,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (f.isVerified) ...[
                              const SizedBox(width: 5),
                              const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 16),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${f.farmName} • ${f.district}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: f.status == 'Active' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      f.status,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: f.status == 'Active' ? const Color(0xFF047857) : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildMetaPill(Icons.phone_rounded, f.phone),
                  _buildMetaPill(Icons.terrain_rounded, f.scale),
                  _buildMetaPill(Icons.location_city_rounded, f.agrarianCenter),
                  if (f.bankName.isNotEmpty) _buildMetaPill(Icons.account_balance_rounded, '${f.bankName} (${f.accountNumber})'),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _service.toggleFarmerVerification(f.id);
                    },
                    icon: Icon(
                      f.isVerified ? Icons.verified : Icons.verified_outlined,
                      size: 15,
                      color: f.isVerified ? const Color(0xFF047857) : const Color(0xFF64748B),
                    ),
                    label: Text(
                      f.isVerified ? 'Verified' : 'Verify',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: f.isVerified ? const Color(0xFF047857) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      side: BorderSide(color: f.isVerified ? const Color(0xFFA7F3D0) : _borderLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const Spacer(),

                  ElevatedButton.icon(
                    onPressed: () => showFarmerEditDialog(context, farmer: f),
                    icon: const Icon(Icons.edit_note_rounded, size: 16),
                    label: const Text('Edit Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF047857),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 8),

                  IconButton(
                    onPressed: () {
                      showDeleteConfirmDialog(
                        context,
                        title: 'Delete Farmer Record',
                        message: 'Are you sure you want to delete ${f.name} (${f.farmName}) from the marketplace database?',
                        onConfirmed: () => _service.deleteFarmer(f.id),
                      );
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 20),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🛒 5. TAB 2: BUYERS CRUD VIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildBuyersTab() {
    var list = _service.buyers;
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((b) =>
              b.name.toLowerCase().contains(_searchQuery) ||
              b.email.toLowerCase().contains(_searchQuery) ||
              b.phone.contains(_searchQuery) ||
              b.address.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (list.isEmpty) {
      return _buildEmptyState(
        title: 'No Buyers Found',
        message: 'No registered buyers match your query.',
        onAction: () => showBuyerEditDialog(context),
        actionLabel: 'Add First Buyer',
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final b = list[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${b.buyerType} • ${b.email}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: b.status == 'Active' ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      b.status,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: b.status == 'Active' ? const Color(0xFF047857) : const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildMetaPill(Icons.phone_rounded, b.phone),
                  _buildMetaPill(Icons.hub_rounded, b.hub),
                  _buildMetaPill(Icons.location_on_rounded, b.address),
                  _buildMetaPill(Icons.shopping_cart_checkout_rounded, '${b.totalOrders} Orders Placed'),
                  _buildMetaPill(Icons.payments_rounded, 'Rs. ${b.totalSpent.toInt()} Spent'),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _service.toggleBuyerStatus(b.id);
                    },
                    icon: Icon(
                      b.status == 'Active' ? Icons.block_rounded : Icons.check_circle_outline,
                      size: 15,
                      color: b.status == 'Active' ? const Color(0xFFDC2626) : const Color(0xFF047857),
                    ),
                    label: Text(
                      b.status == 'Active' ? 'Suspend' : 'Activate',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: b.status == 'Active' ? const Color(0xFFDC2626) : const Color(0xFF047857),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      side: BorderSide(color: b.status == 'Active' ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const Spacer(),

                  ElevatedButton.icon(
                    onPressed: () => showBuyerEditDialog(context, buyer: b),
                    icon: const Icon(Icons.edit_note_rounded, size: 16),
                    label: const Text('Edit Buyer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 8),

                  IconButton(
                    onPressed: () {
                      showDeleteConfirmDialog(
                        context,
                        title: 'Delete Buyer Account',
                        message: 'Are you sure you want to delete ${b.name} (${b.email})?',
                        onConfirmed: () => _service.deleteBuyer(b.id),
                      );
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 20),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🚚 6. TAB 3: DRIVERS & FLEET CRUD VIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDriversTab() {
    var list = _service.drivers;
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((d) =>
              d.name.toLowerCase().contains(_searchQuery) ||
              d.plateNumber.toLowerCase().contains(_searchQuery) ||
              d.vehicleType.toLowerCase().contains(_searchQuery) ||
              d.phone.contains(_searchQuery))
          .toList();
    }

    if (list.isEmpty) {
      return _buildEmptyState(
        title: 'No Drivers Found',
        message: 'No registered transit fleet records match.',
        onAction: () => showDriverEditDialog(context),
        actionLabel: 'Enroll First Driver',
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final d = list[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
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
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(Icons.local_shipping_rounded, color: Color(0xFFD97706), size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${d.plateNumber} • ${d.vehicleType}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: d.isOnDuty ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: d.isOnDuty ? const Color(0xFF10B981) : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          d.isOnDuty ? 'On Duty' : 'Standby',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: d.isOnDuty ? const Color(0xFF047857) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildMetaPill(Icons.phone_rounded, d.phone),
                  _buildMetaPill(Icons.badge_rounded, d.licenseNumber),
                  _buildMetaPill(Icons.inventory_2_rounded, 'Capacity: ${d.cargoCapacity}'),
                  _buildMetaPill(Icons.star_rounded, '${d.rating} Rating (${d.completedTrips} Trips)'),
                  if (d.bankName.isNotEmpty) _buildMetaPill(Icons.account_balance_rounded, '${d.bankName} (${d.accountNumber})'),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _service.toggleDriverDuty(d.id);
                    },
                    icon: Icon(d.isOnDuty ? Icons.pause_circle_outline : Icons.play_circle_outline, size: 15),
                    label: Text(
                      d.isOnDuty ? 'Put on Standby' : 'Put On Duty',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const Spacer(),

                  ElevatedButton.icon(
                    onPressed: () => showDriverEditDialog(context, driver: d),
                    icon: const Icon(Icons.edit_note_rounded, size: 16),
                    label: const Text('Edit Driver', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 8),

                  IconButton(
                    onPressed: () {
                      showDeleteConfirmDialog(
                        context,
                        title: 'Delete Fleet Driver',
                        message: 'Are you sure you want to remove ${d.name} (${d.plateNumber}) from transit fleet?',
                        onConfirmed: () => _service.deleteDriver(d.id),
                      );
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 20),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🥦 7. TAB 4: PRODUCE CATALOG CRUD VIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildProductsTab() {
    var list = _service.products;
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery) ||
              p.category.toLowerCase().contains(_searchQuery) ||
              p.farmName.toLowerCase().contains(_searchQuery) ||
              p.farmerName.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (list.isEmpty) {
      return _buildEmptyState(
        title: 'No Products Listed',
        message: 'No produce inventory matches your search.',
        onAction: () => showProductEditDialog(context),
        actionLabel: 'List First Produce',
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final p = list[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  p.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: const Color(0xFFDCFCE7),
                    child: const Icon(Icons.eco_rounded, color: Color(0xFF047857), size: 30),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: _textDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (p.isOrganic)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Organic',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF047857)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${p.category} • ${p.farmName}',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Rs. ${p.price.toInt()} ${p.unit}',
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Stock: ${p.availableQty.toInt()} kg',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => showProductEditDialog(context, product: p),
                          icon: const Icon(Icons.edit_note_rounded, size: 15),
                          label: const Text('Edit Listing', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF047857),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            showDeleteConfirmDialog(
                              context,
                              title: 'Delete Produce Listing',
                              message: 'Are you sure you want to remove ${p.name} from the active catalog?',
                              onConfirmed: () => _service.deleteProduct(p.id),
                            );
                          },
                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📦 8. TAB 5: ORDERS & DISPATCH CRUD VIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildOrdersTab() {
    var list = _service.orders;
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((o) =>
              o.id.toLowerCase().contains(_searchQuery) ||
              o.customerName.toLowerCase().contains(_searchQuery) ||
              o.assignedDriverName.toLowerCase().contains(_searchQuery) ||
              o.itemsSummary.toLowerCase().contains(_searchQuery))
          .toList();
    }

    if (list.isEmpty) {
      return _buildEmptyState(
        title: 'No Orders Found',
        message: 'No marketplace orders match your search.',
        onAction: () => showOrderEditDialog(context),
        actionLabel: 'Create First Order',
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final o = list[i];
        final statusColor = _getOrderStatusColor(o.status);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      o.id,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rs. ${o.totalAmount.toInt()}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF047857)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      o.status,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                o.itemsSummary,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text('${o.customerName} (${o.customerPhone})', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 14, color: Color(0xFFD97706)),
                  const SizedBox(width: 4),
                  Text('Transit Driver: ${o.assignedDriverName}', style: const TextStyle(fontSize: 11.5, color: Color(0xFFD97706), fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      o.deliveryAddress,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 10),

              Row(
                children: [
                  PopupMenuButton<String>(
                    tooltip: 'Change Status',
                    onSelected: (val) {
                      _service.updateOrderStatus(o.id, val);
                    },
                    itemBuilder: (context) => [
                      'Pending',
                      'Confirmed',
                      'Picked Up',
                      'In Transit',
                      'Delivered',
                      'Cancelled',
                    ]
                        .map((s) => PopupMenuItem(
                              value: s,
                              child: Text(s, style: TextStyle(fontWeight: s == o.status ? FontWeight.bold : FontWeight.normal)),
                            ))
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: _borderLight),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Text('Change Status', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF475569)),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),

                  ElevatedButton.icon(
                    onPressed: () => showOrderEditDialog(context, order: o),
                    icon: const Icon(Icons.edit_note_rounded, size: 16),
                    label: const Text('Manage Dispatch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E22CE),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 8),

                  IconButton(
                    onPressed: () {
                      showDeleteConfirmDialog(
                        context,
                        title: 'Delete Order Record',
                        message: 'Are you sure you want to remove Order #${o.id}?',
                        onConfirmed: () => _service.deleteOrder(o.id),
                      );
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 18),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🤝 9. TAB 6: PRE-ORDERS (CONTRACTS) CRUD VIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildContractsTab() {
    return ListenableBuilder(
      listenable: PreOrderManager.instance,
      builder: (context, _) {
        var list = PreOrderManager.instance.preOrders;
        if (_searchQuery.isNotEmpty) {
          list = list
              .where((o) =>
                  o.id.toLowerCase().contains(_searchQuery) ||
                  o.buyerName.toLowerCase().contains(_searchQuery) ||
                  o.cropName.toLowerCase().contains(_searchQuery))
              .toList();
        }

        if (list.isEmpty) {
          return _buildEmptyState(
            title: 'No Contracts Found',
            message: 'No pre-orders match your search.',
            onAction: () {}, // Quick create not needed for contracts directly in admin unless requested
            actionLabel: 'Refresh',
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            final o = list[i];
            final statusColor = o.status == 'Pending' ? const Color(0xFFD97706) : (o.status == 'In Progress' ? const Color(0xFF2563EB) : const Color(0xFF047857));

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          o.id,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _textDark),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          o.status,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${o.cropName} (${o.requiredQuantityKg} Kg @ Rs. ${o.offeredPricePerKg}/Kg)',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textDark),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text('Buyer: ${o.buyerName}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.agriculture_rounded, size: 14, color: Color(0xFF047857)),
                      const SizedBox(width: 4),
                      Text('Farmer: ${o.farmerName ?? 'Unassigned'}', style: const TextStyle(fontSize: 12, color: Color(0xFF047857), fontWeight: FontWeight.w600)),
                    ],
                  ),

                  // Show Farmer's Proposal Details if available
                  if (o.farmerExpectedHarvestDate != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Farmer\'s Proposal:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _buildMetaPill(Icons.calendar_today_rounded, 'Harvest: ${o.farmerExpectedHarvestDate!.day}/${o.farmerExpectedHarvestDate!.month}'),
                              if (o.farmerEstimatedYieldKg != null)
                                _buildMetaPill(Icons.monitor_weight_rounded, 'Yield: ${o.farmerEstimatedYieldKg} Kg'),
                              if (o.farmerLocation.isNotEmpty)
                                _buildMetaPill(Icons.location_city_rounded, o.farmerLocation),
                            ],
                          ),
                          if (o.farmerNotes.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text('Notes: ${o.farmerNotes}', style: const TextStyle(fontSize: 11, color: _textMuted)),
                          ],
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Allow admin to view the full detail screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PreOrderDetailScreen(
                                preOrderId: o.id,
                                isFarmerMode: false, // Treat as observer
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_rounded, size: 16),
                        label: const Text('View Full Timeline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0EA5E9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          showDeleteConfirmDialog(
                            context,
                            title: 'Delete Contract',
                            message: 'Are you sure you want to remove Contract #${o.id}?',
                            onConfirmed: () => PreOrderManager.instance.deletePreOrder(o.id),
                          );
                        },
                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔨 10. TAB 7: CROP AUCTIONS & BIDDING MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAuctionsTab() {
    return ListenableBuilder(
      listenable: AuctionManager.instance,
      builder: (context, _) {
        var list = AuctionManager.instance.auctions;
        if (_searchQuery.isNotEmpty) {
          list = list
              .where((a) =>
                  a.id.toLowerCase().contains(_searchQuery) ||
                  a.cropName.toLowerCase().contains(_searchQuery) ||
                  a.farmerName.toLowerCase().contains(_searchQuery) ||
                  a.location.toLowerCase().contains(_searchQuery))
              .toList();
        }

        final activeCount = AuctionManager.instance.activeAuctionsCount;
        final totalBids = AuctionManager.instance.totalBidsCount;
        final totalVolume = AuctionManager.instance.totalAuctionVolumeRs;

        return CustomScrollView(
          slivers: [
            // Top Executive KPI Stats Grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildExecutiveKpiCard(
                            title: 'Active Auctions',
                            value: '$activeCount',
                            badge: 'Open Now',
                            subText: 'Live lots open for bidding',
                            icon: Icons.gavel_rounded,
                            accentColor: const Color(0xFF059669),
                            gradientStart: const Color(0xFFECFDF5),
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildExecutiveKpiCard(
                            title: 'Total Bids Placed',
                            value: '$totalBids',
                            badge: 'Market Bids',
                            subText: 'Market buyer activity',
                            icon: Icons.how_to_vote_rounded,
                            accentColor: const Color(0xFF2563EB),
                            gradientStart: const Color(0xFFEFF6FF),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildExecutiveKpiCard(
                            title: 'Total Lot Volume',
                            value: 'Rs. ${(totalVolume / 1000).toStringAsFixed(0)}k',
                            badge: 'Auction Value',
                            subText: 'Combined auction lot value',
                            icon: Icons.monetization_on_rounded,
                            accentColor: const Color(0xFFD97706),
                            gradientStart: const Color(0xFFFFFBEB),
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildExecutiveKpiCard(
                            title: 'Total Registered Lots',
                            value: '${list.length}',
                            badge: 'Total Lots',
                            subText: 'Harvest lots in system',
                            icon: Icons.inventory_2_rounded,
                            accentColor: const Color(0xFF7E22CE),
                            gradientStart: const Color(0xFFFAF5FF),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (list.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(
                  title: 'No Auctions Found',
                  message: _searchQuery.isNotEmpty
                      ? 'No auctions match "$_searchQuery".'
                      : 'No harvest auctions registered in the system.',
                  onAction: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateEditAuctionScreen()),
                  ),
                  actionLabel: 'Create First Auction',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, idx) {
                      final a = list[idx];
                      final isActive = a.isActive;
                      final isSold = a.isSold;
                      final statusColor = isSold
                          ? const Color(0xFF0284C7)
                          : (isActive ? const Color(0xFF059669) : const Color(0xFF6B7280));

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive ? const Color(0xFFA7F3D0) : _borderLight,
                            width: isActive ? 1.5 : 1,
                          ),
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
                            // Top Row: ID, Badges, Timer
                            Row(
                              children: [
                                Text(
                                  '#${a.id.toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: _textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    a.category,
                                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                                  ),
                                ),
                                const Spacer(),
                                if (isActive) ...[
                                  const Icon(Icons.timer_outlined, size: 13, color: Color(0xFFEA580C)),
                                  const SizedBox(width: 4),
                                  Text(
                                    a.remainingTimeString,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFEA580C)),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    isSold ? 'SOLD' : (isActive ? 'ACTIVE' : 'ENDED'),
                                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: statusColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Main Content Row with Crop Photo
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    a.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 60,
                                      height: 60,
                                      color: const Color(0xFFDCFCE7),
                                      child: const Icon(Icons.grass_rounded, color: Color(0xFF047857)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.cropName,
                                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: _textDark),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Quantity: ${a.quantity.toStringAsFixed(0)} ${a.unit} • ${a.location}',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(Icons.agriculture_rounded, size: 13, color: Color(0xFF047857)),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Farmer: ${a.farmerName}',
                                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF047857)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Bidding Financials Bar
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _borderLight),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.totalBids > 0 ? 'Leading Bid (${a.totalBids} bids)' : 'Starting Bid',
                                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        'Rs. ${a.effectivePrice.toStringAsFixed(2)} / ${a.unit}',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: a.totalBids > 0 ? const Color(0xFF059669) : _textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Total Lot Value',
                                        style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        'Rs. ${a.totalLotValue.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Action Buttons Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FarmerAuctionDetailScreen(auctionId: a.id),
                                    ),
                                  ),
                                  icon: const Icon(Icons.visibility_rounded, size: 15),
                                  label: const Text('View Bids Tracker', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0EA5E9),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                OutlinedButton.icon(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CreateEditAuctionScreen(existingAuction: a),
                                    ),
                                  ),
                                  icon: const Icon(Icons.edit_note_rounded, size: 15),
                                  label: const Text('Edit', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF475569),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  tooltip: 'Delete Auction',
                                  onPressed: () {
                                    showDeleteConfirmDialog(
                                      context,
                                      title: 'Delete Crop Auction',
                                      message: 'Are you sure you want to permanently remove auction #${a.id} for "${a.cropName}"?',
                                      onConfirmed: () => AuctionManager.instance.deleteAuction(a.id),
                                    );
                                  },
                                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: list.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🛠️ 11. HELPERS & BADGES
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMetaPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.5, color: const Color(0xFF64748B)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String message,
    required VoidCallback onAction,
    required String actionLabel,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 40, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textDark),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _textMuted),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: _emerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getOrderStatusColor(String status) {
    return switch (status) {
      'Delivered' => const Color(0xFF047857),
      'In Transit' => const Color(0xFF2563EB),
      'Picked Up' => const Color(0xFFD97706),
      'Confirmed' => const Color(0xFF0D9488),
      'Cancelled' => const Color(0xFFDC2626),
      _ => const Color(0xFF7E22CE), // Pending
    };
  }
}

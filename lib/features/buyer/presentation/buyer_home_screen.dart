import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/localization/app_settings.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../../cart/models/cart_item_model.dart';
import '../../cart/services/cart_state.dart';
import '../data/buyer_mock_data.dart';
import '../models/buyer_models.dart';
import 'buyer_categories_screen.dart';
import 'buyer_search_screen.dart';
import 'buyer_product_list_screen.dart';
import 'buyer_product_detail_screen.dart';
import 'buyer_profile_screen.dart';
import 'buyer_notifications_screen.dart';
import 'buyer_cart_screen.dart';
import 'widgets/buyer_bottom_nav.dart';
import '../services/buyer_profile_manager.dart';
import '../services/buyer_notification_service.dart';

/// 9. Buyer Home Screen — matching Screenshot 9
class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  final MarketplaceState _cartState = MarketplaceState.instance;
  final BuyerProfileManager _profileManager = BuyerProfileManager.instance;
  final BuyerNotificationService _notifService =
      BuyerNotificationService.instance;
  late String _selectedCity;

  static const Color _forestGreen = Color(0xFF1B5E38);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _selectedCity = _profileManager.profile.topBarLocationDisplay;
    _cartState.addListener(_onCartChanged);
    _profileManager.addListener(_onProfileChanged);
    _notifService.addListener(_onNotifChanged);
    _profileManager.loadProfile();
  }

  @override
  void dispose() {
    _cartState.removeListener(_onCartChanged);
    _profileManager.removeListener(_onProfileChanged);
    _notifService.removeListener(_onNotifChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _onNotifChanged() {
    if (mounted) setState(() {});
  }

  void _onProfileChanged() {
    if (mounted) {
      setState(() {
        _selectedCity = _profileManager.profile.topBarLocationDisplay;
      });
    }
  }

  void _addBuyerProductToCart(BuyerProduct prod) {
    HapticFeedback.lightImpact();
    _cartState.addToCart(
      CartItem(
        id: prod.id,
        name: prod.name,
        price: prod.price,
        unit: '/${prod.unit}',
        quantity: 1,
        emoji: '🌿',
        farmName: prod.farmerName,
        imageUrl: prod.imageUrl,
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr.addedToCart(prod.name)),
        backgroundColor: _forestGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: context.tr.viewCart,
          textColor: const Color(0xFFFDE68A),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BuyerCartScreen()),
            );
          },
        ),
      ),
    );
  }

  void _showLocationPicker() {
    final cities = [
      'Colombo 02, Western',
      'Colombo 07, Western',
      'Kandy City, Central',
      'Galle Fort, Southern',
      'Nuwara Eliya, Central',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr.selectDeliveryLocation,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 12),
            ...cities.map(
              (c) => ListTile(
                leading: const Icon(Icons.location_on_rounded, color: _forestGreen),
                title: Text(
                  c,
                  style: TextStyle(
                    fontWeight: c == _selectedCity ? FontWeight.w700 : FontWeight.w500,
                    color: c == _selectedCity ? _forestGreen : _textDark,
                  ),
                ),
                trailing: c == _selectedCity
                    ? const Icon(Icons.check_circle_rounded, color: _forestGreen)
                    : null,
                onTap: () {
                  setState(() => _selectedCity = c);
                  _profileManager.updateProfile(address: c, hub: c);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = _cartState.totalItemCount;
    final profile = _profileManager.profile;

    return Scaffold(
      backgroundColor: _bgSoft,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    // Profile Avatar with initials and green online dot (opens BuyerProfileScreen)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BuyerProfileScreen(),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE8F5E9),
                              border: Border.all(color: const Color(0xFF16A34A), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                profile.initials,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _forestGreen,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFF16A34A),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Welcome Name & Deliver to location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr.welcomeBuyer(profile.name.trim().isNotEmpty ? profile.name.trim().split(' ').first : "Buyer"),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _textDark,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: _showLocationPicker,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 13,
                                  color: _forestGreen,
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    _selectedCity,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: _textMuted,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 14,
                                  color: _textMuted,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick Language Switcher Pill
                    const AppLanguagePill(),
                    const SizedBox(width: 8),

                    // Notification Bell Button with live badge
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BuyerNotificationsScreen()),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.notifications_none_rounded, size: 20, color: _textDark),
                          ),
                          if (_notifService.unreadCount > 0)
                            Positioned(
                              right: 1,
                              top: 1,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEA580C),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Cart Green Circle Button with Badge
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BuyerCartScreen()),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: _forestGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shopping_bag_outlined, size: 19, color: Colors.white),
                          ),
                          if (cartCount > 0)
                            Positioned(
                              right: -3,
                              top: -3,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEA580C),
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                child: Text(
                                  '$cartCount',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
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

            // Search Bar (Opens Search Screen)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BuyerSearchScreen()),
                  ),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: _textMuted, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.tr.searchPlaceholder,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const Icon(Icons.tune_rounded, color: _textMuted, size: 19),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Hero Promo Banner matching User's Reference
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 205,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D3820),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D3820).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Background Image: Freshly harvested carrots in wooden crate on field
                      Positioned.fill(
                        child: Image.network(
                          'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=1000&auto=format&fit=crop&q=80',
                          fit: BoxFit.cover,
                          alignment: Alignment.centerRight,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF0D3820),
                          ),
                        ),
                      ),
                      // Smooth gradient overlay from dark green on left to translucent on right
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF0D3820),
                                Color(0xFF0D3820),
                                Color(0xE60D3820),
                                Color(0x800D3820),
                                Color(0x260D3820),
                              ],
                              stops: [0.0, 0.40, 0.60, 0.82, 1.0],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top Pill Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E5232).withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF3B7A50),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.eco_rounded, size: 13, color: Color(0xFF4ADE80)),
                                  const SizedBox(width: 5),
                                  Text(
                                    context.tr.springHarvestFest,
                                    style: const TextStyle(
                                      color: Color(0xFF86EFAC),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Headline & Subheading
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr.promoHeadline,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  context.tr.promoSub,
                                  style: const TextStyle(
                                    color: Color(0xFFD1FAE5),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                            // CTA Button
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BuyerProductListScreen(
                                    categoryTitle: context.tr.categoryVegetables,
                                  ),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.12),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  context.tr.shopSeasonSpecials,
                                  style: const TextStyle(
                                    color: Color(0xFF0D3820),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.1,
                                  ),
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
            ),

            // Categories Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr.categories,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BuyerCategoriesScreen()),
                      ),
                      child: Text(
                        context.tr.seeAll,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _forestGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Horizontal Categories Icons Row matching Screenshot 9
            SliverToBoxAdapter(
              child: SizedBox(
                height: 82,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryRoundItem(
                      icon: Icons.eco_rounded,
                      label: context.tr.categoryVegetables,
                      color: const Color(0xFFE8F5E9),
                      iconColor: _forestGreen,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BuyerProductListScreen(categoryTitle: 'Vegetables'),
                        ),
                      ),
                    ),
                    _buildCategoryRoundItem(
                      icon: Icons.apple_rounded,
                      label: context.tr.categoryFruits,
                      color: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFEA580C),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BuyerProductListScreen(categoryTitle: 'Fruits'),
                        ),
                      ),
                    ),
                    _buildCategoryRoundItem(
                      icon: Icons.grain_rounded,
                      label: context.tr.categoryGrains,
                      color: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BuyerProductListScreen(categoryTitle: 'Grains & Rice'),
                        ),
                      ),
                    ),
                    _buildCategoryRoundItem(
                      icon: Icons.whatshot_rounded,
                      label: context.tr.categorySpices,
                      color: const Color(0xFFFEE2E2),
                      iconColor: const Color(0xFFDC2626),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BuyerProductListScreen(categoryTitle: 'Spices & Herbs'),
                        ),
                      ),
                    ),
                    _buildCategoryRoundItem(
                      icon: Icons.spa_rounded,
                      label: context.tr.categoryOrganic,
                      color: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF059669),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BuyerProductListScreen(categoryTitle: 'Organic & Traditional'),
                        ),
                      ),
                    ),
                    _buildCategoryRoundItem(
                      icon: Icons.water_drop_rounded,
                      label: context.tr.categoryDairy,
                      color: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0284C7),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BuyerProductListScreen(categoryTitle: 'Dairy & Farm Fresh'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Daily Harvest Deals Header with countdown timer
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded, color: Color(0xFFEA580C), size: 19),
                        const SizedBox(width: 4),
                        Text(
                          context.tr.dailyHarvestDeals,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFEDD5)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.timer_outlined, size: 12, color: Color(0xFFEA580C)),
                          SizedBox(width: 4),
                          Text(
                            '04:18:22',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFEA580C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Daily Harvest Deals Horizontal Cards
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: BuyerMockData.dailyDeals.map((prod) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _buildDealCard(
                        product: prod,
                        discountTag: prod.badge ?? 'Fresh Pick',
                        onAdd: () => _addBuyerProductToCart(prod),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Popular Right Now Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr.popularRightNow,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr.verifiedFreshPartner,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BuyerSearchScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.tune_rounded, size: 12, color: _textDark),
                            const SizedBox(width: 4),
                            Text(
                              context.tr.filter,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _textDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Popular Right Now Grid (2x2 matching Screenshot 9)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final prod = BuyerMockData.popularProducts[index];
                    return _buildPopularProductCard(
                      product: prod,
                      onAdd: () => _addBuyerProductToCart(prod),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BuyerProductDetailScreen(product: prod),
                        ),
                      ),
                    );
                  },
                  childCount: BuyerMockData.popularProducts.length,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BuyerBottomNav(selectedIndex: 0),
    );
  }

  Widget _buildCategoryRoundItem({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDealCard({
    required BuyerProduct product,
    required String discountTag,
    required VoidCallback onAdd,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BuyerProductDetailScreen(product: product),
        ),
      ),
      child: Container(
        width: 172,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  product.imageUrl,
                  height: 105,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      discountTag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
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
                    '${product.farmerName} (${product.farmLocation})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.formattedPrice,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _forestGreen,
                            ),
                          ),
                          if (product.originalPrice != null)
                            Text(
                              product.formattedOriginalPrice,
                              style: const TextStyle(
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onAdd,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _forestGreen,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            '+ Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
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
      ),
    );
  }

  Widget _buildPopularProductCard({
    required BuyerProduct product,
    required VoidCallback onAdd,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  if (product.badge != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.badgeColor ?? const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.formattedPrice,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _forestGreen,
                        ),
                      ),
                      GestureDetector(
                        onTap: onAdd,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: _forestGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, size: 16, color: Colors.white),
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
    );
  }
}

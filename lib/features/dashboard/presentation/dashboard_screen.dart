import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../../../core/constants/constants.dart';
import '../../cart/models/cart_item_model.dart';
import '../../cart/presentation/my_cart_screen.dart';
import '../../cart/services/cart_state.dart';
import '../../orders_chat/presentation/orders_chat_screen.dart';
import '../../orders_chat/presentation/chat_list_screen.dart';
import '../../pre_order/presentation/pre_order_list_screen.dart';
import '../../search/presentation/search_filter_screen.dart';
import '../../auction/presentation/buyer/buyer_auction_list_screen.dart';
import 'farmer_profile_screen.dart';
import 'product_detail_screen.dart';

/// Premium Dashboard / Home screen — Farm2Home matching Image 1
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _selectedCategory = 0;
  int _selectedNav = 0;
  final Set<int> _wishlist = {};
  String _selectedCity = 'Colombo, Sri Lanka';

  late final AnimationController _headerController;
  late final Animation<double> _headerFade;

  static const Color _forestGreen = Color(0xFF1B5E38);
  static const Color _bgSoft = Color(0xFFF9FBFA);
  static const Color _textDark = Color(0xFF1E293B);

  static const _categories = [
    (
      'All',
      Icons.grid_view_rounded,
      'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=120&auto=format&fit=crop&q=80',
    ),
    (
      'Vegetables',
      Icons.eco_rounded,
      'https://images.unsplash.com/photo-1584270354949-c26b0d5b4a0c?w=120&auto=format&fit=crop&q=80',
    ),
    (
      'Fruits',
      Icons.apple_rounded,
      'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=120&auto=format&fit=crop&q=80',
    ),
    (
      'Grains',
      Icons.grass_rounded,
      'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=120&auto=format&fit=crop&q=80',
    ),
    (
      'Spices',
      Icons.whatshot_rounded,
      'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=120&auto=format&fit=crop&q=80',
    ),
    (
      'Dairy & Eggs',
      Icons.egg_rounded,
      'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=120&auto=format&fit=crop&q=80',
    ),
  ];

  static const _defaultFarmer = FarmerData.defaultFarmer;

  // Products matching Image 1 exactly with high-definition photography
  static const _products = [
    ProductData(
      name: 'Tomatoes',
      price: 'Rs. 250',
      unit: '/kg',
      rating: '4.7',
      reviews: '32',
      availability: 'Available: 25 kg',
      emoji: '🍅',
      imageUrl:
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80',
      tag: 'Bestseller',
      tagColor: Color(0xFFFF6B35),
      description:
          'Fresh and naturally grown heirloom tomatoes from our Hambantota farm. No chemicals, 100% organic and rich in flavor.',
      harvestDate: '18 Aug 2026',
      tags: ['Organic', 'Fresh'],
      category: 'Vegetables',
      farmer: _defaultFarmer,
    ),
    ProductData(
      name: 'Carrots',
      price: 'Rs. 300',
      unit: '/kg',
      rating: '4.6',
      reviews: '28',
      availability: 'Available: 15 kg',
      emoji: '🥕',
      imageUrl:
          'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500&auto=format&fit=crop&q=80',
      tag: 'Fresh',
      tagColor: Color(0xFF1E8342),
      description:
          'Crispy sweet carrots cultivated in natural mineral-rich soil. High in beta-carotene and fiber, washed and packed fresh on harvest morning.',
      harvestDate: '19 Aug 2026',
      tags: ['Organic', 'Farm Fresh'],
      category: 'Vegetables',
      farmer: _defaultFarmer,
    ),
    ProductData(
      name: 'Potatoes',
      price: 'Rs. 220',
      unit: '/kg',
      rating: '4.8',
      reviews: '45',
      availability: 'Available: 40 kg',
      emoji: '🥔',
      imageUrl:
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=80',
      tag: null,
      tagColor: null,
      description:
          'Earthy Sri Lankan highland potatoes. Perfect for curries, baking, or roasting. Harvested at peak maturity for rich starch and taste.',
      harvestDate: '16 Aug 2026',
      tags: ['Highland', 'Natural'],
      category: 'Vegetables',
      farmer: _defaultFarmer,
    ),
    ProductData(
      name: 'Bell Peppers',
      price: 'Rs. 380',
      unit: '/kg',
      rating: '4.9',
      reviews: '19',
      availability: 'Available: 12 kg',
      emoji: '🫑',
      imageUrl:
          'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=500&auto=format&fit=crop&q=80',
      tag: 'Premium',
      tagColor: Color(0xFF8B5CF6),
      description:
          'Vibrant green bell peppers with thick crunchy walls and naturally sweet taste. Carefully nurtured in organic greenhouse conditions.',
      harvestDate: '20 Aug 2026',
      tags: ['Greenhouse', 'Premium'],
      category: 'Vegetables',
      farmer: _defaultFarmer,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _headerFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  void _showLocationPicker() {
    final cities = [
      'Colombo, Sri Lanka',
      'Kandy, Sri Lanka',
      'Galle, Sri Lanka',
      'Hambantota, Sri Lanka',
      'Nuwara Eliya, Sri Lanka',
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
            const Text(
              'Select Delivery Location',
              style: TextStyle(
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
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSheet() {
    final notifications = [
      ('🍅 Tomatoes Harvest Alert', 'Sunil Perera harvested 25kg fresh tomatoes this morning.', '10m ago'),
      ('🚚 Order #FT-8291 Update', 'Your fresh farm order is now out for delivery.', '45m ago'),
      ('🥕 Spring Harvest Fest', 'Enjoy up to 25% off on fresh organic carrots & greens.', '2h ago'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Mark all as read'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...notifications.map(
              (n) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(n.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _textDark)),
                        Text(n.$3, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(n.$2, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
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
    // Filter products if category selected (0 = All)
    final displayedProducts = _selectedCategory == 0
        ? _products
        : _products
            .where((p) =>
                p.category.toLowerCase() ==
                _categories[_selectedCategory].$1.toLowerCase())
            .toList();

    return Scaffold(
      backgroundColor: _bgSoft,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Premium App Bar matching Image 1 ───────────────────────────────
          _PremiumSliverAppBar(
            headerFade: _headerFade,
            city: _selectedCity,
            onLocationTap: _showLocationPicker,
            onNotificationTap: _showNotificationSheet,
            onAvatarTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FarmerProfileScreen(farmer: _defaultFarmer),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Search Bar ──────────────────────────────────────────────
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _PremiumSearchBar(),
                ),

                const SizedBox(height: 18),



                // ── Promo Banner matching Image 1 ───────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _PromoBanner(
                    onShopSpecials: () {
                      setState(() => _selectedCategory = 0);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Showing Spring Harvest specials!'),
                          backgroundColor: _forestGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ── Categories Header matching Image 1 ──────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedCategory = 0);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: _forestGreen,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Categories Row matching Image 1
                SizedBox(
                  height: 98,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, i) {
                      final (label, icon, imgUrl) = _categories[i];
                      final isSelected = i == _selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedCategory = i);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: _CategoryChip(
                            label: label,
                            icon: icon,
                            imageUrl: imgUrl,
                            isSelected: isSelected,
                            isAll: i == 0,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 22),

                // ── Popular Products Header matching Image 1 ────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Popular Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchFilterScreen(),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: _forestGreen,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Products 2x2 Grid with Real Photography matching Image 1
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.74,
                    ),
                    itemCount: displayedProducts.length,
                    itemBuilder: (context, i) {
                      final product = displayedProducts[i];
                      final originalIndex = _products.indexOf(product);

                      return _PremiumProductCard(
                        product: product,
                        isWishlisted: _wishlist.contains(originalIndex),
                        onWishlistToggle: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            if (_wishlist.contains(originalIndex)) {
                              _wishlist.remove(originalIndex);
                            } else {
                              _wishlist.add(originalIndex);
                            }
                          });
                        },
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ── Fresh From Farmers card ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _FreshFromFarmersCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const FarmerProfileScreen(farmer: _defaultFarmer),
                      ),
                    ),
                  ),
                ),



                const SizedBox(height: 110),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fab_auction_buyer',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BuyerAuctionListScreen(),
                ),
              );
            },
            backgroundColor: const Color(0xFF1E5E3A),
            icon: const Icon(Icons.gavel_rounded, color: Colors.white, size: 18),
            label: const Text('Auctions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.extended(
            heroTag: 'fab_contract_buyer',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PreOrderListScreen(isFarmerMode: false),
                ),
              );
            },
            backgroundColor: const Color(0xFF047857),
            icon: const Icon(Icons.handshake_rounded, color: Colors.white, size: 18),
            label: const Text('Contracts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      // ── Premium Bottom Navigation matching Image 1 ─────────────────────────
      bottomNavigationBar: _PremiumBottomNav(
        selectedIndex: _selectedNav,
        onTap: (i) {
          if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OrdersChatScreen(initialTab: 0),
              ),
            );
          } else if (i == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChatListScreen(),
              ),
            );
          } else if (i == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const FarmerProfileScreen(farmer: _defaultFarmer),
              ),
            );
          } else {
            setState(() => _selectedNav = i);
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Sliver App Bar matching Image 1
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumSliverAppBar extends StatelessWidget {
  const _PremiumSliverAppBar({
    required this.headerFade,
    required this.city,
    required this.onLocationTap,
    required this.onNotificationTap,
    this.onAvatarTap,
  });

  final Animation<double> headerFade;
  final String city;
  final VoidCallback onLocationTap;
  final VoidCallback onNotificationTap;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: const Color(0xFFF9FBFA),
      elevation: 0,
      automaticallyImplyLeading: false,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: headerFade,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Avatar with green online dot matching Image 1
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Online indicator dot
                        Positioned(
                          right: -1,
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
                  const SizedBox(width: 12),

                  // Greeting & Location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Good morning,',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: const [
                            Text(
                              'Kasun 👋',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: onLocationTap,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: Color(0xFF1B5E38),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                city,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Notification button with badge dot matching Image 1
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            size: 20,
                            color: Color(0xFF1E293B),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Cart button: Solid forest green circle with white cart & amber badge matching Image 1
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyCartScreen()),
                    ),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E38),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1B5E38).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined,
                            size: 20,
                            color: Colors.white,
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFA000),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Text(
                                '2',
                                style: TextStyle(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Search Bar matching Image 1
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumSearchBar extends StatelessWidget {
  const _PremiumSearchBar();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SearchFilterScreen()),
      ),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDF2EF), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 21),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Search fresh veggies, fruits, spices...',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.tune_rounded,
                size: 18,
                color: Color(0xFF1B5E38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Promo Banner with Real Photography matching Image 1
// ─────────────────────────────────────────────────────────────────────────────
class _PromoBanner extends StatefulWidget {
  const _PromoBanner({required this.onShopSpecials});
  final VoidCallback onShopSpecials;

  @override
  State<_PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<_PromoBanner> {
  int _currentIndex = 0;
  Timer? _timer;

  final List<String> _images = [
    'assets/images/promo_1.jpg',
    'assets/images/promo_2.jpg',
    'assets/images/promo_3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _images.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 195,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3B24).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image Carousel Background
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Image.asset(
                _images[_currentIndex],
                key: ValueKey<int>(_currentIndex),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  key: ValueKey<String>('error_$_currentIndex'),
                  color: const Color(0xFF1B5E38),
                ),
              ),
            ),

            // Left-to-right dark green overlay for high legibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0F3B24).withValues(alpha: 0.95),
                    const Color(0xFF1B5E38).withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.65, 1.0],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge pill matching Image 1
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C6E49).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('🌱', style: TextStyle(fontSize: 11)),
                        SizedBox(width: 5),
                        Text(
                          'SPRING HARVEST FEST',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'Up to 25% Off Fresh\nGreens',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.18,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 5),

                  const Text(
                    'Hand-cut at dawn from local organic\nfarmers across the valley.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: onShopSpecials,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Shop Season Specials',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Chip matching Image 1
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.imageUrl,
    required this.isSelected,
    this.isAll = false,
  });

  final String label;
  final IconData icon;
  final String imageUrl;
  final bool isSelected;
  final bool isAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: isSelected && isAll
                ? const Color(0xFF1B5E38)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1B5E38)
                  : const Color(0xFFEDF2EF),
              width: isSelected ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF1B5E38).withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: isAll
                ? Icon(
                    icon,
                    color: isSelected ? Colors.white : const Color(0xFF1B5E38),
                    size: 26,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        icon,
                        color: const Color(0xFF1B5E38),
                        size: 22,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF1B5E38) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Product Card with Real Photography matching Image 1
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumProductCard extends StatefulWidget {
  const _PremiumProductCard({
    required this.product,
    required this.isWishlisted,
    required this.onWishlistToggle,
    this.onTap,
  });

  final ProductData product;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  final VoidCallback? onTap;

  @override
  State<_PremiumProductCard> createState() => _PremiumProductCardState();
}

class _PremiumProductCardState extends State<_PremiumProductCard> {
  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEDF2EF), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real Image Area matching Image 1
              Expanded(
                child: Stack(
                  children: [
                    if (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                      Image.network(
                        p.imageUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF1F5F3),
                          child: Center(
                            child: Text(p.emoji, style: const TextStyle(fontSize: 48)),
                          ),
                        ),
                      )
                    else
                      Container(
                        color: const Color(0xFFF1F5F3),
                        child: Center(
                          child: Text(p.emoji, style: const TextStyle(fontSize: 48)),
                        ),
                      ),

                    // Heart wishlist button on top right matching Image 1
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: widget.onWishlistToggle,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.isWishlisted
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 16,
                            color: widget.isWishlisted
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info Area matching Image 1
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Price + Unit
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          p.price,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E8342),
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          ' ${p.unit}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Rating + Reviews
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFFFA000),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          p.rating,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          ' (${p.reviews})',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const Spacer(),

                        // Quick Add Button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            MarketplaceState.instance.addToCart(
                              CartItem(
                                id: p.name.toLowerCase().replaceAll(' ', '_'),
                                name: p.name,
                                price: double.tryParse(p.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 250.0,
                                unit: p.unit,
                                quantity: 1,
                                emoji: p.emoji,
                                farmName: p.farmer.name,
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${p.name} added to cart!'),
                                duration: const Duration(seconds: 1),
                                action: SnackBarAction(
                                  label: 'View Cart',
                                  textColor: const Color(0xFF4ADE80),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const MyCartScreen()),
                                  ),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B5E38),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Availability
                    Text(
                      p.availability,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
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
// Fresh From Farmers Banner
// ─────────────────────────────────────────────────────────────────────────────
class _FreshFromFarmersCard extends StatelessWidget {
  const _FreshFromFarmersCard({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF8E6), Color(0xFFFFF3CC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.accentOrange.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Text('🌾', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fresh From Farmers',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7A4500),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Hand-cut at dawn from local organic farmers across the valley.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9A6010),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Explore Farms →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Premium Bottom Navigation Bar matching Image 1
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumBottomNav extends StatelessWidget {
  const _PremiumBottomNav({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.assignment_outlined, Icons.assignment_outlined, 'Orders'),
    (Icons.chat_bubble_outline_rounded, Icons.chat_bubble_outline_rounded, 'Chat'),
    (Icons.person_outline_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F5F3), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final (activeIcon, inactiveIcon, label) = _items[i];
          final isSelected = i == selectedIndex;

          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        isSelected ? activeIcon : inactiveIcon,
                        size: 24,
                        color: isSelected
                            ? const Color(0xFF1B5E38)
                            : const Color(0xFF64748B),
                      ),
                      if (i == 1) // Orders green badge dot matching Image 1
                        Positioned(
                          top: -1,
                          right: -1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1B5E38),
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
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF1B5E38)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contract Farming / Pre-Order Banner
// ─────────────────────────────────────────────────────────────────────────────
class _PreOrderFeatureCard extends StatelessWidget {
  const _PreOrderFeatureCard({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF22C55E).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Text('📝', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contract Farming',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF166534),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Pre-order crops directly from farmers before the harvest.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF15803D),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Request Crop →',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

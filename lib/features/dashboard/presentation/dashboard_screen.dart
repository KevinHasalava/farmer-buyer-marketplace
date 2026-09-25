import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/constants.dart';
import 'farmer_profile_screen.dart';
import 'product_detail_screen.dart';

/// Premium Dashboard / Home screen — Farm2Home
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

  late final AnimationController _headerController;
  late final Animation<double> _headerFade;

  static const _categories = [
    ('All', Icons.grid_view_rounded, '🌿'),
    ('Vegetables', Icons.local_florist_rounded, '🥦'),
    ('Fruits', Icons.apple_rounded, '🍎'),
    ('Grains', Icons.grass_rounded, '🌾'),
    ('Spices', Icons.eco_rounded, '🌶️'),
    ('Dairy', Icons.egg_rounded, '🥛'),
  ];

  static const _defaultFarmer = FarmerData(
    name: 'Sunil Perera',
    role: 'Small-Scale Farmer',
    location: 'Hambantota',
    rating: '4.8',
    reviews: '120',
    yearsExperience: '5',
    isOrganic: true,
    happyCustomers: '200',
    about:
        'I am a small-scale farmer from Hambantota. I grow fresh vegetables using natural methods. My goal is to provide healthy and fresh produce to my customers.',
    emoji: '👨‍🌾',
  );

  static const _products = [
    ProductData(
      name: 'Organic Tomatoes',
      price: 'Rs. 250',
      unit: '/kg',
      rating: '4.8',
      reviews: '32',
      availability: 'Available: 25kg',
      emoji: '🍅',
      tag: 'Bestseller',
      tagColor: Color(0xFFFF6B35),
      description:
          'Fresh and naturally grown tomatoes from our farm. No chemicals, 100% organic.',
      harvestDate: '18 Aug 2026',
      tags: ['Organic', 'Fresh'],
      farmer: _defaultFarmer,
    ),
    ProductData(
      name: 'Fresh Carrots',
      price: 'Rs. 300',
      unit: '/kg',
      rating: '4.6',
      reviews: '28',
      availability: 'Available: 15kg',
      emoji: '🥕',
      tag: 'Fresh',
      tagColor: Color(0xFF1E8342),
      description:
          'Crispy sweet carrots cultivated in natural mineral-rich soil. High in beta-carotene and fiber, washed and packed fresh on harvest morning.',
      harvestDate: '19 Aug 2026',
      tags: ['Organic', 'Farm Fresh'],
      farmer: _defaultFarmer,
    ),
    ProductData(
      name: 'Highland Potatoes',
      price: 'Rs. 220',
      unit: '/kg',
      rating: '4.8',
      reviews: '45',
      availability: 'Available: 40kg',
      emoji: '🥔',
      tag: null,
      tagColor: null,
      description:
          'Earthy Sri Lankan highland potatoes. Perfect for curries, baking, or frying. Harvested at peak maturity for rich starch and flavor.',
      harvestDate: '16 Aug 2026',
      tags: ['Highland', 'Natural'],
      farmer: _defaultFarmer,
    ),
    ProductData(
      name: 'Bell Peppers',
      price: 'Rs. 380',
      unit: '/kg',
      rating: '4.9',
      reviews: '19',
      availability: 'Available: 12kg',
      emoji: '🫑',
      tag: 'Premium',
      tagColor: Color(0xFF8B5CF6),
      description:
          'Vibrant bell peppers with thick crunchy walls and naturally sweet taste. Carefully nurtured in organic greenhouse conditions.',
      harvestDate: '20 Aug 2026',
      tags: ['Greenhouse', 'Premium'],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Premium App Bar ────────────────────────────────────────────
          _PremiumSliverAppBar(
            headerFade: _headerFade,
            onAvatarTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const FarmerProfileScreen(farmer: _defaultFarmer),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Search Bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _PremiumSearchBar(),
                ),

                const SizedBox(height: 20),

                // ── Promo Banner ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _PromoBanner(),
                ),

                const SizedBox(height: 24),

                // ── Categories ──────────────────────────────────────────
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
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Category chips
                SizedBox(
                  height: 96,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, i) {
                      final (label, icon, emoji) = _categories[i];
                      final isSelected = i == _selectedCategory;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = i),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _CategoryChip(
                            label: label,
                            emoji: emoji,
                            icon: icon,
                            isSelected: isSelected,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ── Popular Products ────────────────────────────────────
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
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Products Grid
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
                      childAspectRatio: 0.76,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, i) {
                      final product = _products[i];
                      return _PremiumProductCard(
                        product: product,
                        isWishlisted: _wishlist.contains(i),
                        onWishlistToggle: () => setState(() {
                          _wishlist.contains(i)
                              ? _wishlist.remove(i)
                              : _wishlist.add(i);
                        }),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ── Fresh From Farmers section ──────────────────────────
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

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      // ── Premium Bottom Navigation ──────────────────────────────────────
      bottomNavigationBar: _PremiumBottomNav(
        selectedIndex: _selectedNav,
        onTap: (i) {
          if (i == 3) {
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
// Premium Sliver App Bar
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumSliverAppBar extends StatelessWidget {
  const _PremiumSliverAppBar({
    required this.headerFade,
    this.onAvatarTap,
  });

  final Animation<double> headerFade;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: const Color(0xFFF4F7F5),
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
                  // Avatar
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E8342), Color(0xFF063725)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'K',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Good morning,',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              'Kasun 👋',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: const [
                            Icon(
                              Icons.location_on_rounded,
                              size: 11,
                              color: AppColors.primaryGreen,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'Colombo, Sri Lanka',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Notification button
                  _IconBtn(
                    icon: Icons.notifications_outlined,
                    badge: true,
                    badgeCount: null,
                  ),
                  const SizedBox(width: 8),

                  // Cart button
                  _IconBtn(
                    icon: Icons.shopping_bag_outlined,
                    badge: true,
                    badgeCount: 2,
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

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.badge,
    required this.badgeCount,
  });

  final IconData icon;
  final bool badge;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: AppColors.textDark),
        ),
        if (badge)
          Positioned(
            right: -1,
            top: -1,
            child: Container(
              width: badgeCount != null ? null : 10,
              height: badgeCount != null ? null : 10,
              padding: badgeCount != null
                  ? const EdgeInsets.symmetric(horizontal: 5, vertical: 2)
                  : null,
              decoration: BoxDecoration(
                color: AppColors.accentOrange,
                shape:
                    badgeCount != null ? BoxShape.rectangle : BoxShape.circle,
                borderRadius:
                    badgeCount != null ? BorderRadius.circular(99) : null,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: badgeCount != null
                  ? Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Search Bar
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumSearchBar extends StatelessWidget {
  const _PremiumSearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search fresh veggies, fruits, spices...',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textHint,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 17,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Promo Banner
// ─────────────────────────────────────────────────────────────────────────────
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF032B1C), Color(0xFF0D5C38), Color(0xFF1E8342)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text(
                          '🌾  SPRING HARVEST FEST',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      const Text(
                        'Up to 25% Off\nFresh Greens',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Shop Season Specials →',
                          style: TextStyle(
                            color: AppColors.darkGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Emoji art
                const Text(
                  '🥬\n🥕\n🍅',
                  style: TextStyle(fontSize: 30, height: 1.3),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category Chip
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.emoji,
    required this.icon,
    required this.isSelected,
  });

  final String label;
  final String emoji;
  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF1E8342), Color(0xFF063725)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : AppColors.surfaceWhite,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.primaryGreen.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.06),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: isSelected
                  ? Icon(icon, color: Colors.white, size: 24)
                  : Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.primaryGreen
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Product Card
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

class _PremiumProductCardState extends State<_PremiumProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heartController;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.8,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area
              Expanded(
                child: Stack(
                  children: [
                    // Background gradient
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen.withValues(alpha: 0.06),
                            AppColors.primaryGreen.withValues(alpha: 0.12),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          p.emoji,
                          style: const TextStyle(fontSize: 56),
                        ),
                      ),
                    ),

                    // Tag badge
                    if (p.tag != null)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: p.tagColor,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            p.tag!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                    // Wishlist heart
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          _heartController.reverse().then(
                                (_) => _heartController.forward(),
                              );
                          widget.onWishlistToggle();
                        },
                        child: ScaleTransition(
                          scale: _heartController,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                                  ? Colors.redAccent
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info area
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          p.price,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          p.unit,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        // Rating
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: AppColors.accentOrange,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          p.rating,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          ' (${p.reviews})',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),

                        // Add button
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF1E8342),
                                  Color(0xFF0D5C38),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),
                    Text(
                      p.availability,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
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
// Premium Bottom Navigation Bar
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
    (Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Orders'),
    (Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, 'Chat'),
    (Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: isSelected ? 44 : 0,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Icon(
                    isSelected ? activeIcon : inactiveIcon,
                    size: 24,
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.textSecondary,
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

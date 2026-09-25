import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import 'product_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Farmer Profile Screen — matches Figma design
// ─────────────────────────────────────────────────────────────────────────────
class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key, required this.farmer});
  final FarmerData farmer;

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // Products for this farmer
  List<ProductData> get _farmerProductData => [
        ProductData(
          name: 'Organic Tomatoes',
          price: 'Rs. 250',
          unit: '/kg',
          rating: '4.8',
          reviews: '32',
          availability: 'Available: 25kg',
          emoji: '🍅',
          tag: 'Bestseller',
          tagColor: const Color(0xFFFF6B35),
          description:
              'Fresh and naturally grown tomatoes from our farm. No chemicals, 100% organic.',
          harvestDate: '18 Aug 2026',
          tags: const ['Organic', 'Fresh'],
          farmer: widget.farmer,
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
          tagColor: const Color(0xFF1E8342),
          description:
              'Crispy sweet carrots cultivated in natural mineral-rich soil. High in beta-carotene and fiber, washed and packed fresh on harvest morning.',
          harvestDate: '19 Aug 2026',
          tags: const ['Organic', 'Farm Fresh'],
          farmer: widget.farmer,
        ),
        ProductData(
          name: 'Crisp Cucumber',
          price: 'Rs. 200',
          unit: '/kg',
          rating: '4.7',
          reviews: '24',
          availability: 'Available: 30kg',
          emoji: '🥒',
          tag: 'Organic',
          tagColor: const Color(0xFF1E8342),
          description:
              'Freshly harvested crisp cucumbers with high water content and cool refreshing taste. Ideal for daily salads.',
          harvestDate: '21 Aug 2026',
          tags: const ['Organic', 'Hydrating'],
          farmer: widget.farmer,
        ),
      ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.farmer;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Cover + Avatar App Bar ─────────────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.surfaceWhite,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          size: 18,
                          color: AppColors.textDark,
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                title: const Text(
                  'Farmer Profile',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Cover photo — green gradient landscape feel
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF1A5C35),
                              Color(0xFF2E8B4F),
                              Color(0xFF4CAF70),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: CustomPaint(painter: _LandscapePainter()),
                      ),
                      // Bottom white curve
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                        ),
                      ),
                      // Avatar
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1E8342),
                                      Color(0xFF063725),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    f.emoji,
                                    style: const TextStyle(fontSize: 44),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2.5),
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 13,
                                    color: Colors.white,
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

              // ── Content ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slide,
                  child: FadeTransition(
                    opacity: _fade,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          16, 16, 16, 100 + bottomPad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ── Name + verified ──────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                f.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified_rounded,
                                size: 20,
                                color: AppColors.primaryGreen,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            f.role,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ── Location + Rating ────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: AppColors.primaryGreen,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                f.location,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.textHint,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: AppColors.accentOrange,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${f.rating} (${f.reviews} reviews)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ── Stats Row (3 separate cards matching Figma) ──
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  value: '${f.yearsExperience}+',
                                  label: 'Years\nExperience',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _StatCard(
                                  value: f.isOrganic ? '100%' : 'Mixed',
                                  label: 'Organic\nProducts',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _StatCard(
                                  value: '${f.happyCustomers}+',
                                  label: 'Happy\nCustomers',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ── About Me ─────────────────────────────────
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ABOUT ME',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  f.about,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── My Products ──────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'My Products',
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
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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

                          const SizedBox(height: 12),

                          // Horizontal product list
                          SizedBox(
                            height: 170,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _farmerProductData.length,
                              itemBuilder: (context, i) {
                                final prod = _farmerProductData[i];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: _FarmerProductCard(
                                    name: prod.name,
                                    price: '${prod.price}${prod.unit}',
                                    emoji: prod.emoji,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ProductDetailScreen(product: prod),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Fixed Add Product Button ───────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text('Add Product dialog opened'),
                        ],
                      ),
                      backgroundColor: AppColors.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E8342), Color(0xFF063725)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Add Product',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Decorative landscape painter for cover photo
// ─────────────────────────────────────────────────────────────────────────────
class _LandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Rolling hills
    paint.color = const Color(0xFF1A6B3C).withValues(alpha: 0.6);
    final hill1 = Path();
    hill1.moveTo(0, size.height * 0.55);
    hill1.quadraticBezierTo(
      size.width * 0.3, size.height * 0.3,
      size.width * 0.6, size.height * 0.5,
    );
    hill1.quadraticBezierTo(
      size.width * 0.8, size.height * 0.65,
      size.width, size.height * 0.5,
    );
    hill1.lineTo(size.width, size.height);
    hill1.lineTo(0, size.height);
    hill1.close();
    canvas.drawPath(hill1, paint);

    paint.color = const Color(0xFF0D5C38).withValues(alpha: 0.5);
    final hill2 = Path();
    hill2.moveTo(0, size.height * 0.7);
    hill2.quadraticBezierTo(
      size.width * 0.25, size.height * 0.5,
      size.width * 0.5, size.height * 0.65,
    );
    hill2.quadraticBezierTo(
      size.width * 0.75, size.height * 0.8,
      size.width, size.height * 0.6,
    );
    hill2.lineTo(size.width, size.height);
    hill2.lineTo(0, size.height);
    hill2.close();
    canvas.drawPath(hill2, paint);

    // Sun
    paint.color = Colors.white.withValues(alpha: 0.15);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 30, paint);
    paint.color = Colors.white.withValues(alpha: 0.08);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 50, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat card for the 3 stats row matching Figma
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Farmer's product card (horizontal scroll)
// ─────────────────────────────────────────────────────────────────────────────
class _FarmerProductCard extends StatefulWidget {
  const _FarmerProductCard({
    required this.name,
    required this.price,
    required this.emoji,
    this.onTap,
  });

  final String name;
  final String price;
  final String emoji;
  final VoidCallback? onTap;

  @override
  State<_FarmerProductCard> createState() => _FarmerProductCardState();
}

class _FarmerProductCardState extends State<_FarmerProductCard> {
  bool _wishlisted = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen.withValues(alpha: 0.07),
                            AppColors.primaryGreen.withValues(alpha: 0.14),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.emoji,
                          style: const TextStyle(fontSize: 46),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _wishlisted = !_wishlisted),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            _wishlisted
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 13,
                            color: _wishlisted
                                ? Colors.redAccent
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Info
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.price,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
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

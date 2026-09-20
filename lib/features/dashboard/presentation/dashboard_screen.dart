import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';

/// Dashboard / Home screen — product listing placeholder.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _categories = [
    ('All', Icons.grid_view_rounded),
    ('Vegetables', Icons.local_florist_rounded),
    ('Fruits', Icons.apple_rounded),
    ('Grains', Icons.grass_rounded),
    ('Spices', Icons.eco_rounded),
    ('Dairy', Icons.egg_rounded),
  ];

  static const _products = [
    ('Tomatoes', 'Rs. 260', '4.7', 'Available 12kg'),
    ('Carrots', 'Rs. 310', '4.8', 'Available 8kg'),
    ('Potatoes', 'Rs. 220', '4.6', 'Available 20kg'),
    ('Bell Peppers', 'Rs. 380', '4.9', 'Available 5kg'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: AppColors.backgroundLight,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning,',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Kasun 👋',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceXXS),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    Text(
                      'Colombo, Sri Lanka',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accentOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Search ─────────────────────────────────────────────
                Padding(
                  padding: AppDimensions.screenPadding,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search fresh veggies, fruits, spices...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppColors.textSecondary),
                      suffixIcon: const Icon(Icons.tune_rounded,
                          color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.surfaceWhite,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spaceSM,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceMD),

                // ── Promo Banner ────────────────────────────────────────
                Padding(
                  padding: AppDimensions.screenPadding,
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.darkGreen,
                          AppColors.primaryGreen,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusXL),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(AppDimensions.spaceMD),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.spaceSM,
                                    vertical: AppDimensions.spaceXXS,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentOrange,
                                    borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusFull),
                                  ),
                                  child: Text(
                                    '🌾 SPRING HARVEST FEST',
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    height: AppDimensions.spaceSM),
                                Text(
                                  'Up to 25% Off\nFresh Greens',
                                  style:
                                      theme.textTheme.titleLarge?.copyWith(
                                    color: AppColors.surfaceWhite,
                                    fontWeight: FontWeight.w700,
                                    height: AppTextStyles.lineHeightTight,
                                  ),
                                ),
                                const SizedBox(
                                    height: AppDimensions.spaceXS),
                                Text(
                                  'Shop Season Specials →',
                                  style:
                                      theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.surfaceWhite
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.local_florist_rounded,
                            size: 72,
                            color: Colors.white24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceLG),

                // ── Categories ──────────────────────────────────────────
                Padding(
                  padding: AppDimensions.screenPadding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Categories',
                          style: theme.textTheme.titleLarge),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: AppDimensions.screenPadding,
                    itemCount: _categories.length,
                    itemBuilder: (context, i) {
                      final (label, icon) = _categories[i];
                      final isSelected = i == 0;
                      return Padding(
                        padding: const EdgeInsets.only(
                            right: AppDimensions.spaceSM),
                        child: Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryGreen
                                    : AppColors.surfaceWhite,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                icon,
                                color: isSelected
                                    ? AppColors.surfaceWhite
                                    : AppColors.textSecondary,
                                size: AppDimensions.iconSM + 2,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spaceXXS),
                            Text(
                              label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isSelected
                                    ? AppColors.primaryGreen
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceLG),

                // ── Popular Products ────────────────────────────────────
                Padding(
                  padding: AppDimensions.screenPadding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Popular Products',
                          style: theme.textTheme.titleLarge),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: AppDimensions.screenPadding,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppDimensions.spaceSM,
                      crossAxisSpacing: AppDimensions.spaceSM,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, i) {
                      final (name, price, rating, availability) =
                          _products[i];
                      return _ProductCard(
                        name: name,
                        price: price,
                        rating: rating,
                        availability: availability,
                      );
                    },
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceXL),
              ],
            ),
          ),
        ],
      ),

      // ── Bottom Navigation ─────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (_) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.name,
    required this.price,
    required this.rating,
    required this.availability,
  });

  final String name;
  final String price;
  final String rating;
  final String availability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder image area
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.radiusLG),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_florist_rounded,
                      size: 52,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                // Add to cart button
                Positioned(
                  right: AppDimensions.spaceXS,
                  top: AppDimensions.spaceXS,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.primaryGreen.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.surfaceWhite,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product info
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceSM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spaceXXS),
                Text(
                  price,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXXS),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: AppColors.accentOrange,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceXXS),
                    Expanded(
                      child: Text(
                        availability,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
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
}

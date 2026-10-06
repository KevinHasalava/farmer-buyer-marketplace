import 'package:flutter/material.dart';

import '../../cart/services/cart_state.dart';
import '../data/buyer_mock_data.dart';
import '../models/buyer_models.dart';
import 'buyer_cart_screen.dart';
import 'buyer_product_list_screen.dart';
import 'buyer_search_screen.dart';
import 'widgets/buyer_bottom_nav.dart';

/// 10. Categories Screen — matching Screenshot 10
class BuyerCategoriesScreen extends StatefulWidget {
  const BuyerCategoriesScreen({super.key});

  @override
  State<BuyerCategoriesScreen> createState() => _BuyerCategoriesScreenState();
}

class _BuyerCategoriesScreenState extends State<BuyerCategoriesScreen> {
  final MarketplaceState _cartState = MarketplaceState.instance;
  final TextEditingController _searchController = TextEditingController();

  static const Color _forestGreen = Color(0xFF1B5E38);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _cartState.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartState.removeListener(_onCartChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _openCategory(BuyerCategoryItem cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuyerProductListScreen(categoryTitle: cat.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = _cartState.totalItemCount;

    return Scaffold(
      backgroundColor: _bgSoft,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.eco_rounded, color: _forestGreen, size: 24),
                      SizedBox(width: 6),
                      Text(
                        'Farm2Home',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _forestGreen,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  Row(
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
                      const SizedBox(width: 10),
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
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  // Daily Harvests badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC8E6C9)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.eco_rounded, size: 12, color: _forestGreen),
                            SizedBox(width: 4),
                            Text(
                              'Daily Harvests',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _forestGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Big Title
                  const Text(
                    'All Categories',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Fresh farm produce sorted by harvest category',
                    style: TextStyle(
                      fontSize: 12,
                      color: _textMuted,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Search Bar
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BuyerSearchScreen()),
                    ),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(23),
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
                        children: const [
                          Icon(Icons.search_rounded, color: _textMuted, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Search crops, spices, grains...',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Icon(Icons.mic_none_rounded, color: _textMuted, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Cards List matching Screenshot 10
                  ...BuyerMockData.categories.map((cat) => _buildCategoryCard(cat)),

                  const SizedBox(height: 16),

                  // Direct Sourcing Guarantee Container matching Screenshot 10
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDCFCE7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.verified_user_rounded, color: _forestGreen, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Direct Sourcing Guarantee',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _forestGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Every category comes straight from registered local farmers across Sri Lanka. Fair prices, no middlemen, zero-shelf storage delay.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF166534),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Jaffna', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textMuted)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 12, color: _forestGreen),
                            SizedBox(width: 8),
                            Text('Nuwara Eliya', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textMuted)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 12, color: _forestGreen),
                            SizedBox(width: 8),
                            Text('Colombo Hub', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _forestGreen)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BuyerBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildCategoryCard(BuyerCategoryItem cat) {
    return GestureDetector(
      onTap: () => _openCategory(cat),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          if (cat.badge != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: (cat.badgeColor ?? _forestGreen).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                cat.badge!,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: cat.badgeColor ?? _forestGreen,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            cat.itemCountText,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        cat.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _textMuted,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            cat.actionText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _forestGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Category image
              Image.network(
                cat.imageUrl,
                width: 100,
                height: 110,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

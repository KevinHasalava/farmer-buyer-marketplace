import 'package:flutter/material.dart';

import '../../../core/localization/app_settings.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../../cart/services/cart_state.dart';
import '../data/buyer_mock_data.dart';
import '../models/buyer_models.dart';
import 'buyer_cart_screen.dart';
import 'buyer_product_list_screen.dart';
import 'buyer_search_screen.dart';
import 'widgets/buyer_bottom_nav.dart';

/// 10. Categories Screen — matching Screenshot 10 with interactive search & direct category filtering
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

  String _searchFilter = '';

  @override
  void initState() {
    super.initState();
    _cartState.addListener(_onCartChanged);
    _searchController.addListener(() {
      setState(() {
        _searchFilter = _searchController.text.trim().toLowerCase();
      });
    });
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
    final allCategories = BuyerMockData.categories;
    final filteredCategories = _searchFilter.isEmpty
        ? allCategories
        : allCategories.where((c) {
            return c.name.toLowerCase().contains(_searchFilter) ||
                c.description.toLowerCase().contains(_searchFilter);
          }).toList();

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
                      AppBrandLogo(size: 34),
                      SizedBox(width: 8),
                      AppBrandWordmark(fontSize: 18),
                    ],
                  ),
                  Row(
                    children: [
                      // Quick Language Switcher Pill
                      const AppLanguagePill(),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BuyerSearchScreen(),
                          ),
                        ),
                        child: Container(
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
                          child: const Icon(Icons.search_rounded, size: 20, color: _textDark),
                        ),
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


                  // Big Title
                  Text(
                    context.tr.allProduceCategories,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr.pickedFromPartnerFarms,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _textMuted,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Search Bar inside Categories Screen
                  Container(
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
                      children: [
                        const Icon(Icons.search_rounded, color: _forestGreen, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: context.tr.filterOrCropHint,
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BuyerSearchScreen(initialQuery: val.trim()),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () => _searchController.clear(),
                            child: const Icon(Icons.close_rounded, color: _textMuted, size: 18),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_rounded, color: _forestGreen, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BuyerSearchScreen(initialQuery: _searchController.text.trim()),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Cards List
                  if (filteredCategories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.search_off_rounded, size: 40, color: _textMuted),
                            const SizedBox(height: 10),
                            Text(context.tr.noProductsMatch),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () => _searchController.clear(),
                              child: Text(context.tr.showAllCategories),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...filteredCategories.map((cat) => _buildCategoryCard(cat)),


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
                                cat.localizedBadge(context.currentLanguage) ?? cat.badge!,
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
                            cat.localizedItemCount(context.currentLanguage),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat.localizedName(context.currentLanguage),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        cat.localizedDescription(context.currentLanguage),
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
                            cat.localizedActionText(context.currentLanguage),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _forestGreen,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, size: 12, color: _forestGreen),
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
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 100,
                    height: 110,
                    color: const Color(0xFFF1F5F9),
                    child: const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: _forestGreen),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 110,
                  color: const Color(0xFFF1F5F9),
                  child: const Icon(Icons.eco_rounded, color: _forestGreen, size: 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../cart/models/cart_item_model.dart';
import '../../cart/services/cart_state.dart';
import '../data/buyer_mock_data.dart';
import '../models/buyer_models.dart';
import 'buyer_cart_screen.dart';
import 'buyer_filter_screen.dart';
import 'buyer_product_detail_screen.dart';
import 'buyer_search_screen.dart';

/// 13. Product List Screen — matching Screenshot 13 with dynamic real items, search, sort, and filters
class BuyerProductListScreen extends StatefulWidget {
  const BuyerProductListScreen({
    super.key,
    this.categoryTitle = 'Fresh Vegetables',
    this.filterCriteria,
  });

  final String categoryTitle;
  final BuyerFilterCriteria? filterCriteria;

  @override
  State<BuyerProductListScreen> createState() => _BuyerProductListScreenState();
}

class _BuyerProductListScreenState extends State<BuyerProductListScreen> {
  final MarketplaceState _cartState = MarketplaceState.instance;
  final Set<String> _wishlist = {};
  late BuyerFilterCriteria _currentCriteria;

  static const Color _forestGreen = Color(0xFF1B5E38);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  int _quickFilterIndex = 0;
  final List<String> _quickFilters = ['All Picks', 'Under Rs. 400', '100% Organic', 'Picked Today'];

  final List<String> _sortOptions = [
    'Price: Low to High',
    'Price: High to Low',
    'Highest Rated (4.5+ ★)',
    'Newest Harvest First',
  ];
  String _selectedSort = 'Price: Low to High';

  @override
  void initState() {
    super.initState();
    _currentCriteria = widget.filterCriteria ??
        BuyerFilterCriteria(
          category: widget.categoryTitle == 'Filtered Harvests' || widget.categoryTitle == 'Fresh Harvests'
              ? 'All'
              : widget.categoryTitle,
          sortBy: _selectedSort,
        );

    _cartState.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartState.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _addToCart(BuyerProduct prod) {
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
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Added ${prod.name} (${prod.formattedPrice}) to cart!'),
            ),
          ],
        ),
        backgroundColor: _forestGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'View Cart',
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

  Future<void> _openFilterScreen() async {
    final updated = await Navigator.push<BuyerFilterCriteria>(
      context,
      MaterialPageRoute(
        builder: (_) => BuyerFilterScreen(initialCriteria: _currentCriteria),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _currentCriteria = updated;
      });
    }
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Sort Products',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark),
                ),
              ),
              ..._sortOptions.map(
                (opt) => ListTile(
                  title: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: opt == _selectedSort ? FontWeight.w700 : FontWeight.w500,
                      color: opt == _selectedSort ? _forestGreen : _textDark,
                    ),
                  ),
                  trailing: opt == _selectedSort
                      ? const Icon(Icons.check_circle_rounded, color: _forestGreen, size: 20)
                      : null,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedSort = opt;
                      _currentCriteria = _currentCriteria.copyWith(sortBy: opt);
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<BuyerProduct> _getFilteredProducts() {
    var list = BuyerMockData.filterProducts(_currentCriteria);

    if (_quickFilterIndex == 1) {
      list = list.where((p) => p.price <= 400).toList();
    } else if (_quickFilterIndex == 2) {
      list = list.where((p) => p.isOrganic).toList();
    } else if (_quickFilterIndex == 3) {
      list = list.where((p) => p.harvestTime.toLowerCase().contains('today')).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = _cartState.totalItemCount;
    final products = _getFilteredProducts();
    final activeFiltersCount = _currentCriteria.activeFiltersCount;

    return Scaffold(
      backgroundColor: _bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 22, color: _textDark),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BuyerSearchScreen(
                  initialCriteria: _currentCriteria,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BuyerCartScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: _forestGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, size: 18, color: Colors.white),
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
          ),
        ],
      ),
      body: Column(
        children: [
          // Subheader row & Filters chip row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${products.length} fresh ${products.length == 1 ? 'item' : 'items'} available',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Picked fresh from local partner farms',
                      style: TextStyle(fontSize: 10, color: _textMuted),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Filters pill
                    GestureDetector(
                      onTap: _openFilterScreen,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: activeFiltersCount > 0 ? _forestGreen : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: activeFiltersCount > 0 ? _forestGreen : const Color(0xFFC8E6C9),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              size: 13,
                              color: activeFiltersCount > 0 ? Colors.white : _forestGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              activeFiltersCount > 0 ? 'Filters ($activeFiltersCount)' : 'Filters',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: activeFiltersCount > 0 ? Colors.white : _forestGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Sort dropdown chip
                    GestureDetector(
                      onTap: _showSortModal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedSort.split('(').first.trim(),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textDark),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: _textDark),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Filter Horizontal Pills
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_quickFilters.length, (i) {
                  final isSel = _quickFilterIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _quickFilterIndex = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSel ? _forestGreen : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSel ? _forestGreen : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        _quickFilters[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSel ? Colors.white : _textDark,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Product Cards List
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.eco_outlined, size: 36, color: _textMuted),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No Products Match This Selection',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try resetting your active filters or choosing another category.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: _textMuted),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _quickFilterIndex = 0;
                                _currentCriteria = const BuyerFilterCriteria();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _forestGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('Show All Produce'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final prod = products[index];
                      final isFav = _wishlist.contains(prod.id);

                      return _buildProductCard(
                        prod: prod,
                        isFav: isFav,
                        onFavToggle: () {
                          setState(() {
                            if (isFav) {
                              _wishlist.remove(prod.id);
                            } else {
                              _wishlist.add(prod.id);
                            }
                          });
                          HapticFeedback.selectionClick();
                        },
                        onAdd: () => _addToCart(prod),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BuyerProductDetailScreen(product: prod),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required BuyerProduct prod,
    required bool isFav,
    required VoidCallback onFavToggle,
    required VoidCallback onAdd,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Section: Image and Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with badges
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        Image.network(
                          prod.imageUrl,
                          width: 105,
                          height: 105,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 105,
                              height: 105,
                              color: const Color(0xFFF1F5F9),
                              child: const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: _forestGreen),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 105,
                            height: 105,
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.eco_rounded, color: _forestGreen, size: 36),
                          ),
                        ),
                        if (prod.badge != null)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: prod.badgeColor ?? const Color(0xFF16A34A),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                prod.badge!,
                                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${prod.availableStock} in stock',
                              style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                prod.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: onFavToggle,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isFav ? const Color(0xFFFEE2E2) : const Color(0xFFF8FAFC),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  size: 16,
                                  color: isFav ? const Color(0xFFEF4444) : _textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 3),
                            Text(
                              '${prod.rating} (${prod.reviewsCount}) • ${prod.farmerName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 12, color: _textMuted),
                            const SizedBox(width: 2),
                            Text(
                              '${prod.farmLocation} • ${prod.harvestTime}',
                              style: const TextStyle(fontSize: 10, color: _textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${prod.formattedPrice} / ${prod.unit}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _forestGreen,
                              ),
                            ),
                            if (prod.originalPrice != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                prod.formattedOriginalPrice,
                                style: const TextStyle(
                                  fontSize: 11,
                                  decoration: TextDecoration.lineThrough,
                                  color: _textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

            // Bottom Action Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, size: 14, color: _forestGreen),
                      const SizedBox(width: 4),
                      Text(
                        prod.dispatchVia,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _forestGreen),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.shopping_bag_outlined, size: 14),
                    label: const Text('Add to Basket', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _forestGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      minimumSize: const Size(0, 32),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../cart/models/cart_item_model.dart';
import '../../cart/services/cart_state.dart';
import '../data/buyer_mock_data.dart';
import '../models/buyer_models.dart';
import 'buyer_cart_screen.dart';
import 'buyer_farmer_profile_screen.dart';
import 'buyer_filter_screen.dart';
import 'buyer_product_detail_screen.dart';
import 'widgets/buyer_bottom_nav.dart';

/// 11. Search Screen — Fully interactive with real-time search, filters, and real produce catalog
class BuyerSearchScreen extends StatefulWidget {
  const BuyerSearchScreen({
    super.key,
    this.initialQuery = '',
    this.initialCriteria,
  });

  final String initialQuery;
  final BuyerFilterCriteria? initialCriteria;

  @override
  State<BuyerSearchScreen> createState() => _BuyerSearchScreenState();
}

class _BuyerSearchScreenState extends State<BuyerSearchScreen> {
  final MarketplaceState _cartState = MarketplaceState.instance;
  late final TextEditingController _searchController;

  static const Color _forestGreen = Color(0xFF1B5E38);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  final List<String> _recentSearches = [
    'Carrots',
    'Avocados',
    'Keeri Samba',
    'Buffalo Curd',
    'Cinnamon',
  ];

  late BuyerFilterCriteria _currentCriteria;
  int _selectedFilterChip = 0;
  final List<String> _chips = [
    'All',
    'Vegetables',
    'Fruits',
    'Grains & Rice',
    'Spices & Herbs',
    'Organic & Traditional',
    'Dairy & Farm Fresh',
  ];

  final List<String> _sortOptions = [
    'Recommended',
    'Price: Low to High',
    'Price: High to Low',
    'Highest Rated (4.5+ ★)',
  ];
  String _selectedSort = 'Recommended';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _currentCriteria = widget.initialCriteria ??
        BuyerFilterCriteria(
          searchQuery: widget.initialQuery,
        );

    // If initial category exists in criteria, match chip
    if (_currentCriteria.category != 'All' && _currentCriteria.category.isNotEmpty) {
      final idx = _chips.indexWhere((c) => c.toLowerCase() == _currentCriteria.category.toLowerCase());
      if (idx >= 0) _selectedFilterChip = idx;
    }

    _cartState.addListener(_onCartChanged);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _cartState.removeListener(_onCartChanged);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _onSearchChanged() {
    setState(() {
      _currentCriteria = _currentCriteria.copyWith(
        searchQuery: _searchController.text.trim(),
      );
    });
  }

  void _onSelectChip(int index) {
    setState(() {
      _selectedFilterChip = index;
      final selectedCategory = index == 0 ? 'All' : _chips[index];
      _currentCriteria = _currentCriteria.copyWith(category: selectedCategory);
    });
  }

  void _applyRecentSearch(String term) {
    _searchController.text = term;
    _searchController.selection = TextSelection.fromPosition(TextPosition(offset: term.length));
  }

  Future<void> _openFilters() async {
    final updatedCriteria = await Navigator.push<BuyerFilterCriteria>(
      context,
      MaterialPageRoute(
        builder: (_) => BuyerFilterScreen(initialCriteria: _currentCriteria),
      ),
    );

    if (updatedCriteria != null && mounted) {
      setState(() {
        _currentCriteria = updatedCriteria;
        final idx = _chips.indexWhere((c) => c.toLowerCase() == updatedCriteria.category.toLowerCase());
        _selectedFilterChip = idx >= 0 ? idx : 0;
      });
    }
  }

  void _showSortPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Sort Harvests By',
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
          ),
        );
      },
    );
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
              child: Text(
                'Added ${prod.name} (${prod.formattedPrice}) to cart!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
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

  @override
  Widget build(BuildContext context) {
    final cartCount = _cartState.totalItemCount;
    final results = BuyerMockData.filterProducts(_currentCriteria);
    final activeFilterCount = _currentCriteria.activeFiltersCount;

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
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textDark),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.eco_rounded, color: _forestGreen, size: 22),
                      const SizedBox(width: 6),
                      const Text(
                        'Farm2Home Direct',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _forestGreen,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
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

            // Search input field with Tune/Filter button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _searchController.text.isNotEmpty ? _forestGreen : const Color(0xFFCBD5E1),
                          width: _searchController.text.isNotEmpty ? 1.5 : 1,
                        ),
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
                          const Icon(Icons.search_rounded, color: _forestGreen, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _textDark,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Search vegetables, fruits, rice, spices...',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF94A3B8),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _currentCriteria = _currentCriteria.copyWith(searchQuery: '');
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded, color: _textDark, size: 14),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter Sliders Button with Active Badge
                  GestureDetector(
                    onTap: _openFilters,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: activeFilterCount > 0 ? _forestGreen : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: activeFilterCount > 0 ? _forestGreen : const Color(0xFFCBD5E1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: activeFilterCount > 0 ? Colors.white : _forestGreen,
                            size: 22,
                          ),
                        ),
                        if (activeFilterCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEA580C),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                '$activeFilterCount',
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

            // Live Farm Connection Notice
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 14, color: _forestGreen),
                        SizedBox(width: 6),
                        Text(
                          'Directly from verified Sri Lankan farmers',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _forestGreen,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'No Middlemen Markups',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Searches Row (Scrollable Horizontal)
            if (_recentSearches.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Row(
                  children: [
                    const Text(
                      'RECENT:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: _textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _recentSearches.map((term) {
                            return GestureDetector(
                              onTap: () => _applyRecentSearch(term),
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  term,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _textDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Dynamic Category Filter Chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_chips.length, (idx) {
                    final isSelected = _selectedFilterChip == idx;
                    return GestureDetector(
                      onTap: () => _onSelectChip(idx),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? _forestGreen : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? _forestGreen : const Color(0xFFE2E8F0),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _forestGreen.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            if (isSelected) ...[
                              const Icon(Icons.check_rounded, size: 13, color: Colors.white),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              _chips[idx],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : _textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Results Count & Sort Dropdown
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: '${results.length} fresh ${results.length == 1 ? 'item' : 'items'} ',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                      children: [
                        if (_searchController.text.isNotEmpty)
                          TextSpan(
                            text: 'for "${_searchController.text}"',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _textMuted,
                            ),
                          )
                        else if (_chips[_selectedFilterChip] != 'All')
                          TextSpan(
                            text: 'in ${_chips[_selectedFilterChip]}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showSortPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _selectedSort,
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
            ),

            // Results List / Empty State
            Expanded(
              child: results.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final prod = results[index];
                        return _buildSearchResultCard(prod);
                      },
                    ),
            ),

            // Fair Pay Bottom Banner
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shield_outlined, size: 16, color: _forestGreen),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '100% Guaranteed Farm Fresh: Guaranteed delivery within 12-24 hours from harvest.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF166534),
                          height: 1.25,
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
      bottomNavigationBar: const BuyerBottomNav(selectedIndex: 0),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 40, color: _textMuted),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Fresh Harvests Found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'We could not find any products matching your search or filters. Try adjusting your keywords or clearing active filters.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: _textMuted, height: 1.4),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedFilterChip = 0;
                  _currentCriteria = const BuyerFilterCriteria();
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset All Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(BuyerProduct prod) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BuyerProductDetailScreen(product: prod),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
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
        child: Row(
          children: [
            // Image with tags
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.network(
                    prod.imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 90,
                        height: 90,
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: _forestGreen),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 90,
                      height: 90,
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.eco_rounded, color: _forestGreen, size: 30),
                    ),
                  ),
                  if (prod.badge != null)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
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

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prod.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Farmer row
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BuyerFarmerProfileScreen(
                            farmer: BuyerMockData.primaryFarmer,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 2),
                        Text(
                          '${prod.rating} (${prod.reviewsCount}) • ',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _textDark),
                        ),
                        Expanded(
                          child: Text(
                            '${prod.farmerName} • ${prod.farmLocation}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _forestGreen,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    prod.harvestTime,
                    style: const TextStyle(fontSize: 10, color: _textMuted),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${prod.formattedPrice} / ${prod.unit}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _forestGreen,
                            ),
                          ),
                          if (prod.originalPrice != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              prod.formattedOriginalPrice,
                              style: const TextStyle(
                                fontSize: 10,
                                decoration: TextDecoration.lineThrough,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(prod),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: _forestGreen,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _forestGreen.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
}

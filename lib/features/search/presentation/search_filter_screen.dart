import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../dashboard/presentation/product_detail_screen.dart';

/// Search & Filter Screen — matches Figma mockup (Image 2)
class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryIndex = 0;
  RangeValues _priceRange = const RangeValues(0, 1000);
  String _selectedLocation = 'Near me';
  bool _onlyFresh = true;
  bool _onlyOrganic = false;
  final Set<int> _favoriteIndices = {};

  static const _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Grains',
    'Spices',
  ];

  static const _locations = [
    'Near me',
    'Hambantota',
    'Colombo',
    'Kandy',
    'Nuwara Eliya',
    'Jaffna',
  ];

  // Base product catalog
  late List<ProductData> _allProducts;
  late List<ProductData> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _allProducts = [
      ProductData(
        name: 'Tomatoes',
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
        farmer: FarmerData.defaultFarmer,
        category: 'Vegetables',
        isActive: true,
      ),
      ProductData(
        name: 'Carrots',
        price: 'Rs. 300',
        unit: '/kg',
        rating: '4.6',
        reviews: '28',
        availability: 'Available: 15kg',
        emoji: '🥕',
        tag: 'Fresh',
        tagColor: const Color(0xFF1E8342),
        description:
            'Crispy sweet carrots cultivated in natural mineral-rich soil. High in beta-carotene.',
        harvestDate: '19 Aug 2026',
        tags: const ['Organic', 'Farm Fresh'],
        farmer: FarmerData.defaultFarmer,
        category: 'Vegetables',
        isActive: true,
      ),
      ProductData(
        name: 'Potatoes',
        price: 'Rs. 220',
        unit: '/kg',
        rating: '4.8',
        reviews: '45',
        availability: 'Available: 40kg',
        emoji: '🥔',
        tag: null,
        tagColor: null,
        description:
            'Earthy Sri Lankan highland potatoes. Harvested at peak maturity for rich flavor.',
        harvestDate: '16 Aug 2026',
        tags: const ['Highland', 'Natural'],
        farmer: FarmerData.defaultFarmer,
        category: 'Vegetables',
        isActive: true,
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
        tagColor: const Color(0xFF8B5CF6),
        description:
            'Vibrant bell peppers with thick crunchy walls and naturally sweet taste.',
        harvestDate: '20 Aug 2026',
        tags: const ['Greenhouse', 'Premium'],
        farmer: FarmerData.defaultFarmer,
        category: 'Vegetables',
        isActive: true,
      ),
      ProductData(
        name: 'Green Chili',
        price: 'Rs. 450',
        unit: '/kg',
        rating: '4.7',
        reviews: '15',
        availability: 'Available: 10kg',
        emoji: '🌶️',
        tag: 'Spicy',
        tagColor: const Color(0xFFEF4444),
        description:
            'Hot and pungent green chilies hand-picked fresh from organic gardens.',
        harvestDate: '21 Aug 2026',
        tags: const ['Spicy', 'Fresh'],
        farmer: FarmerData.defaultFarmer,
        category: 'Spices',
        isActive: true,
      ),
    ];
    _filteredProducts = List.from(_allProducts);
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    final selectedCategory = _categories[_selectedCategoryIndex];

    setState(() {
      _filteredProducts = _allProducts.where((p) {
        // Query search
        final matchesQuery = query.isEmpty ||
            p.name.toLowerCase().contains(query) ||
            p.tags.any((t) => t.toLowerCase().contains(query));

        // Category filter
        final matchesCategory =
            selectedCategory == 'All' || p.category == selectedCategory;

        // Price filter
        final numericPrice = double.tryParse(
              p.price.replaceAll(RegExp(r'[^0-9.]'), ''),
            ) ??
            0;
        final matchesPrice = numericPrice >= _priceRange.start &&
            numericPrice <= _priceRange.end;

        // Toggles
        final matchesOrganic =
            !_onlyOrganic || p.tags.any((t) => t.toLowerCase().contains('organic'));
        final matchesFresh =
            !_onlyFresh || p.tags.any((t) => t.toLowerCase().contains('fresh'));

        return matchesQuery &&
            matchesCategory &&
            matchesPrice &&
            matchesOrganic &&
            matchesFresh;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark,
              size: 20,
            ),
          ),
        ),
        title: const Text(
          'Search & Filter',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textDark,
                  size: 22,
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
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search Input ─────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 18,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ── Category ─────────────────────────────────────────────────
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_categories.length, (i) {
                  final cat = _categories[i];
                  final isSelected = _selectedCategoryIndex == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategoryIndex = i);
                        _applyFilters();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF235D3A)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 22),

            // ── Price Range ──────────────────────────────────────────────
            const Text(
              'Price Range',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rs. ${_priceRange.start.round()} – Rs. ${_priceRange.end.round()}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF235D3A),
                inactiveTrackColor: const Color(0xFFE5E7EB),
                thumbColor: const Color(0xFF235D3A),
                overlayColor: const Color(0xFF235D3A).withValues(alpha: 0.15),
                trackHeight: 3.5,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 9),
              ),
              child: RangeSlider(
                values: _priceRange,
                min: 0,
                max: 1000,
                divisions: 20,
                onChanged: (values) {
                  setState(() => _priceRange = values);
                  _applyFilters();
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Location ─────────────────────────────────────────────────
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLocation,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF6B7280),
                  ),
                  items: _locations.map((loc) {
                    return DropdownMenuItem<String>(
                      value: loc,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: Color(0xFF235D3A),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            loc,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedLocation = val);
                      _applyFilters();
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Toggles: Only Fresh & Only Organic ───────────────────────
            _ToggleRow(
              icon: Icons.check_circle_outline_rounded,
              title: 'Only Fresh',
              value: _onlyFresh,
              onChanged: (val) {
                setState(() => _onlyFresh = val);
                _applyFilters();
              },
            ),
            const SizedBox(height: 12),
            _ToggleRow(
              icon: Icons.check_circle_outline_rounded,
              title: 'Only Organic',
              value: _onlyOrganic,
              onChanged: (val) {
                setState(() => _onlyOrganic = val);
                _applyFilters();
              },
            ),

            const SizedBox(height: 24),

            // ── Apply Filters CTA ────────────────────────────────────────
            GestureDetector(
              onTap: () {
                _applyFilters();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Filters applied (${_filteredProducts.length} items found)',
                    ),
                    backgroundColor: const Color(0xFF235D3A),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF235D3A),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF235D3A).withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Filtered Results ─────────────────────────────────────────
            const Text(
              'Filtered Results',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),

            if (_filteredProducts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Column(
                  children: [
                    Text('🥬', style: TextStyle(fontSize: 36)),
                    SizedBox(height: 8),
                    Text(
                      'No matching products found',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Try adjusting your search criteria or price range.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredProducts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final p = _filteredProducts[index];
                  final isFav = _favoriteIndices.contains(index);

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: p),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Thumbnail
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryGreen
                                      .withValues(alpha: 0.08),
                                  AppColors.primaryGreen
                                      .withValues(alpha: 0.16),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                p.emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Title and Price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${p.price}${p.unit}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF235D3A),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Heart favorite
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isFav
                                    ? _favoriteIndices.remove(index)
                                    : _favoriteIndices.add(index);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 20,
                                color: isFav
                                    ? Colors.redAccent
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF235D3A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const Spacer(),
        Switch(
          value: value,
          activeColor: const Color(0xFF235D3A),
          activeTrackColor: const Color(0xFF235D3A).withValues(alpha: 0.35),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

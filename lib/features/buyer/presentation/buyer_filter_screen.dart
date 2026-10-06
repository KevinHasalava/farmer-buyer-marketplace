import 'package:flutter/material.dart';

import '../data/buyer_mock_data.dart';
import '../models/buyer_models.dart';
import 'buyer_product_list_screen.dart';

/// 12. Search & Filter Screen / Modal — matching Screenshot 12 with live dynamic filtering
class BuyerFilterScreen extends StatefulWidget {
  const BuyerFilterScreen({
    super.key,
    this.initialCriteria,
  });

  final BuyerFilterCriteria? initialCriteria;

  @override
  State<BuyerFilterScreen> createState() => _BuyerFilterScreenState();
}

class _BuyerFilterScreenState extends State<BuyerFilterScreen> {
  static const Color _forestGreen = Color(0xFF1B5E38);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  late int _selectedCategoryIndex;
  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Grains & Rice',
    'Spices & Herbs',
    'Organic & Traditional',
    'Dairy & Farm Fresh',
  ];

  late RangeValues _priceRange;

  late int _selectedRegionIndex;
  final List<(String, String)> _regions = [
    ('All Sri Lanka', 'Direct from all 9 provinces'),
    ('Nuwara Eliya', 'Highland Cool-Climate'),
    ('Dambulla', 'North Central Veg Hub'),
    ('Kandy', 'Mid-Country Run'),
    ('Welimada', 'Highland Valley Farmlands'),
    ('Matale', 'Spices & Mountain Slopes'),
    ('Jaffna', 'Northern Red Soil Produce'),
    ('Kurunegala', 'Coconut Triangle & Fruits'),
    ('Monaragala', 'Dry Zone Chena & Honey'),
  ];

  late bool _freshHarvestOnly;
  late bool _certifiedOrganic;
  late bool _directFarmDispatch;

  late int _selectedSortIndex;
  final List<(String, String)> _sortOptions = [
    ('Distance (Closest Farm First)', 'Lowest transit carbon footprint'),
    ('Price (Low to High)', 'Best budget values per 1 kg'),
    ('Price (High to Low)', 'Premium export & whole packs'),
    ('Highest Rated Farmer (4.5+ ★)', 'Consistently verified freshness'),
    ('Newest Harvest First', 'Uploaded within today'),
  ];

  @override
  void initState() {
    super.initState();
    final init = widget.initialCriteria ?? const BuyerFilterCriteria();

    // Match category
    final catIdx = _categories.indexWhere(
      (c) => c.toLowerCase() == init.category.toLowerCase(),
    );
    _selectedCategoryIndex = catIdx >= 0 ? catIdx : 0;

    // Price range
    _priceRange = RangeValues(
      init.priceRange.start.clamp(50, 2000),
      init.priceRange.end.clamp(50, 2000),
    );

    // Region
    final regIdx = _regions.indexWhere(
      (r) => r.$1.toLowerCase().contains(init.region.toLowerCase()) ||
          init.region.toLowerCase().contains(r.$1.toLowerCase()),
    );
    _selectedRegionIndex = regIdx >= 0 ? regIdx : 0;

    _freshHarvestOnly = init.freshHarvestOnly;
    _certifiedOrganic = init.certifiedOrganicOnly;
    _directFarmDispatch = init.directFarmDispatch;

    // Sort
    final sortIdx = _sortOptions.indexWhere((s) => s.$1 == init.sortBy);
    _selectedSortIndex = sortIdx >= 0 ? sortIdx : 0;
  }

  BuyerFilterCriteria _buildCurrentCriteria() {
    return BuyerFilterCriteria(
      category: _categories[_selectedCategoryIndex],
      priceRange: _priceRange,
      region: _regions[_selectedRegionIndex].$1,
      freshHarvestOnly: _freshHarvestOnly,
      certifiedOrganicOnly: _certifiedOrganic,
      directFarmDispatch: _directFarmDispatch,
      sortBy: _sortOptions[_selectedSortIndex].$1,
      searchQuery: widget.initialCriteria?.searchQuery ?? '',
    );
  }

  void _resetAll() {
    setState(() {
      _selectedCategoryIndex = 0;
      _priceRange = const RangeValues(50, 2000);
      _selectedRegionIndex = 0;
      _freshHarvestOnly = false;
      _certifiedOrganic = false;
      _directFarmDispatch = false;
      _selectedSortIndex = 0;
    });
  }

  void _applyAndReturn() {
    final criteria = _buildCurrentCriteria();
    if (Navigator.canPop(context)) {
      Navigator.pop(context, criteria);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BuyerProductListScreen(
            categoryTitle: criteria.category == 'All' ? 'Filtered Harvests' : criteria.category,
            filterCriteria: criteria,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final criteria = _buildCurrentCriteria();
    final matchingProducts = BuyerMockData.filterProducts(criteria);
    final activeCount = criteria.activeFiltersCount;

    return Scaffold(
      backgroundColor: _bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filters & Sorting',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$activeCount Active',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _forestGreen,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _resetAll,
            child: const Text(
              'Reset All',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _forestGreen,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Customizing Farm Basket info card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDCFCE7)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: _forestGreen, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Customizing Your Farm Basket',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _forestGreen,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Refine harvest origins, organic purity, price per kg, and dispatch hub.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Categories Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                    Text(
                      _categories[_selectedCategoryIndex],
                      style: const TextStyle(fontSize: 11, color: _forestGreen, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_categories.length, (i) {
                    final isSel = _selectedCategoryIndex == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryIndex = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSel ? _forestGreen : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel ? _forestGreen : const Color(0xFFE2E8F0),
                          ),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: _forestGreen.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          _categories[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSel ? Colors.white : _textDark,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 22),

                // Price Range Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Price Range',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                    Text(
                      'Rs. ${_priceRange.start.round()} - Rs. ${_priceRange.end.round()}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _forestGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('MINIMUM', style: TextStyle(fontSize: 9, color: _textMuted, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              'Rs. ${_priceRange.start.round()}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('-', style: TextStyle(color: _textMuted, fontSize: 18)),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('MAXIMUM', style: TextStyle(fontSize: 9, color: _textMuted, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              'Rs. ${_priceRange.end.round()}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 50,
                  max: 2000,
                  divisions: 39,
                  activeColor: _forestGreen,
                  inactiveColor: const Color(0xFFE2E8F0),
                  onChanged: (values) => setState(() => _priceRange = values),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Rs. 50', style: TextStyle(fontSize: 10, color: _textMuted)),
                      Text('Rs. 1,000', style: TextStyle(fontSize: 10, color: _textMuted)),
                      Text('Rs. 2,000+', style: TextStyle(fontSize: 10, color: _textMuted)),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Sourcing Region
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sourcing Region',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                    Text(
                      _regions[_selectedRegionIndex].$1,
                      style: const TextStyle(fontSize: 11, color: _forestGreen, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: _regions.length,
                  itemBuilder: (context, i) {
                    final (title, sub) = _regions[i];
                    final isSel = _selectedRegionIndex == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedRegionIndex = i),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFF0FDF4) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSel ? _forestGreen : const Color(0xFFE2E8F0),
                            width: isSel ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSel ? _forestGreen : _textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sub,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSel ? const Color(0xFF166534) : _textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 22),

                // Harvest Standards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Harvest Standards',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                    Text(
                      'Verified quality badge',
                      style: TextStyle(fontSize: 11, color: _textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildToggleCard(
                  title: 'Fresh Harvest Today',
                  subtitle: 'Plucked from fields at dawn within 24 hours',
                  value: _freshHarvestOnly,
                  onChanged: (val) => setState(() => _freshHarvestOnly = val),
                ),
                const SizedBox(height: 8),
                _buildToggleCard(
                  title: '100% Certified Organic Only',
                  subtitle: 'Zero synthetic chemical sprays or fertilizers',
                  value: _certifiedOrganic,
                  onChanged: (val) => setState(() => _certifiedOrganic = val),
                ),
                const SizedBox(height: 8),
                _buildToggleCard(
                  title: 'Direct Farm Dispatch',
                  subtitle: 'Direct cold transit straight to your doorstep',
                  value: _directFarmDispatch,
                  onChanged: (val) => setState(() => _directFarmDispatch = val),
                ),
                const SizedBox(height: 22),

                // Sort Results By
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Sort Results By',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                    Text(
                      'Live ordering',
                      style: TextStyle(fontSize: 11, color: _textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...List.generate(_sortOptions.length, (i) {
                  final (title, desc) = _sortOptions[i];
                  final isSel = _selectedSortIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSortIndex = i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFF0FDF4) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel ? _forestGreen : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSel ? _forestGreen : _textMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isSel ? _forestGreen : _textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  desc,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSel ? const Color(0xFF166534) : _textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Bottom Floating Apply Filter bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Clear / Reset
                    OutlinedButton(
                      onPressed: _resetAll,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _textDark,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    // Apply button with live count
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyAndReturn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _forestGreen,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Apply Filters (${matchingProducts.length} ${matchingProducts.length == 1 ? 'Product' : 'Products'})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: _textMuted),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: _forestGreen,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

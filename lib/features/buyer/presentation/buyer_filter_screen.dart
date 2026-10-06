import 'package:flutter/material.dart';

import 'buyer_product_list_screen.dart';

/// 12. Search & Filter Screen / Modal — matching Screenshot 12
class BuyerFilterScreen extends StatefulWidget {
  const BuyerFilterScreen({super.key});

  @override
  State<BuyerFilterScreen> createState() => _BuyerFilterScreenState();
}

class _BuyerFilterScreenState extends State<BuyerFilterScreen> {
  static const Color _forestGreen = Color(0xFF1B5E38);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Grains & Rice',
    'Spices',
    'Organic Only',
  ];

  RangeValues _priceRange = const RangeValues(200, 800);

  int _selectedRegionIndex = 0;
  final List<(String, String)> _regions = [
    ('All Sri Lanka', 'Direct from cooperative hubs'),
    ('Nuwara Eliya', 'Highland Cool-Climate'),
    ('Dambulla', 'North Central'),
    ('Jaffna', 'Northern Produce'),
    ('Kandy', 'Mid-Country Run'),
    ('Kalutara', 'Low-Country Wet'),
  ];

  bool _freshHarvestOnly = true;
  bool _certifiedOrganic = false;
  bool _directFarmDispatch = true;

  int _selectedSortIndex = 0;
  final List<(String, String)> _sortOptions = [
    ('Distance (Closest Farm First)', 'Lowest transit carbon footprint'),
    ('Price (Low to High)', 'Best budget values per 1 kg'),
    ('Highest Rated Farmer (4.5+ ★)', 'Consistently verified freshness'),
    ('Newest Harvest First', 'Uploaded in the last few hours'),
  ];

  void _resetAll() {
    setState(() {
      _selectedCategoryIndex = 0;
      _priceRange = const RangeValues(200, 800);
      _selectedRegionIndex = 0;
      _freshHarvestOnly = true;
      _certifiedOrganic = false;
      _directFarmDispatch = true;
      _selectedSortIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              'Filters',
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
              child: const Text(
                '4 Active',
                style: TextStyle(
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 160),
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
                              'Refine harvest origins, delivery times, and producer standards.',
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
                  children: const [
                    Text(
                      'Categories',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                    Text(
                      'Tap to pick',
                      style: TextStyle(fontSize: 11, color: _textMuted),
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
                  children: const [
                    Text(
                      'Price Range',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                    Text(
                      'Avg. Rs. 380/kg',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _forestGreen),
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
                  min: 100,
                  max: 1500,
                  activeColor: _forestGreen,
                  inactiveColor: const Color(0xFFE2E8F0),
                  onChanged: (values) => setState(() => _priceRange = values),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Rs. 100', style: TextStyle(fontSize: 10, color: _textMuted)),
                      Text('Rs. 760', style: TextStyle(fontSize: 10, color: _textMuted)),
                      Text('Rs. 1,500+', style: TextStyle(fontSize: 10, color: _textMuted)),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Sourcing Region
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Sourcing Region',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                    Text(
                      'Select: All',
                      style: TextStyle(fontSize: 11, color: _forestGreen, fontWeight: FontWeight.w600),
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
                      'Quality & authenticity verified',
                      style: TextStyle(fontSize: 11, color: _textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildToggleCard(
                  title: 'Fresh Harvest Only',
                  subtitle: 'Picked within the last 24 hours',
                  value: _freshHarvestOnly,
                  onChanged: (val) => setState(() => _freshHarvestOnly = val),
                ),
                const SizedBox(height: 8),
                _buildToggleCard(
                  title: '100% Certified Organic',
                  subtitle: 'Zero synthetic chemicals or pests',
                  value: _certifiedOrganic,
                  onChanged: (val) => setState(() => _certifiedOrganic = val),
                ),
                const SizedBox(height: 8),
                _buildToggleCard(
                  title: 'Direct Farm Dispatch',
                  subtitle: 'Farm-made straight from collective',
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
                      'Default: nearest by farm distance',
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
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isSel ? _forestGreen : _textDark,
                                  ),
                                ),
                                Text(
                                  desc,
                                  style: const TextStyle(fontSize: 10, color: _textMuted),
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

          // Floating Bottom Filter Summary & Apply Bar matching Screenshot 12
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mini summary card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: const [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=100&auto=format&fit=crop&q=80',
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '4.8 • Green Valley Collective\n34 matching products ready (Dispatches from Welimada & Kandy at 3:00 PM)',
                              style: TextStyle(fontSize: 10, color: _textMuted, height: 1.25),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: const Icon(Icons.close_rounded, color: _textDark, size: 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BuyerProductListScreen(categoryTitle: 'Filtered Harvests'),
                                ),
                              );
                            },
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: _forestGreen,
                                borderRadius: BorderRadius.circular(23),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Apply Filters (34 Products)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
          Column(
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

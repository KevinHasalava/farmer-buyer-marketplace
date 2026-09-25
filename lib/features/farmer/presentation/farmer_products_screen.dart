import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../dashboard/presentation/farmer_profile_screen.dart';
import '../../dashboard/presentation/product_detail_screen.dart';
import 'add_edit_product_screen.dart';

/// My Products Screen (Farmer management) — matches Figma mockup (Image 4)
class FarmerProductsScreen extends StatefulWidget {
  const FarmerProductsScreen({super.key});

  @override
  State<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen> {
  int _selectedFilter = 0; // 0: All Products, 1: Active, 2: Out of Stock
  int _selectedNav = 0;

  static const _farmer = FarmerData.defaultFarmer;

  static const _filters = ['All Products', 'Active', 'Out of Stock'];

  late List<ProductData> _products;

  @override
  void initState() {
    super.initState();
    _products = [
      ProductData(
        name: 'Tomatoes',
        price: 'Rs. 250',
        unit: '/kg',
        rating: '4.8',
        reviews: '32',
        availability: 'Available: 25 kg',
        emoji: '🍅',
        tag: 'Bestseller',
        tagColor: const Color(0xFFFF6B35),
        description:
            'Fresh and organic tomatoes from our farm. Hand-picked at dawn.',
        harvestDate: '18 Aug 2026',
        tags: const ['Organic', 'Fresh'],
        farmer: _farmer,
        category: 'Vegetables',
        isActive: true,
      ),
      ProductData(
        name: 'Carrots',
        price: 'Rs. 300',
        unit: '/kg',
        rating: '4.6',
        reviews: '28',
        availability: 'Available: 15 kg',
        emoji: '🥕',
        tag: 'Fresh',
        tagColor: const Color(0xFF1E8342),
        description:
            'Crispy sweet carrots cultivated in natural mineral-rich soil.',
        harvestDate: '19 Aug 2026',
        tags: const ['Organic', 'Farm Fresh'],
        farmer: _farmer,
        category: 'Vegetables',
        isActive: true,
      ),
      ProductData(
        name: 'Cucumber',
        price: 'Rs. 200',
        unit: '/kg',
        rating: '4.7',
        reviews: '24',
        availability: 'Available: 10 kg',
        emoji: '🥒',
        tag: 'Hydrating',
        tagColor: const Color(0xFF1E8342),
        description:
            'Freshly harvested crisp cucumbers with high water content.',
        harvestDate: '21 Aug 2026',
        tags: const ['Organic', 'Hydrating'],
        farmer: _farmer,
        category: 'Vegetables',
        isActive: true,
      ),
    ];
  }

  List<ProductData> get _filteredList {
    if (_selectedFilter == 1) {
      return _products.where((p) => p.isActive).toList();
    } else if (_selectedFilter == 2) {
      return _products.where((p) => !p.isActive).toList();
    }
    return _products;
  }

  void _onEditProduct(int index, ProductData prod) async {
    final updated = await Navigator.push<ProductData>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditProductScreen(productToEdit: prod),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _products[index] = updated;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${updated.name} updated successfully!'),
          backgroundColor: const Color(0xFF235D3A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onAddNewProduct() async {
    final newProd = await Navigator.push<ProductData>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditProductScreen(),
      ),
    );

    if (newProd != null && mounted) {
      setState(() {
        _products.insert(0, newProd);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newProd.name} added to your products!'),
          backgroundColor: const Color(0xFF235D3A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmDelete(int index, ProductData prod) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Delete Product',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text('Are you sure you want to delete "${prod.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _products.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${prod.name} deleted'),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredList;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark,
              size: 20,
            ),
          ),
        ),
        title: const Text(
          'My Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
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
          children: [
            // ── Farmer Profile Mini Banner ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E8342), Color(0xFF063725)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFDCFCE7),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _farmer.emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E8342),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _farmer.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: Color(0xFF1E8342),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _farmer.role,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _farmer.location,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
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

            const SizedBox(height: 16),

            // ── Filter Pills: All Products, Active, Out of Stock ─────────
            Row(
              children: List.generate(_filters.length, (i) {
                final isSelected = _selectedFilter == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF235D3A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF235D3A)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        _filters[i],
                        style: TextStyle(
                          fontSize: 12,
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

            const SizedBox(height: 16),

            // ── Add New Product Button ───────────────────────────────────
            GestureDetector(
              onTap: _onAddNewProduct,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF235D3A),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF235D3A).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Add New Product',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ── Product Cards List ───────────────────────────────────────
            if (list.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Column(
                  children: [
                    Text('📦', style: TextStyle(fontSize: 36)),
                    SizedBox(height: 8),
                    Text(
                      'No products in this category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final p = list[index];

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
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
                        // Top info row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryGreen
                                        .withValues(alpha: 0.07),
                                    AppColors.primaryGreen
                                        .withValues(alpha: 0.15),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  p.emoji,
                                  style: const TextStyle(fontSize: 36),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Name, price, availability
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${p.price} ${p.unit}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF235D3A),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    p.availability,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Active pill + 3-dots
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(99),
                                    border: Border.all(
                                      color: const Color(0xFFA7F3D0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Active',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Icon(
                                  Icons.more_horiz_rounded,
                                  color: Color(0xFF9CA3AF),
                                  size: 18,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Action Buttons: Edit | Delete
                        Row(
                          children: [
                            // Edit
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _onEditProduct(index, p),
                                child: Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF235D3A),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Edit',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Delete
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _confirmDelete(index, p),
                                child: Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      // ── Bottom Navigation Bar ──────────────────────────────────────────
      bottomNavigationBar: Container(
        height: 70 + MediaQuery.of(context).padding.bottom,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _FarmerNavBtn(
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: _selectedNav == 0,
              onTap: () {
                setState(() => _selectedNav = 0);
                Navigator.pop(context);
              },
            ),
            _FarmerNavBtn(
              icon: Icons.assignment_outlined,
              label: 'Orders',
              badgeDot: true,
              isSelected: _selectedNav == 1,
              onTap: () => setState(() => _selectedNav = 1),
            ),
            _FarmerNavBtn(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Chat',
              isSelected: _selectedNav == 2,
              onTap: () => setState(() => _selectedNav = 2),
            ),
            _FarmerNavBtn(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              isSelected: _selectedNav == 3,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FarmerProfileScreen(farmer: _farmer),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FarmerNavBtn extends StatelessWidget {
  const _FarmerNavBtn({
    required this.icon,
    required this.label,
    this.badgeDot = false,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool badgeDot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? const Color(0xFF235D3A) : const Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 24, color: color),
                if (badgeDot)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

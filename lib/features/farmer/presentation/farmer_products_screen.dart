import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../dashboard/presentation/farmer_profile_screen.dart';
import '../../dashboard/presentation/product_detail_screen.dart';
import 'add_edit_product_screen.dart';

/// Premium My Products Screen
class FarmerProductsScreen extends StatefulWidget {
  const FarmerProductsScreen({super.key});

  @override
  State<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen>
    with TickerProviderStateMixin {
  int _selectedFilter = 0;
  int _selectedNav = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  static const _farmer = FarmerData.defaultFarmer;
  static const _filters = ['All Products', 'Active', 'Out of Stock'];

  late List<ProductData> _products;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

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
        description: 'Fresh and organic tomatoes from our farm. Hand-picked at dawn.',
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
        description: 'Crispy sweet carrots cultivated in natural mineral-rich soil.',
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
        description: 'Freshly harvested crisp cucumbers with high water content.',
        harvestDate: '21 Aug 2026',
        tags: const ['Organic', 'Hydrating'],
        farmer: _farmer,
        category: 'Vegetables',
        isActive: true,
      ),
    ];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<ProductData> get _filteredList {
    if (_selectedFilter == 1) return _products.where((p) => p.isActive).toList();
    if (_selectedFilter == 2) return _products.where((p) => !p.isActive).toList();
    return _products;
  }

  void _onEditProduct(int index, ProductData prod) async {
    final updated = await Navigator.push<ProductData>(
      context,
      MaterialPageRoute(builder: (_) => AddEditProductScreen(productToEdit: prod)),
    );
    if (updated != null && mounted) {
      setState(() => _products[index] = updated);
      _showPremiumSnackBar('${updated.name} updated successfully! ✅');
    }
  }

  void _onAddNewProduct() async {
    final newProd = await Navigator.push<ProductData>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
    );
    if (newProd != null && mounted) {
      setState(() => _products.insert(0, newProd));
      _showPremiumSnackBar('${newProd.name} added to your products! 🌱');
    }
  }

  void _confirmDelete(int index, ProductData prod) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Delete',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: child,
      ),
      pageBuilder: (ctx, _, __) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFEF4444), size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete Product?',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to delete "${prod.name}"? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() => _products.removeAt(index));
                      _showPremiumSnackBar(
                          '${prod.name} deleted', isError: true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Delete',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF063725),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final list = _filteredList;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F2),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Gradient Header ───────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(context)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),

                  // Filter chips
                  _buildFilterChips(),
                  const SizedBox(height: 16),

                  // Add New Product button
                  _buildAddProductButton(),
                  const SizedBox(height: 20),

                  // Stats summary
                  _buildProductStats(),
                  const SizedBox(height: 20),

                  // Product cards
                  if (list.isEmpty)
                    _buildEmptyState()
                  else
                    ...List.generate(list.length, (i) {
                      // Find real index in _products list
                      final realIndex = _products.indexOf(list[i]);
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: i < list.length - 1 ? 14 : 0),
                        child: _PremiumProductCard(
                          product: list[i],
                          onEdit: () => _onEditProduct(realIndex, list[i]),
                          onDelete: () => _confirmDelete(realIndex, list[i]),
                        ),
                      );
                    }),

                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF063725), Color(0xFF1E8342), Color(0xFF2DA55A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            left: -10,
            bottom: 5,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 17),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Products',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          '${_products.length} products listed',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Farmer mini profile
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const FarmerProfileScreen(farmer: _farmer),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                          ),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1A5C34), Color(0xFF063725)],
                              ),
                            ),
                            child: const Center(
                              child: Text('👨‍🌾',
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded,
                            color: Color(0xFF4ADE80), size: 16),
                      ],
                    ),
                  ),
                  // Notification icon
                  const SizedBox(width: 10),
                  Stack(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: Colors.white, size: 19),
                      ),
                      Positioned(
                        right: 7,
                        top: 7,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBBF24),
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: List.generate(_filters.length, (i) {
        final isSelected = _selectedFilter == i;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF1E8342), Color(0xFF063725)],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1E8342)
                              .withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Text(
                _filters[i],
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAddProductButton() {
    return GestureDetector(
      onTap: _onAddNewProduct,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E8342), Color(0xFF063725)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E8342).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              '+ Add New Product',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductStats() {
    final active = _products.where((p) => p.isActive).length;
    final outOfStock = _products.where((p) => !p.isActive).length;

    return Row(
      children: [
        _MiniStatChip(
          label: 'Total',
          value: '${_products.length}',
          color: const Color(0xFF2563EB),
        ),
        const SizedBox(width: 10),
        _MiniStatChip(
          label: 'Active',
          value: '$active',
          color: const Color(0xFF1E8342),
        ),
        const SizedBox(width: 10),
        _MiniStatChip(
          label: 'Out of Stock',
          value: '$outOfStock',
          color: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Text('📦', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'No products here',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first product to start selling!',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBtn(
            icon: Icons.home_rounded,
            label: 'Home',
            isSelected: _selectedNav == 0,
            onTap: () {
              setState(() => _selectedNav = 0);
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
          _NavBtn(
            icon: Icons.receipt_long_rounded,
            label: 'Orders',
            badgeDot: true,
            isSelected: _selectedNav == 1,
            onTap: () => setState(() => _selectedNav = 1),
          ),
          _NavBtn(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            isSelected: _selectedNav == 2,
            onTap: () => setState(() => _selectedNav = 2),
          ),
          _NavBtn(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            isSelected: _selectedNav == 3,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const FarmerProfileScreen(farmer: _farmer),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini stat chip
// ─────────────────────────────────────────────────────────────────────────────
class _MiniStatChip extends StatelessWidget {
  const _MiniStatChip({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Product Card
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumProductCard extends StatefulWidget {
  const _PremiumProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });
  final ProductData product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_PremiumProductCard> createState() => _PremiumProductCardState();
}

class _PremiumProductCardState extends State<_PremiumProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  // Category gradient map
  static final _categoryColors = {
    'Vegetables': [const Color(0xFF1E8342), const Color(0xFF0D6B35)],
    'Fruits': [const Color(0xFFEA580C), const Color(0xFFC2410C)],
    'Grains': [const Color(0xFFD97706), const Color(0xFFB45309)],
    'Spices': [const Color(0xFFDC2626), const Color(0xFFB91C1C)],
    'Dairy': [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
  };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final colors = _categoryColors[p.category] ??
        [const Color(0xFF1E8342), const Color(0xFF0D6B35)];

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF0F0F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top section
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gradient emoji thumbnail
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors[0].withValues(alpha: 0.12),
                            colors[0].withValues(alpha: 0.25),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: colors[0].withValues(alpha: 0.2)),
                      ),
                      child: Center(
                        child: Text(p.emoji,
                            style: const TextStyle(fontSize: 38)),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Product info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1A1A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                '${p.price}',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: colors[0],
                                ),
                              ),
                              Text(
                                p.unit,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 12,
                                  color: const Color(0xFF6B7280)),
                              const SizedBox(width: 4),
                              Text(
                                p.availability,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Tags
                          Row(
                            children: p.tags
                                .take(2)
                                .map(
                                  (tag) => Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          colors[0].withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      tag,
                                      style: GoogleFonts.poppins(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: colors[0],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    // Status + more menu
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: p.isActive
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: p.isActive
                                  ? const Color(0xFFA7F3D0)
                                  : const Color(0xFFFECACA),
                            ),
                          ),
                          child: Text(
                            p.isActive ? '● Active' : '○ Inactive',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: p.isActive
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _showOptionsMenu(context),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.more_horiz_rounded,
                                color: Color(0xFF6B7280), size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: const Color(0xFFF3F4F6),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Edit button
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.onEdit,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: colors,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: colors[0].withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.edit_outlined,
                                  color: Colors.white, size: 15),
                              const SizedBox(width: 6),
                              Text(
                                'Edit',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Delete button
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.onDelete,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFFFECACA)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.delete_outline_rounded,
                                  color: Color(0xFFEF4444), size: 15),
                              const SizedBox(width: 6),
                              Text(
                                'Delete',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _OptionTile(
              icon: Icons.edit_outlined,
              label: 'Edit Product',
              color: const Color(0xFF1E8342),
              onTap: () {
                Navigator.pop(context);
                widget.onEdit();
              },
            ),
            _OptionTile(
              icon: Icons.visibility_outlined,
              label: 'View Details',
              color: const Color(0xFF2563EB),
              onTap: () => Navigator.pop(context),
            ),
            _OptionTile(
              icon: Icons.toggle_off_outlined,
              label: 'Mark Out of Stock',
              color: const Color(0xFFD97706),
              onTap: () => Navigator.pop(context),
            ),
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete Product',
              color: const Color(0xFFEF4444),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav Button (shared)
// ─────────────────────────────────────────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  const _NavBtn({
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E8342).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? const Color(0xFF1E8342)
                      : const Color(0xFF9CA3AF),
                ),
                if (badgeDot)
                  Positioned(
                    right: -3,
                    top: -3,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF1E8342)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

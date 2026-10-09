import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/theme/app_theme.dart';

import '../../admin/models/admin_models.dart';
import '../../admin/services/admin_marketplace_service.dart';
import '../../dashboard/presentation/farmer_profile_screen.dart';
import '../../dashboard/presentation/product_detail_screen.dart';
import '../services/farmer_profile_manager.dart';
import 'add_edit_product_screen.dart';
import 'farmer_dashboard_screen.dart';

/// Pixel-perfect My Products Screen matching reference design
class FarmerProductsScreen extends StatefulWidget {
  const FarmerProductsScreen({super.key});

  @override
  State<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedFilter = 0;
  int _selectedNav = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  FarmerData get _farmer => FarmerProfileManager.instance.profile.toFarmerData();
  List<String> get _filters => [context.tr.allProducts, context.tr.active, context.tr.outOfStock];

  late List<ProductData> _products;

  @override
  void initState() {
    super.initState();
    FarmerProfileManager.instance.addListener(_onProfileChanged);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

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
        imageUrl:
            'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500&auto=format&fit=crop&q=80',
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
        imageUrl:
            'https://images.unsplash.com/photo-1604977042946-1eecc30f269e?w=400&auto=format&fit=crop&q=80',
      ),
    ];
  }

  void _onProfileChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    FarmerProfileManager.instance.removeListener(_onProfileChanged);
    _fadeController.dispose();
    super.dispose();
  }

  List<ProductData> get _filteredList {
    if (_selectedFilter == 1) {
      return _products.where((p) => p.isActive).toList();
    }
    if (_selectedFilter == 2) {
      return _products.where((p) => !p.isActive).toList();
    }
    return _products;
  }

  AdminProductModel _toAdminProduct(ProductData p) {
    final cleanPrice = p.price.replaceAll('Rs.', '').replaceAll('Rs', '').replaceAll(',', '').trim();
    final priceNum = double.tryParse(cleanPrice) ?? 250.0;
    final cleanQty = p.availability.replaceAll('Available:', '').replaceAll('kg', '').replaceAll('Kg', '').trim();
    final qtyNum = double.tryParse(cleanQty) ?? 50.0;
    return AdminProductModel(
      id: 'prod_${p.name.toLowerCase().replaceAll(' ', '_')}',
      name: p.name,
      category: p.category,
      price: priceNum,
      unit: p.unit,
      availableQty: qtyNum,
      farmName: FarmerProfileManager.instance.profile.farmName,
      farmerName: _farmer.name,
      isOrganic: p.tag?.toLowerCase().contains('organic') == true || p.tags.contains('Organic'),
      imageUrl: p.imageUrl ?? '',
      description: p.description,
      status: p.isActive ? 'In Stock' : 'Out of Stock',
      createdAt: DateTime.now(),
    );
  }

  void _onEditProduct(int index, ProductData prod) async {
    final updated = await Navigator.push<ProductData>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditProductScreen(productToEdit: prod),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _products[index] = updated);
      try {
        AdminMarketplaceService.instance.updateProduct(_toAdminProduct(updated));
      } catch (_) {}
      _showSnackBar(context.tr.productUpdated(updated.name));
    }
  }

  void _onAddNewProduct() async {
    final newProd = await Navigator.push<ProductData>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
    );
    if (newProd != null && mounted) {
      setState(() => _products.insert(0, newProd));
      try {
        AdminMarketplaceService.instance.addProduct(_toAdminProduct(newProd));
      } catch (_) {}
      _showSnackBar(context.tr.productAdded(newProd.name));
    }
  }

  void _toggleProductStatus(int index) {
    setState(() {
      final p = _products[index];
      _products[index] = p.copyWith(isActive: !p.isActive);
    });
    final p = _products[index];
    try {
      AdminMarketplaceService.instance.updateProduct(_toAdminProduct(p));
    } catch (_) {}
    _showSnackBar(
      '${p.name}: ${p.isActive ? context.tr.active : context.tr.outOfStock}',
    );
  }

  void _confirmDelete(int index, ProductData prod) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Delete',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: child,
      ),
      pageBuilder: (ctx, _, __) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFEF4444),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr.deleteProductQuestion,
              style: AppTheme.fontStyle(context.currentLanguage, 
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr.deleteProductConfirm(prod.name),
              textAlign: TextAlign.center,
              style: AppTheme.fontStyle(context.currentLanguage, 
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      context.tr.cancel,
                      style: AppTheme.fontStyle(context.currentLanguage, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() => _products.removeAt(index));
                      try {
                        AdminMarketplaceService.instance.deleteProduct(_toAdminProduct(prod).id);
                      } catch (_) {}
                      _showSnackBar('${prod.name} deleted', isError: true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      context.tr.delete,
                      style: AppTheme.fontStyle(context.currentLanguage, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: AppTheme.fontStyle(context.currentLanguage, fontWeight: FontWeight.w500),
        ),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF235A43),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final list = _filteredList;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // ── Top App Bar ───────────────────────────────────────────
                _buildTopBar(context),
                const SizedBox(height: 18),

                // ── Farmer Profile Card ───────────────────────────────────
                _buildProfileCard(context),
                const SizedBox(height: 18),

                // ── Filter Chips ──────────────────────────────────────────
                _buildFilterChips(),
                const SizedBox(height: 16),

                // ── Add New Product Button ────────────────────────────────
                _buildAddProductButton(),
                const SizedBox(height: 20),

                // ── Product Cards List ────────────────────────────────────
                if (list.isEmpty)
                  _buildEmptyState()
                else
                  ...List.generate(list.length, (i) {
                    final realIndex = _products.indexOf(list[i]);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildProductCard(list[i], realIndex),
                    );
                  }),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ── Top App Bar ─────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(
            Icons.menu_rounded,
            color: Color(0xFF111827),
            size: 26,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text(
          context.tr.myProducts,
          style: AppTheme.fontStyle(context.currentLanguage, 
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        // Bell icon in mint circle with notification dot
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.tr.noProductAlerts,
                  style: AppTheme.fontStyle(context.currentLanguage, ),
                ),
                backgroundColor: const Color(0xFF235A43),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF235A43),
                    size: 22,
                  ),
                ),
                Positioned(
                  top: 7,
                  right: 8,
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
          ),
        ),
      ],
    );
  }

  // ── Farmer Profile Card ─────────────────────────────────────────────────────
  Widget _buildProfileCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FarmerProfileScreen(farmer: _farmer),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular photo with green ring & checkmark badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF22C55E),
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(
                    child: (_farmer.avatarUrl != null && _farmer.avatarUrl!.isNotEmpty)
                        ? (_farmer.avatarUrl!.startsWith('assets/')
                            ? Image.asset(
                                _farmer.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFDCFCE7),
                                  child: const Center(
                                    child: Text('👨‍🌾', style: TextStyle(fontSize: 26)),
                                  ),
                                ),
                              )
                            : Image.network(
                                _farmer.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFDCFCE7),
                                  child: const Center(
                                    child: Text('👨‍🌾', style: TextStyle(fontSize: 26)),
                                  ),
                                ),
                              ))
                        : Container(
                            color: const Color(0xFFDCFCE7),
                            child: const Center(
                              child: Text('👨‍🌾', style: TextStyle(fontSize: 26)),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _farmer.name,
                        style: AppTheme.fontStyle(context.currentLanguage, 
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF235A43),
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr.farmerRole,
                    style: AppTheme.fontStyle(context.currentLanguage, 
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _farmer.location,
                        style: AppTheme.fontStyle(context.currentLanguage, 
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF235A43),
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

  // ── Filter Chips ────────────────────────────────────────────────────────────
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF235A43) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                _filters[i],
                style: AppTheme.fontStyle(context.currentLanguage, 
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF374151),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Add New Product Button ──────────────────────────────────────────────────
  Widget _buildAddProductButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _onAddNewProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF235A43),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, size: 20, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              context.tr.addNewProduct,
              style: AppTheme.fontStyle(context.currentLanguage, 
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Product Card ────────────────────────────────────────────────────────────
  Widget _buildProductCard(ProductData p, int realIndex) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top product info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Produce photo thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: p.imageUrl != null
                      ? Image.network(
                          p.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildFallbackThumbnail(p),
                        )
                      : _buildFallbackThumbnail(p),
                ),
              ),
              const SizedBox(width: 14),

              // Title, price, availability
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.localizedName(context),
                      style: AppTheme.fontStyle(context.currentLanguage, 
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          p.localizedPrice(context),
                          style: AppTheme.fontStyle(context.currentLanguage, 
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          ' ${p.localizedUnit(context)}',
                          style: AppTheme.fontStyle(context.currentLanguage, 
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      p.localizedAvailability(context),
                      style: AppTheme.fontStyle(context.currentLanguage, 
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              // Active pill badge & 3-dots more menu
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: p.isActive
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: p.isActive
                                ? const Color(0xFFA7F3D0)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(
                          p.isActive ? context.tr.active : context.tr.outOfStock,
                          style: AppTheme.fontStyle(context.currentLanguage, 
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: p.isActive
                                ? const Color(0xFF059669)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          color: Color(0xFF9CA3AF),
                          size: 22,
                        ),
                        onSelected: (val) {
                          if (val == 'edit') {
                            _onEditProduct(realIndex, p);
                          } else if (val == 'toggle') {
                            _toggleProductStatus(realIndex);
                          } else if (val == 'delete') {
                            _confirmDelete(realIndex, p);
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 18),
                                const SizedBox(width: 8),
                                Text(context.tr.editProduct),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  p.isActive
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  p.isActive ? context.tr.markOutOfStock : context.tr.markActive,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.tr.delete,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action buttons row: [Edit] and [Delete]
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => _onEditProduct(realIndex, p),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF235A43),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      context.tr.edit,
                      style: AppTheme.fontStyle(context.currentLanguage, 
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () => _confirmDelete(realIndex, p),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF374151),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      context.tr.delete,
                      style: AppTheme.fontStyle(context.currentLanguage, 
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
  }

  Widget _buildFallbackThumbnail(ProductData p) {
    return Container(
      color: const Color(0xFFF0FDF4),
      child: Center(
        child: Text(p.emoji, style: const TextStyle(fontSize: 34)),
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            context.tr.noProductsFound,
            style: AppTheme.fontStyle(context.currentLanguage, 
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.tr.noProductsFilter,
            textAlign: TextAlign.center,
            style: AppTheme.fontStyle(context.currentLanguage, 
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Navigation Bar ───────────────────────────────────────────────────
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home_rounded,
            label: context.tr.home,
            isSelected: _selectedNav == 0,
            onTap: () {
              setState(() => _selectedNav = 0);
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FarmerDashboardScreen(),
                  ),
                );
              }
            },
          ),
          _buildNavItem(
            icon: Icons.assignment_outlined,
            label: context.tr.orders,
            hasBadge: true,
            isSelected: _selectedNav == 1,
            onTap: () => setState(() => _selectedNav = 1),
          ),
          _buildNavItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: context.tr.messages,
            isSelected: _selectedNav == 2,
            onTap: () => setState(() => _selectedNav = 2),
          ),
          _buildNavItem(
            icon: Icons.person_outline_rounded,
            label: context.tr.navProfile,
            isSelected: _selectedNav == 3,
            onTap: () {
              setState(() => _selectedNav = 3);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FarmerProfileScreen(farmer: _farmer),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    bool hasBadge = false,
    required VoidCallback onTap,
  }) {
    const activeColor = Color(0xFF235A43);
    const inactiveColor = Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? activeColor : inactiveColor,
              ),
              if (hasBadge)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.fontStyle(context.currentLanguage, 
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

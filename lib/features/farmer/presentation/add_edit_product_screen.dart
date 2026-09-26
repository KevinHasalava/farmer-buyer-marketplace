import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../dashboard/presentation/product_detail_screen.dart';

/// Pixel-perfect Add/Edit Product Screen matching Screenshot 3
class AddEditProductScreen extends StatefulWidget {
  const AddEditProductScreen({super.key, this.productToEdit});
  final ProductData? productToEdit;

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  late String _selectedProductName;
  late String _selectedCategory;
  late String _selectedImageUrl;
  late String _selectedEmoji;

  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  late DateTime _harvestDate;
  late bool _isOrganic;
  late bool _isFresh;

  static const _productOptions = [
    (
      name: 'Tomatoes',
      emoji: '🍅',
      category: 'Vegetables',
      imageUrl:
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400&auto=format&fit=crop&q=80',
    ),
    (
      name: 'Carrots',
      emoji: '🥕',
      category: 'Vegetables',
      imageUrl:
          'https://images.unsplash.com/photo-1598170845058-32b9d6a5c317?w=400&auto=format&fit=crop&q=80',
    ),
    (
      name: 'Cucumber',
      emoji: '🥒',
      category: 'Vegetables',
      imageUrl:
          'https://images.unsplash.com/photo-1604977042946-1eecc30f269e?w=400&auto=format&fit=crop&q=80',
    ),
    (
      name: 'Potatoes',
      emoji: '🥔',
      category: 'Vegetables',
      imageUrl:
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&auto=format&fit=crop&q=80',
    ),
    (
      name: 'Bell Peppers',
      emoji: '🫑',
      category: 'Vegetables',
      imageUrl:
          'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=400&auto=format&fit=crop&q=80',
    ),
    (
      name: 'Cabbage',
      emoji: '🥬',
      category: 'Vegetables',
      imageUrl:
          'https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f?w=400&auto=format&fit=crop&q=80',
    ),
    (
      name: 'Pumpkin',
      emoji: '🎃',
      category: 'Vegetables',
      imageUrl:
          'https://images.unsplash.com/photo-1508747703725-719777637510?w=400&auto=format&fit=crop&q=80',
    ),
    (
      name: 'Green Chili',
      emoji: '🌶️',
      category: 'Spices',
      imageUrl:
          'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=400&auto=format&fit=crop&q=80',
    ),
    (
      name: 'Banana',
      emoji: '🍌',
      category: 'Fruits',
      imageUrl:
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&auto=format&fit=crop&q=80',
    ),
    (
      name: 'Papaya',
      emoji: '🍈',
      category: 'Fruits',
      imageUrl:
          'https://images.unsplash.com/photo-1517282009859-f000ec3b26fe?w=400&auto=format&fit=crop&q=80',
    ),
    (
      name: 'Mango',
      emoji: '🥭',
      category: 'Fruits',
      imageUrl:
          'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400&auto=format&fit=crop&q=80',
    ),
  ];

  static const _categoryOptions = [
    'Vegetables',
    'Fruits',
    'Grains',
    'Spices',
    'Dairy',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;

    _selectedProductName = p?.name ?? 'Tomatoes';
    _selectedCategory = p?.category ?? 'Vegetables';
    _selectedEmoji = p?.emoji ?? '🍅';
    _selectedImageUrl = p?.imageUrl ??
        _productOptions.firstWhere((o) => o.name == _selectedProductName,
            orElse: () => _productOptions[0]).imageUrl;

    _priceController = TextEditingController(
      text: p != null ? p.price.replaceAll(RegExp(r'[^0-9.]'), '') : '250',
    );
    _quantityController = TextEditingController(
      text:
          p != null ? p.availability.replaceAll(RegExp(r'[^0-9.]'), '') : '50',
    );
    _descriptionController = TextEditingController(
      text: p?.description ?? 'Fresh and organic tomatoes from our farm.',
    );
    _locationController = TextEditingController(
      text: p?.farmer.location ?? 'Hambantota',
    );

    _harvestDate = DateTime(2026, 8, 18);
    _isOrganic = p?.tags.contains('Organic') ?? true;
    _isFresh = p?.tags.contains('Fresh') ?? true;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  void _pickHarvestDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2028),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF235A43),
            onPrimary: Colors.white,
            onSurface: Color(0xFF111827),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _harvestDate = picked);
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Product Photo',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _productOptions.length,
                itemBuilder: (ctx, i) {
                  final opt = _productOptions[i];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImageUrl = opt.imageUrl;
                        _selectedProductName = opt.name;
                        _selectedEmoji = opt.emoji;
                        _selectedCategory = opt.category;
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedImageUrl == opt.imageUrl
                              ? const Color(0xFF235A43)
                              : const Color(0xFFE5E7EB),
                          width: _selectedImageUrl == opt.imageUrl ? 2.5 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          opt.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(opt.emoji,
                                style: const TextStyle(fontSize: 32)),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _saveProduct() {
    HapticFeedback.mediumImpact();
    final price = _priceController.text.trim().isEmpty
        ? '250'
        : _priceController.text.trim();
    final qty = _quantityController.text.trim().isEmpty
        ? '50'
        : _quantityController.text.trim();
    final desc = _descriptionController.text.trim().isEmpty
        ? 'Fresh and organic tomatoes from our farm.'
        : _descriptionController.text.trim();

    final tags = <String>[];
    if (_isOrganic) tags.add('Organic');
    if (_isFresh) tags.add('Fresh');

    final product = ProductData(
      name: _selectedProductName,
      price: 'Rs. $price',
      unit: '/kg',
      rating: widget.productToEdit?.rating ?? '4.8',
      reviews: widget.productToEdit?.reviews ?? '1',
      availability: 'Available: $qty kg',
      emoji: _selectedEmoji,
      tag: _isOrganic ? 'Organic' : (_isFresh ? 'Fresh' : null),
      tagColor: const Color(0xFF235A43),
      description: desc,
      harvestDate: _formatDate(_harvestDate),
      tags: tags.isEmpty ? ['Farm Fresh'] : tags,
      farmer: widget.productToEdit?.farmer ?? FarmerData.defaultFarmer,
      category: _selectedCategory,
      isActive: widget.productToEdit?.isActive ?? true,
      imageUrl: _selectedImageUrl,
    );

    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top App Bar ───────────────────────────────────────────────
            _buildTopBar(context),

            // ── Scrollable Form Fields ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Photo Section (Thumbnail + Dashed Box)
                    _buildPhotoSection(),
                    const SizedBox(height: 20),

                    // Product Name
                    _buildFieldLabel('Product Name'),
                    const SizedBox(height: 6),
                    _buildProductNameDropdown(),
                    const SizedBox(height: 16),

                    // Category
                    _buildFieldLabel('Category'),
                    const SizedBox(height: 6),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),

                    // Side-by-side: Price per Kg & Available Quantity
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Price per Kg (Rs.)'),
                              const SizedBox(height: 6),
                              _buildTextInput(
                                controller: _priceController,
                                hint: '250',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Available Quantity (kg)'),
                              const SizedBox(height: 6),
                              _buildTextInput(
                                controller: _quantityController,
                                hint: '50',
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Harvest Date
                    _buildFieldLabel('Harvest Date'),
                    const SizedBox(height: 6),
                    _buildHarvestDateField(),
                    const SizedBox(height: 16),

                    // Description
                    _buildFieldLabel('Description'),
                    const SizedBox(height: 6),
                    _buildDescriptionInput(),
                    const SizedBox(height: 18),

                    // Toggles Row: Organic & Fresh
                    _buildTogglesRow(),
                    const SizedBox(height: 18),

                    // Location
                    _buildFieldLabel('Location'),
                    const SizedBox(height: 6),
                    _buildLocationField(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Pinned Bottom Button ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF235A43),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Save Product',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top App Bar ─────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF111827),
              size: 30,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Text(
            'Add/Edit Product',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Product notification settings',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: const Color(0xFF235A43),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF111827),
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ── Photo Section ───────────────────────────────────────────────────────────
  Widget _buildPhotoSection() {
    return SizedBox(
      height: 125,
      child: Row(
        children: [
          // Current selected photo thumbnail
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                _selectedImageUrl,
                height: 125,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF0FDF4),
                  child: Center(
                    child: Text(_selectedEmoji,
                        style: const TextStyle(fontSize: 48)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Dashed border Add Photo box
          Expanded(
            child: GestureDetector(
              onTap: _showPhotoOptions,
              child: CustomPaint(
                painter: const _DashedBorderPainter(
                  color: Color(0xFF10B981),
                  strokeWidth: 1.5,
                  radius: 16,
                  dashWidth: 6,
                  dashSpace: 4,
                ),
                child: Container(
                  height: 125,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFBBF7D0),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFF10B981),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add Photo',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Field Label ─────────────────────────────────────────────────────────────
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF374151),
      ),
    );
  }

  // ── Product Name Dropdown ───────────────────────────────────────────────────
  Widget _buildProductNameDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedProductName,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF9CA3AF),
            size: 24,
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF111827),
          ),
          onChanged: (val) {
            if (val != null) {
              final match = _productOptions.firstWhere(
                (o) => o.name == val,
                orElse: () => _productOptions[0],
              );
              setState(() {
                _selectedProductName = val;
                _selectedEmoji = match.emoji;
                _selectedCategory = match.category;
                _selectedImageUrl = match.imageUrl;
              });
            }
          },
          items: _productOptions.map((opt) {
            return DropdownMenuItem<String>(
              value: opt.name,
              child: Text(opt.name),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Category Dropdown ───────────────────────────────────────────────────────
  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF9CA3AF),
            size: 24,
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF111827),
          ),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedCategory = val);
            }
          },
          items: _categoryOptions.map((cat) {
            return DropdownMenuItem<String>(
              value: cat,
              child: Text(cat),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Text Input ──────────────────────────────────────────────────────────────
  Widget _buildTextInput({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF111827),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  // ── Harvest Date Field ──────────────────────────────────────────────────────
  Widget _buildHarvestDateField() {
    return GestureDetector(
      onTap: _pickHarvestDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Color(0xFF059669),
            ),
            const SizedBox(width: 10),
            Text(
              _formatDate(_harvestDate),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Description Input ───────────────────────────────────────────────────────
  Widget _buildDescriptionInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 3,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF111827),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Fresh and organic tomatoes from our farm.',
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  // ── Toggles Row: Organic & Fresh ────────────────────────────────────────────
  Widget _buildTogglesRow() {
    return Row(
      children: [
        // Organic Switch
        _buildSwitchItem(
          label: 'Organic',
          value: _isOrganic,
          onChanged: (v) => setState(() => _isOrganic = v),
        ),
        const SizedBox(width: 32),
        // Fresh Switch
        _buildSwitchItem(
          label: 'Fresh',
          value: _isFresh,
          onChanged: (v) => setState(() => _isFresh = v),
        ),
      ],
    );
  }

  Widget _buildSwitchItem({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CustomSwitch(
            value: value,
            onChanged: onChanged,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  // ── Location Field ──────────────────────────────────────────────────────────
  Widget _buildLocationField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 18,
            color: Color(0xFF059669),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _locationController,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111827),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: 'Hambantota',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Pill Switch matching Screenshot 3
// ─────────────────────────────────────────────────────────────────────────────
class _CustomSwitch extends StatelessWidget {
  const _CustomSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: value ? const Color(0xFF235A43) : const Color(0xFFD1D5DB),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashed Border Painter for Add Photo Container
// ─────────────────────────────────────────────────────────────────────────────
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          nextDistance > metric.length ? metric.length : nextDistance,
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      radius != oldDelegate.radius ||
      dashWidth != oldDelegate.dashWidth ||
      dashSpace != oldDelegate.dashSpace;
}

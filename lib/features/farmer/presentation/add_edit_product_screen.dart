import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../dashboard/presentation/product_detail_screen.dart';

/// Add / Edit Product Screen — matches Figma mockup (Image 5)
class AddEditProductScreen extends StatefulWidget {
  const AddEditProductScreen({super.key, this.productToEdit});

  final ProductData? productToEdit;

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  late String _selectedProductName;
  late String _selectedCategory;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _harvestDate;
  late bool _isOrganic;
  late bool _isFresh;
  late String _selectedEmoji;

  static const _productOptions = [
    ('Tomatoes', '🍅', 'Vegetables'),
    ('Carrots', '🥕', 'Vegetables'),
    ('Potatoes', '🥔', 'Vegetables'),
    ('Bell Peppers', '🫑', 'Vegetables'),
    ('Cucumber', '🥒', 'Vegetables'),
    ('Cabbage', '🥬', 'Vegetables'),
    ('Pumpkin', '🎃', 'Vegetables'),
    ('Green Chili', '🌶️', 'Spices'),
    ('Banana', '🍌', 'Fruits'),
    ('Papaya', '🍈', 'Fruits'),
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
    _priceController = TextEditingController(
      text: p != null ? p.price.replaceAll(RegExp(r'[^0-9.]'), '') : '250',
    );
    _quantityController = TextEditingController(
      text: p != null
          ? p.availability.replaceAll(RegExp(r'[^0-9.]'), '')
          : '50',
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  void _pickHarvestDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2028),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF235D3A),
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _harvestDate = picked);
    }
  }

  void _saveProduct() {
    final name = _selectedProductName;
    final price = _priceController.text.trim().isEmpty
        ? '250'
        : _priceController.text.trim();
    final qty = _quantityController.text.trim().isEmpty
        ? '50'
        : _quantityController.text.trim();
    final desc = _descriptionController.text.trim().isEmpty
        ? 'Fresh and naturally grown from our farm.'
        : _descriptionController.text.trim();

    final tags = <String>[];
    if (_isOrganic) tags.add('Organic');
    if (_isFresh) tags.add('Fresh');

    final updatedProduct = ProductData(
      name: name,
      price: 'Rs. $price',
      unit: '/kg',
      rating: widget.productToEdit?.rating ?? '4.8',
      reviews: widget.productToEdit?.reviews ?? '1',
      availability: 'Available: $qty kg',
      emoji: _selectedEmoji,
      tag: _isOrganic ? 'Organic' : (_isFresh ? 'Fresh' : null),
      tagColor: const Color(0xFF235D3A),
      description: desc,
      harvestDate: _formatDate(_harvestDate),
      tags: tags.isEmpty ? ['Farm Fresh'] : tags,
      farmer: widget.productToEdit?.farmer ?? FarmerData.defaultFarmer,
      category: _selectedCategory,
      isActive: true,
    );

    Navigator.pop(context, updatedProduct);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;

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
        title: Text(
          isEditing ? 'Edit Product' : 'Add/Edit Product',
          style: const TextStyle(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo upload preview row ─────────────────────────────────
            Row(
              children: [
                // Current Photo Preview Card
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF235D3A).withValues(alpha: 0.08),
                          const Color(0xFF235D3A).withValues(alpha: 0.16),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF235D3A).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _selectedEmoji,
                        style: const TextStyle(fontSize: 54),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Dashed "Add Photo" Card
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Cycle or choose emoji icon
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Product Emoji Icon',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 14,
                                runSpacing: 14,
                                children: _productOptions.map((opt) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedProductName = opt.$1;
                                        _selectedEmoji = opt.$2;
                                        _selectedCategory = opt.$3;
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          opt.$2,
                                          style: const TextStyle(fontSize: 28),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF10B981),
                          width: 1.5,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add Photo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF235D3A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Product Name Dropdown ────────────────────────────────────
            _FieldLabel('Product Name'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedProductName,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF6B7280),
                  ),
                  items: _productOptions.map((opt) {
                    return DropdownMenuItem<String>(
                      value: opt.$1,
                      child: Row(
                        children: [
                          Text(opt.$2, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            opt.$1,
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
                      final match = _productOptions.firstWhere((o) => o.$1 == val);
                      setState(() {
                        _selectedProductName = val;
                        _selectedEmoji = match.$2;
                        _selectedCategory = match.$3;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Category Dropdown ────────────────────────────────────────
            _FieldLabel('Category'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF6B7280),
                  ),
                  items: _categoryOptions.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(
                        cat,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCategory = val);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Price & Quantity Side by Side ────────────────────────────
            Row(
              children: [
                // Price per kg
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Price per Kg (Rs.)'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '250',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Available Quantity
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Available Quantity (kg)'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '50',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Harvest Date Picker Field ────────────────────────────────
            _FieldLabel('Harvest Date'),
            GestureDetector(
              onTap: _pickHarvestDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Color(0xFF235D3A),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _formatDate(_harvestDate),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Description ──────────────────────────────────────────────
            _FieldLabel('Description'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 3,
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Fresh and organic produce from our farm...',
                  hintStyle: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Switches: Organic & Fresh ────────────────────────────────
            Row(
              children: [
                // Organic Switch
                Row(
                  children: [
                    Switch(
                      value: _isOrganic,
                      activeThumbColor: const Color(0xFF235D3A),
                      activeTrackColor:
                          const Color(0xFF235D3A).withValues(alpha: 0.35),
                      onChanged: (val) => setState(() => _isOrganic = val),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Organic',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),

                // Fresh Switch
                Row(
                  children: [
                    Switch(
                      value: _isFresh,
                      activeThumbColor: const Color(0xFF235D3A),
                      activeTrackColor:
                          const Color(0xFF235D3A).withValues(alpha: 0.35),
                      onChanged: (val) => setState(() => _isFresh = val),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Fresh',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Location ─────────────────────────────────────────────────
            _FieldLabel('Location'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Hambantota',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Save Product Button ──────────────────────────────────────
            GestureDetector(
              onTap: _saveProduct,
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF235D3A),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF235D3A).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Save Product',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/theme/app_theme.dart';

import '../../dashboard/presentation/product_detail_screen.dart';
import '../services/farmer_profile_manager.dart';

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
          'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500&auto=format&fit=crop&q=80',
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

  static const _sriLankanDistricts = <String>[
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Matara',
    'Monaragala',
    'Mullaitivu',
    'Nuwara Eliya',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya',
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
      text: p?.description ?? '',
    );

    final prof = FarmerProfileManager.instance.profile;
    final defaultLoc = p?.farmer.location ??
        (prof.district.isNotEmpty
            ? prof.district
            : (prof.location.isNotEmpty ? prof.location : 'Hambantota'));

    _locationController = TextEditingController(
      text: defaultLoc,
    );

    _harvestDate = DateTime.now();
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
    final lang = context.currentLanguage;
    if (lang == AppLanguage.sinhala) {
      const sinhalaMonths = [
        'ජනවාරි',
        'පෙබරවාරි',
        'මාර්තු',
        'අප්‍රේල්',
        'මැයි',
        'ජූනි',
        'ජූලි',
        'අගෝස්තු',
        'සැප්තැම්බර්',
        'ඔක්තෝබර්',
        'නොවැම්බර්',
        'දෙසැම්බර්'
      ];
      return '${dt.day} ${sinhalaMonths[dt.month - 1]} ${dt.year}';
    } else if (lang == AppLanguage.tamil) {
      const tamilMonths = [
        'ஜனவரி',
        'பிப்ரவரி',
        'மார்ச்',
        'ஏப்ரல்',
        'மே',
        'ஜூன்',
        'ஜூலை',
        'ஆகஸ்ட்',
        'செப்டம்பர்',
        'அக்டோபர்',
        'நவம்பர்',
        'டிசம்பர்'
      ];
      return '${dt.day} ${tamilMonths[dt.month - 1]} ${dt.year}';
    }
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
              context.tr.selectProductPhoto,
              style: AppTheme.fontStyle(context.currentLanguage, 
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
        ? 'Fresh and high-quality $_selectedProductName directly from our farm.'
        : _descriptionController.text.trim();

    final tags = <String>[];
    if (_isOrganic) tags.add('Organic');
    if (_isFresh) tags.add('Fresh');

    final locText = _locationController.text.trim().isNotEmpty
        ? _locationController.text.trim()
        : (FarmerProfileManager.instance.profile.district.isNotEmpty
            ? FarmerProfileManager.instance.profile.district
            : 'Hambantota');

    final baseFarmer = widget.productToEdit?.farmer ??
        FarmerProfileManager.instance.profile.toFarmerData();
    final updatedFarmer = baseFarmer.copyWith(location: locText);

    // Save location to farmer profile so it persists
    if (_locationController.text.trim().isNotEmpty) {
      FarmerProfileManager.instance.updateProfile(
        location: locText,
        district: locText,
      );
    }

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
      farmer: updatedFarmer,
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
                    _buildFieldLabel(context.tr.productName),
                    const SizedBox(height: 6),
                    _buildProductNameDropdown(),
                    const SizedBox(height: 16),

                    // Category
                    _buildFieldLabel(context.tr.category),
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
                              _buildFieldLabel(context.tr.pricePerKg),
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
                              _buildFieldLabel(context.tr.availableQuantity),
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
                    _buildFieldLabel(context.tr.harvestDate),
                    const SizedBox(height: 6),
                    _buildHarvestDateField(),
                    const SizedBox(height: 16),

                    // Description
                    _buildFieldLabel(context.tr.description),
                    const SizedBox(height: 6),
                    _buildDescriptionInput(),
                    const SizedBox(height: 18),

                    // Toggles Row: Organic & Fresh
                    _buildTogglesRow(),
                    const SizedBox(height: 18),

                    // Location
                    _buildFieldLabel(context.tr.location),
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
                    context.tr.saveProduct,
                    style: AppTheme.fontStyle(context.currentLanguage, 
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
            widget.productToEdit != null ? context.tr.editProduct : context.tr.addEditProduct,
            style: AppTheme.fontStyle(context.currentLanguage, 
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
                    context.tr.productNotificationSettings,
                    style: AppTheme.fontStyle(context.currentLanguage, ),
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
                        context.tr.addPhoto,
                        style: AppTheme.fontStyle(context.currentLanguage, 
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
      style: AppTheme.fontStyle(context.currentLanguage, 
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
          dropdownColor: Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF374151),
            size: 24,
          ),
          style: AppTheme.fontStyle(
            context.currentLanguage,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
          selectedItemBuilder: (context) {
            return _productOptions.map((opt) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${opt.emoji}  ${opt.name.trAuto(context)}',
                  style: AppTheme.fontStyle(
                    context.currentLanguage,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              );
            }).toList();
          },
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
              child: Text(
                '${opt.emoji}  ${opt.name.trAuto(context)}',
                style: AppTheme.fontStyle(
                  context.currentLanguage,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
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
          dropdownColor: Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF374151),
            size: 24,
          ),
          style: AppTheme.fontStyle(
            context.currentLanguage,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
          selectedItemBuilder: (context) {
            return _categoryOptions.map((cat) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  cat.trAuto(context),
                  style: AppTheme.fontStyle(
                    context.currentLanguage,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              );
            }).toList();
          },
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedCategory = val);
            }
          },
          items: _categoryOptions.map((cat) {
            return DropdownMenuItem<String>(
              value: cat,
              child: Text(
                cat.trAuto(context),
                style: AppTheme.fontStyle(
                  context.currentLanguage,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
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
        style: AppTheme.fontStyle(context.currentLanguage, 
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF111827),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintText: hint,
          hintStyle: AppTheme.fontStyle(context.currentLanguage, 
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
              style: AppTheme.fontStyle(context.currentLanguage, 
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
    final hint = context.currentLanguage == AppLanguage.sinhala
        ? 'අපගේ ගොවිපළේ නැවුම් සහ උසස් තත්ත්වයේ අස්වැන්න...'
        : (context.currentLanguage == AppLanguage.tamil
            ? 'எங்கள் பண்ணையிலிருந்து புதிய மற்றும் உயர்தர விளைச்சல்...'
            : 'Fresh and organic produce from our farm.');

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
        style: AppTheme.fontStyle(context.currentLanguage, 
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF111827),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppTheme.fontStyle(context.currentLanguage, 
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
          label: 'Organic'.trAuto(context),
          value: _isOrganic,
          onChanged: (v) => setState(() => _isOrganic = v),
        ),
        const SizedBox(width: 32),
        // Fresh Switch
        _buildSwitchItem(
          label: 'Fresh'.trAuto(context),
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
            style: AppTheme.fontStyle(context.currentLanguage, 
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  // ── District Picker Modal ───────────────────────────────────────────────────
  void _showDistrictPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filtered = _sriLankanDistricts.where((d) {
              final loc = d.trAuto(context).toLowerCase();
              final eng = d.toLowerCase();
              final q = query.toLowerCase().trim();
              return loc.contains(q) || eng.contains(q);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.currentLanguage == AppLanguage.sinhala
                              ? 'දිස්ත්‍රික්කය තෝරන්න'
                              : (context.currentLanguage == AppLanguage.tamil
                                  ? 'மாவட்டத்தைத் தேர்ந்தெடுக்கவும்'
                                  : 'Select District'),
                          style: AppTheme.fontStyle(
                            context.currentLanguage,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22, color: Color(0xFF6B7280)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  // Search Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, size: 20, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (val) {
                                setModalState(() => query = val);
                              },
                              style: AppTheme.fontStyle(
                                context.currentLanguage,
                                fontSize: 14,
                                color: const Color(0xFF111827),
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: context.currentLanguage == AppLanguage.sinhala
                                    ? 'දිස්ත්‍රික්කය සොයන්න...'
                                    : (context.currentLanguage == AppLanguage.tamil
                                        ? 'மாவட்டத்தைத் தேடுங்கள்...'
                                        : 'Search district...'),
                                hintStyle: AppTheme.fontStyle(
                                  context.currentLanguage,
                                  fontSize: 14,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      itemBuilder: (ctx, i) {
                        final dist = filtered[i];
                        final localizedDist = dist.trAuto(context);
                        final currentText = _locationController.text.trim().toLowerCase();
                        final isSelected = currentText == localizedDist.toLowerCase() ||
                            currentText == dist.toLowerCase();

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          onTap: () {
                            setState(() {
                              _locationController.text = localizedDist;
                            });
                            Navigator.pop(ctx);
                          },
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 18,
                              color: isSelected ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                            ),
                          ),
                          title: Text(
                            localizedDist,
                            style: AppTheme.fontStyle(
                              context.currentLanguage,
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? const Color(0xFF059669) : const Color(0xFF111827),
                            ),
                          ),
                          subtitle: localizedDist != dist
                              ? Text(
                                  dist,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                )
                              : null,
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Location Field ──────────────────────────────────────────────────────────
  Widget _buildLocationField() {
    final hint = context.currentLanguage == AppLanguage.sinhala
        ? 'ස්ථානය හෝ දිස්ත්‍රික්කය ඇතුළත් කරන්න'
        : (context.currentLanguage == AppLanguage.tamil
            ? 'இடத்தைத் தட்டச்சு செய்க அல்லது தேர்வுசெய்க'
            : 'Enter location or select district');

    const quickDistricts = [
      'නුවරඑළිය',
      'මහනුවර',
      'බදුල්ල',
      'දඹුල්ල',
      'හම්බන්තොට',
      'කුරුණෑගල',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                size: 20,
                color: Color(0xFF059669),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _locationController,
                  style: AppTheme.fontStyle(context.currentLanguage, 
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintText: hint,
                    hintStyle: AppTheme.fontStyle(context.currentLanguage, 
                      fontSize: 14,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: _showDistrictPicker,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map_outlined, size: 15, color: Color(0xFF059669)),
                      const SizedBox(width: 4),
                      Text(
                        context.currentLanguage == AppLanguage.sinhala
                            ? 'දිස්ත්‍රික්ක'
                            : (context.currentLanguage == AppLanguage.tamil ? 'மாவட்டங்கள்' : 'Districts'),
                        style: AppTheme.fontStyle(
                          context.currentLanguage,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF059669),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down_rounded, size: 16, color: Color(0xFF059669)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: quickDistricts.map((d) {
              final localized = d.trAuto(context);
              final isCurrent = _locationController.text.trim() == localized;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _locationController.text = localized;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCurrent ? const Color(0xFF235A43) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrent ? const Color(0xFF235A43) : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      localized,
                      style: AppTheme.fontStyle(
                        context.currentLanguage,
                        fontSize: 11,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                        color: isCurrent ? Colors.white : const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
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

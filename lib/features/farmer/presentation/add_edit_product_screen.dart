import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../dashboard/presentation/product_detail_screen.dart';

/// Premium Add / Edit Product Screen
class AddEditProductScreen extends StatefulWidget {
  const AddEditProductScreen({super.key, this.productToEdit});
  final ProductData? productToEdit;

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  late String _selectedProductName;
  late String _selectedCategory;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _harvestDate;
  late bool _isOrganic;
  late bool _isFresh;
  late bool _isPremium;
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
    ('Mango', '🥭', 'Fruits'),
    ('Coconut', '🥥', 'Fruits'),
  ];

  static const _categoryOptions = [
    ('Vegetables', '🥦', Color(0xFF1E8342)),
    ('Fruits', '🍎', Color(0xFFEA580C)),
    ('Grains', '🌾', Color(0xFFD97706)),
    ('Spices', '🌶️', Color(0xFFDC2626)),
    ('Dairy', '🥛', Color(0xFF2563EB)),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _fadeAnim =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    final p = widget.productToEdit;
    _selectedProductName = p?.name ?? 'Tomatoes';
    _selectedCategory = p?.category ?? 'Vegetables';
    _selectedEmoji = p?.emoji ?? '🍅';
    _priceController = TextEditingController(
      text: p != null
          ? p.price.replaceAll(RegExp(r'[^0-9.]'), '')
          : '250',
    );
    _quantityController = TextEditingController(
      text: p != null
          ? p.availability.replaceAll(RegExp(r'[^0-9.]'), '')
          : '50',
    );
    _descriptionController = TextEditingController(
      text: p?.description ?? 'Fresh and organic produce from our farm.',
    );
    _locationController = TextEditingController(
      text: p?.farmer.location ?? 'Hambantota',
    );
    _harvestDate = DateTime(2026, 8, 18);
    _isOrganic = p?.tags.contains('Organic') ?? true;
    _isFresh = p?.tags.contains('Fresh') ?? true;
    _isPremium = false;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
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
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1E8342),
            onPrimary: Colors.white,
            onSurface: Color(0xFF1A1A1A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _harvestDate = picked);
  }

  void _saveProduct() {
    HapticFeedback.mediumImpact();
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
    if (_isPremium) tags.add('Premium');

    final product = ProductData(
      name: name,
      price: 'Rs. $price',
      unit: '/kg',
      rating: widget.productToEdit?.rating ?? '4.8',
      reviews: widget.productToEdit?.reviews ?? '1',
      availability: 'Available: $qty kg',
      emoji: _selectedEmoji,
      tag: _isOrganic ? 'Organic' : (_isFresh ? 'Fresh' : null),
      tagColor: const Color(0xFF1E8342),
      description: desc,
      harvestDate: _formatDate(_harvestDate),
      tags: tags.isEmpty ? ['Farm Fresh'] : tags,
      farmer: widget.productToEdit?.farmer ?? FarmerData.defaultFarmer,
      category: _selectedCategory,
      isActive: true,
    );

    Navigator.pop(context, product);
  }

  Color get _categoryColor {
    final match = _categoryOptions.where((c) => c.$1 == _selectedCategory);
    return match.isNotEmpty ? match.first.$3 : const Color(0xFF1E8342);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final isEditing = widget.productToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F2),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(context, isEditing),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Photo section
                        _buildPhotoSection(),
                        const SizedBox(height: 24),

                        // Product Info card
                        _buildSectionCard(
                          title: 'Product Information',
                          icon: Icons.inventory_2_outlined,
                          child: Column(
                            children: [
                              // Product name
                              _buildDropdownField(
                                label: 'Product Name',
                                value: _selectedProductName,
                                items: _productOptions
                                    .map((o) => DropdownMenuItem<String>(
                                          value: o.$1,
                                          child: Row(children: [
                                            Text(o.$2,
                                                style: const TextStyle(
                                                    fontSize: 20)),
                                            const SizedBox(width: 10),
                                            Text(o.$1,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ]),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    final m = _productOptions
                                        .firstWhere((o) => o.$1 == val);
                                    setState(() {
                                      _selectedProductName = val;
                                      _selectedEmoji = m.$2;
                                      _selectedCategory = m.$3;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 14),

                              // Category
                              _buildLabel('Category'),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _categoryOptions.map((cat) {
                                  final isSelected =
                                      _selectedCategory == cat.$1;
                                  return GestureDetector(
                                    onTap: () => setState(
                                        () => _selectedCategory = cat.$1),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(colors: [
                                                cat.$3,
                                                cat.$3.withValues(alpha: 0.7)
                                              ])
                                            : null,
                                        color: isSelected
                                            ? null
                                            : const Color(0xFFF3F4F6),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: cat.$3.withValues(
                                                      alpha: 0.4),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 3),
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(cat.$2,
                                              style: const TextStyle(
                                                  fontSize: 14)),
                                          const SizedBox(width: 6),
                                          Text(
                                            cat.$1,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Pricing & Quantity card
                        _buildSectionCard(
                          title: 'Pricing & Quantity',
                          icon: Icons.attach_money_rounded,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: 'Price per Kg (Rs.)',
                                  controller: _priceController,
                                  hint: '250',
                                  keyboardType: TextInputType.number,
                                  prefixText: 'Rs.',
                                  color: _categoryColor,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildTextField(
                                  label: 'Quantity (kg)',
                                  controller: _quantityController,
                                  hint: '50',
                                  keyboardType: TextInputType.number,
                                  prefixText: 'kg',
                                  color: _categoryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Harvest date & description card
                        _buildSectionCard(
                          title: 'Details',
                          icon: Icons.description_outlined,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Harvest date
                              _buildLabel('Harvest Date'),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _pickHarvestDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: _categoryColor
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                            Icons.calendar_today_outlined,
                                            size: 16,
                                            color: _categoryColor),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _formatDate(_harvestDate),
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 20,
                                          color: Color(0xFF9CA3AF)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Description
                              _buildLabel('Description'),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: const Color(0xFFE5E7EB)),
                                ),
                                child: TextField(
                                  controller: _descriptionController,
                                  maxLines: 3,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(14),
                                    hintText:
                                        'Fresh and organic produce from our farm...',
                                    hintStyle: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quality tags card
                        _buildSectionCard(
                          title: 'Quality Tags',
                          icon: Icons.verified_outlined,
                          child: Column(
                            children: [
                              _buildPremiumToggle(
                                label: 'Organic',
                                description: 'Grown without pesticides',
                                emoji: '🌿',
                                value: _isOrganic,
                                color: const Color(0xFF1E8342),
                                onChanged: (v) =>
                                    setState(() => _isOrganic = v),
                              ),
                              const SizedBox(height: 12),
                              _buildPremiumToggle(
                                label: 'Farm Fresh',
                                description: 'Harvested within 24 hours',
                                emoji: '🌱',
                                value: _isFresh,
                                color: const Color(0xFF059669),
                                onChanged: (v) =>
                                    setState(() => _isFresh = v),
                              ),
                              const SizedBox(height: 12),
                              _buildPremiumToggle(
                                label: 'Premium Quality',
                                description: 'Hand-selected top grade',
                                emoji: '⭐',
                                value: _isPremium,
                                color: const Color(0xFFD97706),
                                onChanged: (v) =>
                                    setState(() => _isPremium = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Location card
                        _buildSectionCard(
                          title: 'Farm Location',
                          icon: Icons.location_on_outlined,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 14),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444)
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                        Icons.location_on_rounded,
                                        size: 16,
                                        color: Color(0xFFEF4444)),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _locationController,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 14),
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
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Save button
                        _buildSaveButton(isEditing),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isEditing) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF063725),
            _categoryColor,
            _categoryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
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
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            left: -15,
            bottom: 0,
            child: Container(
              width: 90,
              height: 90,
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
                    onTap: () => Navigator.pop(context),
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
                          isEditing ? 'Edit Product' : 'Add New Product',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          isEditing
                              ? 'Update your product details'
                              : 'List your fresh produce',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                            border: Border.all(color: Colors.white, width: 1.5),
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

  Widget _buildPhotoSection() {
    return Row(
      children: [
        // Current product preview
        Expanded(
          child: Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _categoryColor.withValues(alpha: 0.1),
                  _categoryColor.withValues(alpha: 0.22),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: _categoryColor.withValues(alpha: 0.25)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(_selectedEmoji,
                      style: const TextStyle(fontSize: 60)),
                ),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        _selectedProductName,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _categoryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Change photo / Add photo
        Expanded(
          child: GestureDetector(
            onTap: () => _showEmojiPicker(),
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF1E8342),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(0xFF1E8342).withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E8342), Color(0xFF063725)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Change Icon',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E8342),
                    ),
                  ),
                  Text(
                    'Tap to select',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
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
              'Select Product',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _productOptions.map((opt) {
                final isSelected = _selectedProductName == opt.$1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedProductName = opt.$1;
                      _selectedEmoji = opt.$2;
                      _selectedCategory = opt.$3;
                    });
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(colors: [
                              Color(0xFF1E8342),
                              Color(0xFF063725)
                            ])
                          : null,
                      color: isSelected ? null : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF1E8342)
                                    .withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(opt.$2,
                          style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child:
                      Icon(icon, size: 16, color: _categoryColor),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: _categoryColor),
              items: items,
              onChanged: onChanged,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    String? prefixText,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              if (prefixText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(13),
                      bottomLeft: Radius.circular(13),
                    ),
                    border: Border(
                        right: BorderSide(
                            color: const Color(0xFFE5E7EB))),
                  ),
                  child: Text(
                    prefixText,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    hintText: hint,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumToggle({
    required String label,
    required String description,
    required String emoji,
    required bool value,
    required Color color,
    required ValueChanged<bool> onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: value ? color.withValues(alpha: 0.06) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? color.withValues(alpha: 0.3) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: color,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE5E7EB),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return GestureDetector(
      onTap: _saveProduct,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_categoryColor, const Color(0xFF063725)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _categoryColor.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEditing ? Icons.save_rounded : Icons.add_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isEditing ? 'Save Changes' : 'Add Product',
              style: GoogleFonts.poppins(
                fontSize: 15,
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
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/constants.dart';
import '../../farmer/presentation/add_edit_product_screen.dart';
import '../../farmer/presentation/farmer_products_screen.dart';
import 'product_detail_screen.dart';

/// Premium Farmer Profile Screen matching Image 2 with dynamic edit capabilities
class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key, required this.farmer});
  final FarmerData farmer;

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  late FarmerData _farmer;

  static const Color _forestGreen = Color(0xFF286A46);
  static const Color _bgSoft = Color(0xFFF9FBFA);
  static const Color _textDark = Color(0xFF1E293B);

  // Products for this farmer with high quality real photographs
  List<ProductData> get _farmerProductData => [
        ProductData(
          name: 'Tomatoes',
          price: 'Rs. 250',
          unit: '/kg',
          rating: '4.7',
          reviews: '32',
          availability: 'Available: 25 kg',
          emoji: '🍅',
          imageUrl:
              'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80',
          tag: 'Bestseller',
          tagColor: const Color(0xFFFF6B35),
          description:
              'Fresh and naturally grown tomatoes from our Hambantota farm. No synthetic chemicals, 100% organic produce.',
          harvestDate: '18 Aug 2026',
          tags: const ['Organic', 'Fresh'],
          farmer: _farmer,
        ),
        ProductData(
          name: 'Carrots',
          price: 'Rs. 300',
          unit: '/kg',
          rating: '4.6',
          reviews: '28',
          availability: 'Available: 15 kg',
          emoji: '🥕',
          imageUrl:
              'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500&auto=format&fit=crop&q=80',
          tag: 'Fresh',
          tagColor: const Color(0xFF1E8342),
          description:
              'Crispy sweet carrots cultivated in natural mineral-rich soil. High in beta-carotene and fiber, washed and packed fresh on harvest morning.',
          harvestDate: '19 Aug 2026',
          tags: const ['Organic', 'Farm Fresh'],
          farmer: _farmer,
        ),
        ProductData(
          name: 'Cucumber',
          price: 'Rs. 200',
          unit: '/kg',
          rating: '4.8',
          reviews: '24',
          availability: 'Available: 30 kg',
          emoji: '🥒',
          imageUrl:
              'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=500&auto=format&fit=crop&q=80',
          tag: 'Organic',
          tagColor: const Color(0xFF1E8342),
          description:
              'Freshly harvested crisp cucumbers with high water content and cool refreshing taste. Ideal for daily salads and hydration.',
          harvestDate: '21 Aug 2026',
          tags: const ['Organic', 'Hydrating'],
          farmer: _farmer,
        ),
      ];

  @override
  void initState() {
    super.initState();
    _farmer = widget.farmer;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showEditProfileModal() {
    final nameCtrl = TextEditingController(text: _farmer.name);
    final roleCtrl = TextEditingController(text: _farmer.role);
    final locCtrl = TextEditingController(text: _farmer.location);
    final expCtrl = TextEditingController(text: _farmer.yearsExperience);
    final custCtrl = TextEditingController(text: _farmer.happyCustomers);
    final aboutCtrl = TextEditingController(text: _farmer.about);
    final phoneCtrl = TextEditingController(text: _farmer.phone ?? '076 323 8225');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Farmer Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Name Field
                _buildEditField(controller: nameCtrl, label: 'Full Name', hint: 'e.g. Sunil Perera'),
                const SizedBox(height: 12),

                // Role Field
                _buildEditField(controller: roleCtrl, label: 'Role / Farm Title', hint: 'e.g. Small-Scale Farmer'),
                const SizedBox(height: 12),

                // Location Field
                _buildEditField(controller: locCtrl, label: 'Location', hint: 'e.g. Hambantota'),
                const SizedBox(height: 12),

                // Phone Field
                _buildEditField(controller: phoneCtrl, label: 'Phone Number', hint: 'e.g. 076 323 8225', keyboardType: TextInputType.phone),
                const SizedBox(height: 12),

                // Experience & Customers row
                Row(
                  children: [
                    Expanded(
                      child: _buildEditField(controller: expCtrl, label: 'Experience', hint: 'e.g. 5+ Years'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildEditField(controller: custCtrl, label: 'Happy Customers', hint: 'e.g. 200+'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // About Me Field
                _buildEditField(
                  controller: aboutCtrl,
                  label: 'About Me',
                  hint: 'Tell buyers about your natural farming methods...',
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _forestGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _farmer = _farmer.copyWith(
                          name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : _farmer.name,
                          role: roleCtrl.text.trim().isNotEmpty ? roleCtrl.text.trim() : _farmer.role,
                          location: locCtrl.text.trim().isNotEmpty ? locCtrl.text.trim() : _farmer.location,
                          phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : _farmer.phone,
                          yearsExperience: expCtrl.text.trim().isNotEmpty ? expCtrl.text.trim() : _farmer.yearsExperience,
                          happyCustomers: custCtrl.text.trim().isNotEmpty ? custCtrl.text.trim() : _farmer.happyCustomers,
                          about: aboutCtrl.text.trim().isNotEmpty ? aboutCtrl.text.trim() : _farmer.about,
                        );
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile details updated successfully!'),
                          backgroundColor: _forestGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: _textDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _forestGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = _farmer;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    final coverImg = f.coverUrl ??
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1000&auto=format&fit=crop&q=80';
    final avatarImg = f.avatarUrl ??
        'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=400&auto=format&fit=crop&q=80';

    return Scaffold(
      backgroundColor: _bgSoft,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Cover + Avatar App Bar matching Image 2 ────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: _textDark,
                    ),
                  ),
                ),
                actions: [
                  // Edit Profile Button in Top Bar
                  GestureDetector(
                    onTap: _showEditProfileModal,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.edit_rounded, size: 14, color: _forestGreen),
                          SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _forestGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Notification Button
                  Container(
                    margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          size: 19,
                          color: _textDark,
                        ),
                        Positioned(
                          right: 9,
                          top: 9,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                title: const Text(
                  'Farmer Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Real landscape cover photograph matching Image 2
                      Image.network(
                        coverImg,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1A5C35), Color(0xFF2E8B4F)],
                            ),
                          ),
                        ),
                      ),
                      // Gradient overlay for visual readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.25),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Bottom curve
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 38,
                          decoration: const BoxDecoration(
                            color: _bgSoft,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                        ),
                      ),
                      // Centered overlapping Avatar with checkmark
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: NetworkImage(avatarImg),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: _forestGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Profile Content ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slide,
                  child: FadeTransition(
                    opacity: _fade,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 100 + bottomPad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Name + verified check icon matching Image 2
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                f.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 19,
                                color: _forestGreen,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            f.role,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Location + Rating line
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: _forestGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                f.location,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFCBD5E1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.star_rounded,
                                size: 15,
                                color: Color(0xFFFFA000),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${f.rating} (${f.reviews} reviews)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ── Stats Row matching Image 2 ─────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  value: f.yearsExperience.contains('+')
                                      ? f.yearsExperience
                                      : '${f.yearsExperience}+',
                                  label: 'Years\nExperience',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _StatCard(
                                  value: f.isOrganic ? '100%' : 'Mixed',
                                  label: 'Organic\nProducts',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _StatCard(
                                  value: f.happyCustomers.contains('+')
                                      ? f.happyCustomers
                                      : '${f.happyCustomers}+',
                                  label: 'Happy\nCustomers',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ── About Me Card matching Image 2 ─────────────────
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFEDF2EF)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'ABOUT ME',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: _textDark,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _showEditProfileModal,
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                        color: _forestGreen,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  f.about,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                    height: 1.55,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── My Products Header ─────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'My Products',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const FarmerProductsScreen(),
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: _forestGreen,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'See All',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Horizontal Real Product Cards
                          SizedBox(
                            height: 165,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _farmerProductData.length,
                              itemBuilder: (context, i) {
                                final prod = _farmerProductData[i];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: _FarmerProductCard(
                                    name: prod.name,
                                    price: '${prod.price}${prod.unit}',
                                    imageUrl: prod.imageUrl,
                                    emoji: prod.emoji,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailScreen(product: prod),
                                      ),
                                    ),
                                  ),
                                );
                              },
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

          // ── Fixed "Add Product" Button matching Image 2 ────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 14 + bottomPad),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _forestGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddEditProductScreen(),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add Product',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat Card for 3 stats row matching Image 2
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDF2EF), width: 1.2),
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Farmer Product Card with Real Photography matching Image 2
// ─────────────────────────────────────────────────────────────────────────────
class _FarmerProductCard extends StatefulWidget {
  const _FarmerProductCard({
    required this.name,
    required this.price,
    this.imageUrl,
    required this.emoji,
    this.onTap,
  });

  final String name;
  final String price;
  final String? imageUrl;
  final String emoji;
  final VoidCallback? onTap;

  @override
  State<_FarmerProductCard> createState() => _FarmerProductCardState();
}

class _FarmerProductCardState extends State<_FarmerProductCard> {
  bool _wishlisted = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDF2EF), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real Image area
              Expanded(
                child: Stack(
                  children: [
                    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                      Image.network(
                        widget.imageUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF1F5F3),
                          child: Center(
                            child: Text(widget.emoji, style: const TextStyle(fontSize: 36)),
                          ),
                        ),
                      )
                    else
                      Container(
                        color: const Color(0xFFF1F5F3),
                        child: Center(
                          child: Text(widget.emoji, style: const TextStyle(fontSize: 36)),
                        ),
                      ),

                    // Heart icon on top right
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _wishlisted = !_wishlisted);
                        },
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _wishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 14,
                            color: _wishlisted ? Colors.redAccent : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.price,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF286A46),
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
}

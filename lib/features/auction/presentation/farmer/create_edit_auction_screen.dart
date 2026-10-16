import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/app_settings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/auction_model.dart';
import '../../services/auction_manager.dart';
import '../../../farmer/services/farmer_profile_manager.dart';

class CreateEditAuctionScreen extends StatefulWidget {
  final AuctionModel? existingAuction;

  const CreateEditAuctionScreen({super.key, this.existingAuction});

  @override
  State<CreateEditAuctionScreen> createState() => _CreateEditAuctionScreenState();
}

class _CreateEditAuctionScreenState extends State<CreateEditAuctionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _cropNameCtrl;
  late TextEditingController _quantityCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _startingPriceCtrl;
  late TextEditingController _minIncrementCtrl;
  late TextEditingController _reservePriceCtrl;
  late TextEditingController _buyNowPriceCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _deliveryTermsCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _imageUrlCtrl;

  String _selectedCategory = 'Vegetables';
  Duration _selectedDuration = const Duration(hours: 24);
  DateTime? _harvestDate;
  bool _isSubmitting = false;

  static const List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Grains & Rice',
    'Spices & Herbs',
    'Dairy & Fresh',
    'Other',
  ];

  static const List<(String, Duration)> _durationOptions = [
    ('12 Hours', Duration(hours: 12)),
    ('24 Hours (1 Day)', Duration(hours: 24)),
    ('48 Hours (2 Days)', Duration(hours: 48)),
    ('3 Days', Duration(days: 3)),
    ('5 Days', Duration(days: 5)),
    ('7 Days', Duration(days: 7)),
  ];

  static const List<(String, String)> _imagePresets = [
    (
      'Paddy/Rice',
      'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&auto=format&fit=crop&q=80',
    ),
    (
      'Carrots',
      'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600&auto=format&fit=crop&q=80',
    ),
    (
      'Potatoes',
      'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&auto=format&fit=crop&q=80',
    ),
    (
      'Chillies',
      'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&auto=format&fit=crop&q=80',
    ),
    (
      'Red Onions',
      'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600&auto=format&fit=crop&q=80',
    ),
    (
      'Cinnamon',
      'https://images.unsplash.com/photo-1509358271058-acd22cc93898?w=600&auto=format&fit=crop&q=80',
    ),
    (
      'Tomatoes',
      'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.existingAuction;
    _cropNameCtrl = TextEditingController(text: a?.cropName ?? '');
    _quantityCtrl = TextEditingController(text: a != null ? a.quantity.toString() : '');
    _unitCtrl = TextEditingController(text: a?.unit ?? 'kg');
    _startingPriceCtrl = TextEditingController(text: a != null ? a.startingPrice.toString() : '');
    _minIncrementCtrl = TextEditingController(text: a != null ? a.minBidIncrement.toString() : '5');
    _reservePriceCtrl = TextEditingController(text: a?.reservePrice != null ? a!.reservePrice.toString() : '');
    _buyNowPriceCtrl = TextEditingController(text: a?.buyNowPrice != null ? a!.buyNowPrice.toString() : '');
    _locationCtrl = TextEditingController(
      text: a?.location ?? (FarmerProfileManager.instance.profile.location.isNotEmpty ? FarmerProfileManager.instance.profile.location : 'Polonnaruwa, Central'),
    );
    _deliveryTermsCtrl = TextEditingController(
      text: a?.deliveryTerms ?? 'Farmgate Pickup / Truck delivery arranged',
    );
    _descriptionCtrl = TextEditingController(text: a?.description ?? '');
    _imageUrlCtrl = TextEditingController(
      text: a?.imageUrl ?? _imagePresets.first.$2,
    );

    if (a != null) {
      _selectedCategory = a.category;
      _harvestDate = a.harvestDate;
    } else {
      _harvestDate = DateTime.now().add(const Duration(days: 2));
    }
  }

  @override
  void dispose() {
    _cropNameCtrl.dispose();
    _quantityCtrl.dispose();
    _unitCtrl.dispose();
    _startingPriceCtrl.dispose();
    _minIncrementCtrl.dispose();
    _reservePriceCtrl.dispose();
    _buyNowPriceCtrl.dispose();
    _locationCtrl.dispose();
    _deliveryTermsCtrl.dispose();
    _descriptionCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickHarvestDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E5E3A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF111827),
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

  Future<void> _submitAuction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    final farmer = FarmerProfileManager.instance.profile;
    final quantity = double.tryParse(_quantityCtrl.text.trim()) ?? 100.0;
    final startingPrice = double.tryParse(_startingPriceCtrl.text.trim()) ?? 100.0;
    final minIncrement = double.tryParse(_minIncrementCtrl.text.trim()) ?? 5.0;
    final reservePrice = double.tryParse(_reservePriceCtrl.text.trim());
    final buyNowPrice = double.tryParse(_buyNowPriceCtrl.text.trim());

    if (widget.existingAuction != null) {
      // Update
      final updated = widget.existingAuction!.copyWith(
        cropName: _cropNameCtrl.text.trim(),
        category: _selectedCategory,
        quantity: quantity,
        unit: _unitCtrl.text.trim(),
        startingPrice: startingPrice,
        minBidIncrement: minIncrement,
        reservePrice: reservePrice,
        buyNowPrice: buyNowPrice,
        description: _descriptionCtrl.text.trim(),
        harvestDate: _harvestDate,
        deliveryTerms: _deliveryTermsCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        imageUrl: _imageUrlCtrl.text.trim(),
      );

      await AuctionManager.instance.updateAuction(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Auction updated successfully!'),
            backgroundColor: Color(0xFF1E5E3A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      // Create
      await AuctionManager.instance.createAuction(
        farmerId: farmer.id.isNotEmpty ? farmer.id : 'farmer_current',
        farmerName: farmer.name.isNotEmpty ? farmer.name : 'Farmer',
        farmerPhone: farmer.phone,
        farmerLocation: farmer.location.isNotEmpty ? farmer.location : _locationCtrl.text.trim(),
        cropName: _cropNameCtrl.text.trim(),
        category: _selectedCategory,
        quantity: quantity,
        unit: _unitCtrl.text.trim(),
        startingPrice: startingPrice,
        minBidIncrement: minIncrement,
        reservePrice: reservePrice,
        buyNowPrice: buyNowPrice,
        description: _descriptionCtrl.text.trim(),
        harvestDate: _harvestDate,
        deliveryTerms: _deliveryTermsCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        imageUrl: _imageUrlCtrl.text.trim(),
        duration: _selectedDuration,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Your crop auction is now LIVE for buyers to bid!'),
            backgroundColor: Color(0xFF1E5E3A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAuction != null;
    const primaryColor = Color(0xFF1E5E3A);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFA),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Crop Auction' : 'Create Crop Auction',
          style: AppTheme.fontStyle(
            context.currentLanguage,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            // Header info banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bulk Harvest Bidding System',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF065F46),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'List your crops for auction. Buyers across Sri Lanka will place bids to get you the highest price.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF047857),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 1. CROP DETAILS SECTION
            _buildSectionHeader('1. Crop Specifications', Icons.eco_rounded),
            const SizedBox(height: 12),
            _buildCardContainer([
              TextFormField(
                controller: _cropNameCtrl,
                decoration: _inputDeco('Crop Name & Variety (e.g. Keeri Samba Rice)', Icons.grass_rounded),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter crop name' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: _inputDeco('Category', Icons.category_outlined),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDeco('Total Quantity', Icons.scale_outlined),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (double.tryParse(val) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _unitCtrl,
                      decoration: _inputDeco('Unit (kg/crate)', Icons.straighten_rounded),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickHarvestDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF1E5E3A)),
                      const SizedBox(width: 10),
                      Text(
                        _harvestDate != null
                            ? 'Harvest Date: ${_harvestDate!.day}/${_harvestDate!.month}/${_harvestDate!.year}'
                            : 'Select Harvest Date',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: Color(0xFF9CA3AF)),
                    ],
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // 2. PRICING & BID RULES
            _buildSectionHeader('2. Pricing & Bidding Rules', Icons.monetization_on_rounded),
            const SizedBox(height: 12),
            _buildCardContainer([
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startingPriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDeco('Starting Bid (Rs./unit)', Icons.sell_outlined),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (double.tryParse(val) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _minIncrementCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDeco('Min. Increment (Rs.)', Icons.trending_up_rounded),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _reservePriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDeco('Reserve Price (Optional)', Icons.lock_outline_rounded),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _buyNowPriceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDeco('Buy-Now Price (Optional)', Icons.flash_on_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '• Reserve Price: Minimum price per unit you agree to sell for.\n• Buy-Now Price: An instant purchase price that ends the auction immediately.',
                style: TextStyle(fontSize: 11, color: Color(0xFF6B7280), height: 1.4),
              ),
            ]),
            const SizedBox(height: 20),

            // 3. SCHEDULE & DURATION
            if (!isEditing) ...[
              _buildSectionHeader('3. Auction Timer / Duration', Icons.timer_outlined),
              const SizedBox(height: 12),
              _buildCardContainer([
                DropdownButtonFormField<Duration>(
                  initialValue: _selectedDuration,
                  decoration: _inputDeco('Auction Duration', Icons.access_time_rounded),
                  items: _durationOptions
                      .map((opt) => DropdownMenuItem(value: opt.$2, child: Text(opt.$1)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDuration = val);
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'The auction will automatically tick down with live countdown timers visible to all verified buyers.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                ),
              ]),
              const SizedBox(height: 20),
            ],

            // 4. LOGISTICS & DESCRIPTION
            _buildSectionHeader('4. Farm Location & Logistics', Icons.local_shipping_outlined),
            const SizedBox(height: 12),
            _buildCardContainer([
              TextFormField(
                controller: _locationCtrl,
                decoration: _inputDeco('Farm Location (District / Town)', Icons.location_on_outlined),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _deliveryTermsCtrl,
                decoration: _inputDeco('Delivery Terms', Icons.handshake_outlined),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 3,
                decoration: _inputDeco('Lot Description & Crop Quality Notes', Icons.notes_rounded),
              ),
            ]),
            const SizedBox(height: 20),

            // 5. CROP PHOTO SELECTION
            _buildSectionHeader('5. Crop Photography', Icons.photo_camera_back_outlined),
            const SizedBox(height: 12),
            _buildCardContainer([
              const Text(
                'Choose a photo preset or paste image URL:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 70,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagePresets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final preset = _imagePresets[idx];
                    final isSelected = _imageUrlCtrl.text == preset.$2;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _imageUrlCtrl.text = preset.$2);
                      },
                      child: Container(
                        width: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? primaryColor : const Color(0xFFE5E7EB),
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(preset.$2, fit: BoxFit.cover),
                            Container(
                              color: Colors.black.withValues(alpha: 0.3),
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.all(2),
                              child: Text(
                                preset.$1,
                                style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                              ),
                            ),
                            if (isSelected)
                              const Positioned(
                                top: 3,
                                right: 3,
                                child: CircleAvatar(
                                  radius: 8,
                                  backgroundColor: primaryColor,
                                  child: Icon(Icons.check, size: 10, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlCtrl,
                decoration: _inputDeco('Image URL', Icons.link_rounded),
              ),
            ]),
            const SizedBox(height: 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitAuction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.rocket_launch_rounded),
                label: Text(
                  isEditing ? 'Save Auction Changes' : 'Publish Live Auction',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1E5E3A)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
      prefixIcon: Icon(icon, size: 19, color: const Color(0xFF9CA3AF)),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E5E3A), width: 1.5),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/localization/app_settings.dart';
import 'package:flutter/services.dart';

import '../../models/admin_models.dart';
import '../../services/admin_marketplace_service.dart';

/// Reusable styling helpers for Admin Dialogs
class AdminDialogHelpers {
  static const Color primaryGreen = Color(0xFF047857);
  static const Color darkSlate = Color(0xFF0F172A);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color bgField = Color(0xFFF8FAFC);

  static Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: darkSlate),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
            prefixIcon: icon != null ? Icon(icon, size: 18, color: primaryGreen) : null,
            filled: true,
            fillColor: bgField,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 🌾 1. FARMER ADD / EDIT DIALOG
// =============================================================================
void showFarmerEditDialog(BuildContext context, {AdminFarmerModel? farmer}) {
  final isEditing = farmer != null;
  final nameCtrl = TextEditingController(text: farmer?.name ?? '');
  final phoneCtrl = TextEditingController(text: farmer?.phone ?? '');
  final farmCtrl = TextEditingController(text: farmer?.farmName ?? '');
  final agrarianCtrl = TextEditingController(text: farmer?.agrarianCenter ?? '');
  final nicCtrl = TextEditingController(text: farmer?.nic ?? '');
  final bankCtrl = TextEditingController(text: farmer?.bankName ?? 'Commercial Bank');
  final accCtrl = TextEditingController(text: farmer?.accountNumber ?? '');

  String selectedDistrict = farmer?.district ?? 'Nuwara Eliya';
  String selectedScale = farmer?.scale ?? '1 - 3 Acres';
  String selectedPractice = farmer?.practice ?? 'Certified Organic (SL-GAP)';
  bool isVerified = farmer?.isVerified ?? true;

  final districts = [
    'Nuwara Eliya',
    'Badulla',
    'Kandy',
    'Matale',
    'Anuradhapura',
    'Polonnaruwa',
    'Kurunegala',
    'Hambantota',
    'Monaragala',
    'Ratnapura',
    'Colombo',
  ];

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setStateModal) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(22),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.agriculture_rounded, color: Color(0xFF047857), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isEditing ? 'Edit Farmer Profile' : 'Add Registered Farmer',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.90,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminDialogHelpers.buildTextField(
                  controller: nameCtrl,
                  label: 'Farmer Legal Name',
                  hint: 'e.g. Sunil Shantha Perera',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                AdminDialogHelpers.buildTextField(
                  controller: phoneCtrl,
                  label: 'Mobile Number',
                  hint: 'e.g. +94763238225',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                AdminDialogHelpers.buildTextField(
                  controller: farmCtrl,
                  label: 'Farm Name / Holdings',
                  hint: 'e.g. Hakgala Organic Highlands',
                  icon: Icons.eco_outlined,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'District',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AdminDialogHelpers.bgField,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AdminDialogHelpers.borderLight),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedDistrict,
                                isExpanded: true,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                                items: districts
                                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setStateModal(() => selectedDistrict = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: agrarianCtrl,
                        label: 'Agrarian Center',
                        hint: 'e.g. Hakgala Center',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: bankCtrl,
                        label: 'Bank Name',
                        hint: 'e.g. Commercial Bank',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: accCtrl,
                        label: 'Account Number',
                        hint: 'e.g. 80041293',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AdminDialogHelpers.buildTextField(
                  controller: nicCtrl,
                  label: 'National Identity Card (NIC)',
                  hint: 'e.g. 197829401928',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 14),
                // Verified Status Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Verified Agri-Partner Badge',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                      ),
                      Switch(
                        value: isVerified,
                        activeThumbColor: const Color(0xFF047857),
                        onChanged: (v) => setStateModal(() => isVerified = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: const TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF047857),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;

              final updatedFarmer = AdminFarmerModel(
                id: isEditing
                    ? farmer.id
                    : 'FRM-${DateTime.now().millisecondsSinceEpoch % 1000}',
                name: name,
                phone: phoneCtrl.text.trim().isNotEmpty
                    ? phoneCtrl.text.trim()
                    : '+94760000000',
                farmName: farmCtrl.text.trim().isNotEmpty
                    ? farmCtrl.text.trim()
                    : '$name\'s Farm',
                district: selectedDistrict,
                agrarianCenter: agrarianCtrl.text.trim().isNotEmpty
                    ? agrarianCtrl.text.trim()
                    : 'Regional Agrarian Office',
                scale: selectedScale,
                practice: selectedPractice,
                crops: farmer?.crops ?? ['Organic Vegetables', 'Highland Produce'],
                nic: nicCtrl.text.trim(),
                bankName: bankCtrl.text.trim(),
                accountNumber: accCtrl.text.trim(),
                isVerified: isVerified,
                status: isVerified ? 'Active' : 'Pending Verification',
                registeredAt: farmer?.registeredAt ?? DateTime.now(),
              );

              Navigator.pop(ctx);

              if (isEditing) {
                await AdminMarketplaceService.instance.updateFarmer(updatedFarmer);
              } else {
                await AdminMarketplaceService.instance.addFarmer(updatedFarmer);
              }

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEditing
                      ? 'Farmer ${updatedFarmer.name} updated!'
                      : 'Farmer ${updatedFarmer.name} registered successfully!'),
                  backgroundColor: const Color(0xFF047857),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(isEditing ? 'Save Changes' : 'Create Farmer'),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// 🛒 2. BUYER ADD / EDIT DIALOG
// =============================================================================
void showBuyerEditDialog(BuildContext context, {AdminBuyerModel? buyer}) {
  final isEditing = buyer != null;
  final nameCtrl = TextEditingController(text: buyer?.name ?? '');
  final emailCtrl = TextEditingController(text: buyer?.email ?? '');
  final phoneCtrl = TextEditingController(text: buyer?.phone ?? '');
  final addressCtrl = TextEditingController(text: buyer?.address ?? '');

  String selectedHub = buyer?.hub ?? 'Colombo Regional Hub (Western)';
  String selectedType = buyer?.buyerType ?? 'Family / Household';
  String selectedStatus = buyer?.status ?? 'Active';

  final hubs = [
    'Colombo Regional Hub (Western)',
    'Colombo Central Regional Hub',
    'Kandy Regional Hub (Central)',
    'Galle Hub (Southern)',
    'Negombo Hub',
  ];

  final buyerTypes = [
    'Family / Household',
    'Restaurant & Hospitality',
    'Retail Organic Store',
    'Wholesale Commercial Buyer',
  ];

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setStateModal) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(22),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF2563EB), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isEditing ? 'Edit Buyer Account' : 'Register New Buyer',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.90,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminDialogHelpers.buildTextField(
                  controller: nameCtrl,
                  label: 'Buyer Full Name',
                  hint: 'e.g. Chaminda Perera',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                AdminDialogHelpers.buildTextField(
                  controller: emailCtrl,
                  label: 'Email Address',
                  hint: 'e.g. buyer@gmail.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                AdminDialogHelpers.buildTextField(
                  controller: phoneCtrl,
                  label: 'Mobile Phone Number',
                  hint: 'e.g. +94771234567',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                AdminDialogHelpers.buildTextField(
                  controller: addressCtrl,
                  label: 'Delivery Street Address',
                  hint: 'e.g. No 45, Flower Road, Colombo 07',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Fulfillment Hub',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AdminDialogHelpers.bgField,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AdminDialogHelpers.borderLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedHub,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                      items: hubs.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                      onChanged: (v) {
                        if (v != null) setStateModal(() => selectedHub = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Buyer Classification',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AdminDialogHelpers.bgField,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AdminDialogHelpers.borderLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedType,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                      items: buyerTypes
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setStateModal(() => selectedType = v);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: const TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;

              final updatedBuyer = AdminBuyerModel(
                id: isEditing
                    ? buyer.id
                    : 'BYR-${DateTime.now().millisecondsSinceEpoch % 1000}',
                name: name,
                email: emailCtrl.text.trim().isNotEmpty
                    ? emailCtrl.text.trim()
                    : '$name@farm2home.lk',
                phone: phoneCtrl.text.trim().isNotEmpty
                    ? phoneCtrl.text.trim()
                    : '+94770000000',
                address: addressCtrl.text.trim().isNotEmpty
                    ? addressCtrl.text.trim()
                    : 'Colombo 07',
                hub: selectedHub,
                buyerType: selectedType,
                totalOrders: buyer?.totalOrders ?? 1,
                totalSpent: buyer?.totalSpent ?? 2500.0,
                status: selectedStatus,
                registeredAt: buyer?.registeredAt ?? DateTime.now(),
              );

              Navigator.pop(ctx);

              if (isEditing) {
                await AdminMarketplaceService.instance.updateBuyer(updatedBuyer);
              } else {
                await AdminMarketplaceService.instance.addBuyer(updatedBuyer);
              }

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEditing
                      ? 'Buyer ${updatedBuyer.name} updated!'
                      : 'Buyer ${updatedBuyer.name} added successfully!'),
                  backgroundColor: const Color(0xFF2563EB),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(isEditing ? 'Save Changes' : 'Create Buyer'),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// 🚚 3. DRIVER ADD / EDIT DIALOG
// =============================================================================
void showDriverEditDialog(BuildContext context, {AdminDriverModel? driver}) {
  final isEditing = driver != null;
  final nameCtrl = TextEditingController(text: driver?.name ?? '');
  final phoneCtrl = TextEditingController(text: driver?.phone ?? '');
  final licenseCtrl = TextEditingController(text: driver?.licenseNumber ?? '');
  final vehicleCtrl = TextEditingController(text: driver?.vehicleType ?? 'Chilled / Refrigerated Van');
  final plateCtrl = TextEditingController(text: driver?.plateNumber ?? '');
  final capacityCtrl = TextEditingController(text: driver?.cargoCapacity ?? '1,200 kg');
  final bankCtrl = TextEditingController(text: driver?.bankName ?? 'Commercial Bank of Ceylon');
  final accCtrl = TextEditingController(text: driver?.accountNumber ?? '');
  bool isOnDuty = driver?.isOnDuty ?? true;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setStateModal) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(22),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_shipping_rounded, color: Color(0xFFD97706), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isEditing ? 'Edit Transit Driver' : 'Register Fleet Driver',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.90,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminDialogHelpers.buildTextField(
                  controller: nameCtrl,
                  label: 'Driver Legal Name',
                  hint: 'e.g. Ranjith Subha Udhasanak',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                AdminDialogHelpers.buildTextField(
                  controller: phoneCtrl,
                  label: 'Driver Contact Phone',
                  hint: 'e.g. +94771234567',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: vehicleCtrl,
                        label: 'Vehicle Category',
                        hint: 'e.g. Refrigerated Van',
                        icon: Icons.local_shipping_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: plateCtrl,
                        label: 'Plate Number',
                        hint: 'e.g. WP NC-4982',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: capacityCtrl,
                        label: 'Cargo Payload Capacity',
                        hint: 'e.g. 1,200 kg',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: licenseCtrl,
                        label: 'Driving License No.',
                        hint: 'e.g. B-8492019',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: bankCtrl,
                        label: 'Bank Account Name',
                        hint: 'e.g. Commercial Bank',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: accCtrl,
                        label: 'Bank Account Number',
                        hint: 'e.g. 8004 1293',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // On-duty toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Active Shift Duty (Available for Dispatch)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                      ),
                      Switch(
                        value: isOnDuty,
                        activeThumbColor: const Color(0xFF047857),
                        onChanged: (v) => setStateModal(() => isOnDuty = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: const TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;

              final updatedDriver = AdminDriverModel(
                id: isEditing
                    ? driver.id
                    : 'DRV-${DateTime.now().millisecondsSinceEpoch % 1000}',
                name: name,
                phone: phoneCtrl.text.trim().isNotEmpty
                    ? phoneCtrl.text.trim()
                    : '+94770000000',
                licenseNumber: licenseCtrl.text.trim().isNotEmpty
                    ? licenseCtrl.text.trim()
                    : 'B-Pending',
                vehicleType: vehicleCtrl.text.trim().isNotEmpty
                    ? vehicleCtrl.text.trim()
                    : 'Refrigerated Van',
                plateNumber: plateCtrl.text.trim().isNotEmpty
                    ? plateCtrl.text.trim()
                    : 'WP-Pending',
                cargoCapacity: capacityCtrl.text.trim().isNotEmpty
                    ? capacityCtrl.text.trim()
                    : '1,000 kg',
                bankName: bankCtrl.text.trim(),
                accountNumber: accCtrl.text.trim(),
                isOnDuty: isOnDuty,
                completedTrips: driver?.completedTrips ?? 0,
                rating: driver?.rating ?? 5.0,
                status: isOnDuty ? 'Active' : 'On Standby',
                registeredAt: driver?.registeredAt ?? DateTime.now(),
              );

              Navigator.pop(ctx);

              if (isEditing) {
                await AdminMarketplaceService.instance.updateDriver(updatedDriver);
              } else {
                await AdminMarketplaceService.instance.addDriver(updatedDriver);
              }

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEditing
                      ? 'Driver ${updatedDriver.name} updated!'
                      : 'Driver ${updatedDriver.name} enrolled in fleet!'),
                  backgroundColor: const Color(0xFFD97706),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(isEditing ? 'Save Changes' : 'Enroll Driver'),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// 🥦 4. PRODUCT ADD / EDIT DIALOG
// =============================================================================
void showProductEditDialog(BuildContext context, {AdminProductModel? product}) {
  final isEditing = product != null;
  final nameCtrl = TextEditingController(text: product?.name ?? '');
  final priceCtrl = TextEditingController(text: product?.price.toStringAsFixed(0) ?? '250');
  final qtyCtrl = TextEditingController(text: product?.availableQty.toStringAsFixed(0) ?? '100');
  final farmCtrl = TextEditingController(text: product?.farmName ?? 'Hakgala Organic Highlands');
  final farmerCtrl = TextEditingController(text: product?.farmerName ?? 'Sunil Shantha');
  final descCtrl = TextEditingController(text: product?.description ?? 'Fresh organic harvest direct from farm.');
  final imgCtrl = TextEditingController(
    text: product?.imageUrl ??
        'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500&auto=format&fit=crop&q=80',
  );

  String selectedCategory = product?.category ?? 'Vegetables';
  String selectedUnit = product?.unit ?? '/kg';
  bool isOrganic = product?.isOrganic ?? true;

  final categories = [
    'Vegetables',
    'Root Vegetables',
    'Leafy Greens',
    'Highland Fruits',
    'Grains & Rice',
    'Herbs & Spices',
  ];

  final units = ['/kg', '/pack', '/bundle', '/piece', '/crate'];

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setStateModal) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(22),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF047857), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isEditing ? 'Edit Produce Listing' : 'Add Marketplace Product',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.90,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminDialogHelpers.buildTextField(
                  controller: nameCtrl,
                  label: 'Product Title',
                  hint: 'e.g. Hakgala Sweet Carrots',
                  icon: Icons.spa_outlined,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AdminDialogHelpers.bgField,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AdminDialogHelpers.borderLight),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCategory,
                                isExpanded: true,
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                                items: categories
                                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setStateModal(() => selectedCategory = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pricing Unit',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AdminDialogHelpers.bgField,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AdminDialogHelpers.borderLight),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedUnit,
                                isExpanded: true,
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
                                items: units
                                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setStateModal(() => selectedUnit = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: priceCtrl,
                        label: 'Price in LKR',
                        hint: 'e.g. 250',
                        keyboardType: TextInputType.number,
                        icon: Icons.payments_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: qtyCtrl,
                        label: 'Available Stock',
                        hint: 'e.g. 150',
                        keyboardType: TextInputType.number,
                        icon: Icons.inventory_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: farmCtrl,
                        label: 'Farm Origin',
                        hint: 'e.g. Hakgala Highlands',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: farmerCtrl,
                        label: 'Producer Farmer',
                        hint: 'e.g. Sunil Shantha',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AdminDialogHelpers.buildTextField(
                  controller: descCtrl,
                  label: 'Harvest Details & Description',
                  hint: 'Naturally cultivated with pure mountain soil...',
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                // Organic Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '100% Certified Organic Produce',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                      ),
                      Switch(
                        value: isOrganic,
                        activeThumbColor: const Color(0xFF047857),
                        onChanged: (v) => setStateModal(() => isOrganic = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: const TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF047857),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;

              final priceVal = double.tryParse(priceCtrl.text.trim()) ?? 250.0;
              final qtyVal = double.tryParse(qtyCtrl.text.trim()) ?? 50.0;

              final updatedProduct = AdminProductModel(
                id: isEditing
                    ? product.id
                    : 'PRD-${DateTime.now().millisecondsSinceEpoch % 1000}',
                name: name,
                category: selectedCategory,
                price: priceVal,
                unit: selectedUnit,
                availableQty: qtyVal,
                farmName: farmCtrl.text.trim().isNotEmpty
                    ? farmCtrl.text.trim()
                    : 'Highland Farm',
                farmerName: farmerCtrl.text.trim().isNotEmpty
                    ? farmerCtrl.text.trim()
                    : 'Highland Farmer',
                isOrganic: isOrganic,
                imageUrl: imgCtrl.text.trim().isNotEmpty
                    ? imgCtrl.text.trim()
                    : 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=500&auto=format&fit=crop&q=80',
                description: descCtrl.text.trim(),
                status: qtyVal > 10 ? 'In Stock' : (qtyVal > 0 ? 'Low Stock' : 'Out of Stock'),
                createdAt: product?.createdAt ?? DateTime.now(),
              );

              Navigator.pop(ctx);

              if (isEditing) {
                await AdminMarketplaceService.instance.updateProduct(updatedProduct);
              } else {
                await AdminMarketplaceService.instance.addProduct(updatedProduct);
              }

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEditing
                      ? 'Product ${updatedProduct.name} updated!'
                      : 'Product ${updatedProduct.name} listed on Marketplace!'),
                  backgroundColor: const Color(0xFF047857),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(isEditing ? 'Save Changes' : 'List Product'),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// 📦 5. ORDER ADD / EDIT / DISPATCH DIALOG
// =============================================================================
void showOrderEditDialog(BuildContext context, {AdminOrderModel? order}) {
  final isEditing = order != null;
  final custCtrl = TextEditingController(text: order?.customerName ?? '');
  final phoneCtrl = TextEditingController(text: order?.customerPhone ?? '');
  final farmCtrl = TextEditingController(text: order?.farmName ?? 'Hakgala Organic Highlands');
  final itemsCtrl = TextEditingController(text: order?.itemsSummary ?? '5 kg Carrots, 2 kg Leeks');
  final amountCtrl = TextEditingController(text: order?.totalAmount.toStringAsFixed(0) ?? '1500');
  final addressCtrl = TextEditingController(text: order?.deliveryAddress ?? 'No 45, Flower Road, Colombo 07');

  String selectedStatus = order?.status ?? 'Pending';
  String selectedDriver = order?.assignedDriverName ?? 'Unassigned';

  final statuses = [
    'Pending',
    'Confirmed',
    'Picked Up',
    'In Transit',
    'Delivered',
    'Cancelled',
  ];

  final driverOptions = [
    'Unassigned',
    'Ranjith Subha (NC-4982)',
    'Samantha Jayawardena (LY-3819)',
    'Priyashantha Kumara (DA-8291)',
  ];

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setStateModal) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(22),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.inventory_rounded, color: Color(0xFF7E22CE), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isEditing ? 'Manage Order ${order.id}' : 'Create Manual Order',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.90,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: custCtrl,
                        label: 'Customer Name',
                        hint: 'e.g. Chaminda Perera',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: phoneCtrl,
                        label: 'Customer Phone',
                        hint: 'e.g. +94771234567',
                        icon: Icons.phone_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AdminDialogHelpers.buildTextField(
                  controller: itemsCtrl,
                  label: 'Items & Produce Ordered',
                  hint: 'e.g. 5 kg Carrots, 2 kg Leeks',
                  icon: Icons.shopping_basket_outlined,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: amountCtrl,
                        label: 'Total Amount (LKR)',
                        hint: 'e.g. 2450',
                        keyboardType: TextInputType.number,
                        icon: Icons.attach_money_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminDialogHelpers.buildTextField(
                        controller: farmCtrl,
                        label: 'Sourcing Farm',
                        hint: 'e.g. Hakgala Organic',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AdminDialogHelpers.buildTextField(
                  controller: addressCtrl,
                  label: 'Delivery Destination Address',
                  hint: 'e.g. Colombo 07',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),
                // Order Status Dropdown
                const Text(
                  'Order Lifecycle Status',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AdminDialogHelpers.bgField,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AdminDialogHelpers.borderLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStatus,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                      items: statuses
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setStateModal(() => selectedStatus = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Driver Dispatch Assign Dropdown
                const Text(
                  'Assign Transit Delivery Driver',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AdminDialogHelpers.bgField,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AdminDialogHelpers.borderLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDriver,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                      items: driverOptions
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setStateModal(() => selectedDriver = v);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: const TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7E22CE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final custName = custCtrl.text.trim();
              if (custName.isEmpty) return;

              final totalAmt = double.tryParse(amountCtrl.text.trim()) ?? 1500.0;

              final updatedOrder = AdminOrderModel(
                id: isEditing
                    ? order.id
                    : 'FH-${8850 + (DateTime.now().millisecondsSinceEpoch % 1000)}',
                customerName: custName,
                customerPhone: phoneCtrl.text.trim().isNotEmpty
                    ? phoneCtrl.text.trim()
                    : '+94770000000',
                farmName: farmCtrl.text.trim().isNotEmpty
                    ? farmCtrl.text.trim()
                    : 'Local Organic Farm',
                itemsSummary: itemsCtrl.text.trim().isNotEmpty
                    ? itemsCtrl.text.trim()
                    : 'Fresh Produce Assortment',
                totalAmount: totalAmt,
                status: selectedStatus,
                deliveryAddress: addressCtrl.text.trim().isNotEmpty
                    ? addressCtrl.text.trim()
                    : 'Colombo Western Province',
                assignedDriverName: selectedDriver,
                assignedDriverPhone: selectedDriver == 'Unassigned' ? '' : '+94771234567',
                orderDate: order?.orderDate ?? DateTime.now(),
              );

              Navigator.pop(ctx);

              if (isEditing) {
                await AdminMarketplaceService.instance.updateOrder(updatedOrder);
              } else {
                await AdminMarketplaceService.instance.addOrder(updatedOrder);
              }

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEditing
                      ? 'Order #${updatedOrder.id} dispatch updated!'
                      : 'Order #${updatedOrder.id} registered!'),
                  backgroundColor: const Color(0xFF7E22CE),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(isEditing ? 'Save Changes' : 'Create Order'),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// 🗑️ 6. UNIVERSAL DELETE CONFIRMATION DIALOG
// =============================================================================
void showDeleteConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required VoidCallback onConfirmed,
}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(context.tr.cancel, style: const TextStyle(color: Color(0xFF64748B))),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            HapticFeedback.heavyImpact();
            Navigator.pop(ctx);
            onConfirmed();
          },
          child: const Text('Delete Record', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}

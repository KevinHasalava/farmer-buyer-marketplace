import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/routes/app_router.dart';
import '../../../services/auth_service.dart';
import '../../../services/notify_sms_service.dart';
import '../../farmer/services/farmer_profile_manager.dart';
import 'otp_verification_dialog.dart';

/// Farmer / Producer Registration Screen — matching Farm2Home design.
class FarmerRegistrationScreen extends StatefulWidget {
  const FarmerRegistrationScreen({super.key});

  @override
  State<FarmerRegistrationScreen> createState() =>
      _FarmerRegistrationScreenState();
}

class _FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = const AuthService();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _nicCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _farmNameCtrl = TextEditingController();
  final _agrarianCenterCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();

  // State
  String? _selectedDistrict = 'Nuwara Eliya';
  String _selectedScale = '1 - 3 Acres';
  String _selectedPractice = 'Certified Organic (SL-GAP)';
  bool _otpVerified = false;
  bool _otpSending = false;
  bool _isAttached = false;
  bool _isLoading = false;

  final Set<String> _selectedCrops = {
    'Carrots & Root Veg',
    'Leeks & Cabbage',
  };

  final List<String> _districts = [
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
    'Jaffna',
  ];

  final List<String> _cropOptions = [
    'Carrots & Root Veg',
    'Leeks & Cabbage',
    'Strawberries',
    'Tomatoes',
    'Leafy Greens (Gotukola)',
    'Heirloom Rice / Grains',
  ];

  final List<String> _scaleOptions = [
    'Under 1 Acre',
    '1 - 3 Acres',
    '3 - 10 Acres',
    '10+ Acres',
  ];

  final List<String> _practiceOptions = [
    'Certified Organic (SL-GAP)',
    'Chemical-Free / Natural',
    'Conventional GAP',
    'In-Conversion',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicCtrl.dispose();
    _phoneCtrl.dispose();
    _farmNameCtrl.dispose();
    _agrarianCenterCtrl.dispose();
    _bankCtrl.dispose();
    _accountNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final rawPhone = _phoneCtrl.text.trim();
    if (rawPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your mobile phone number first.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!NotifySmsService.isValidSriLankanMobile(rawPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please enter a valid Sri Lankan mobile number (e.g., 77 234 5678).'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _otpSending = true);

    final res = await NotifySmsService.instance.sendOtp(rawPhone);

    if (!mounted) return;
    setState(() => _otpSending = false);

    if (res.success) {
      OtpVerificationSheet.show(
        context,
        rawPhone: rawPhone,
        onVerified: () {
          setState(() => _otpVerified = true);
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.error ?? 'Could not send SMS.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      OtpVerificationSheet.show(
        context,
        rawPhone: rawPhone,
        onVerified: () {
          setState(() => _otpVerified = true);
        },
      );
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_otpVerified) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please verify your mobile number with the SMS OTP code first.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _sendOtp();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameCtrl.text.trim();

      // Persist real farmer registration details to Supabase & cache
      await FarmerProfileManager.instance.saveRegistrationData(
        name: name,
        phone: _phoneCtrl.text.trim(),
        farmName: _farmNameCtrl.text.trim(),
        district: _selectedDistrict ?? 'Nuwara Eliya',
        agrarianCenter: _agrarianCenterCtrl.text.trim(),
        scale: _selectedScale,
        practice: _selectedPractice,
        crops: _selectedCrops.toList(),
        nic: _nicCtrl.text.trim(),
        bankName: _bankCtrl.text.trim(),
        accountNumber: _accountNumberCtrl.text.trim(),
      );

      if (name.isNotEmpty) {
        await _authService.updateProfile(
          fullName: name,
          role: 'farmer',
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
      }

      if (!mounted) return;
      await context.read<AppSettings>().setRole(UserRole.farmer);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration error: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF1E8342),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr.producerAccountRegistered,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr.producerWelcomeMsg,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go(AppRoutes.farmerDashboard);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E8342),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.tr.goToFarmerDashboard,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.phoneAuth);
            }
          },
        ),
        title: Text(
          'Phone Authentication',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF1E8342),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Producer Portal Pill ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.agriculture_rounded,
                        color: Color(0xFF1E8342),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr.producerPortalPill,
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 0.8,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          context.tr.farmerGrowerPartner,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.roleSelection),
                      child: Text(
                        context.tr.changeRole,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E8342),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Title & Subtitle ───────────────────────────────────────────
              Text(
                context.tr.registerFarmerTitle,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr.farmerRegisterSub,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 14),

              // ── Govt Agrarian Partnership Callout ──────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E7FF)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=200&auto=format&fit=crop&q=80',
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 44,
                          height: 44,
                          color: const Color(0xFFC7D2FE),
                          child: const Icon(
                            Icons.landscape_rounded,
                            color: Color(0xFF4338CA),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF16A34A),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                context.tr.govtAgrarianPartnership,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF16A34A),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr.registeredWithAgrarianCollective,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            context.tr.freeCrateCollection,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Section 1: Producer Details ────────────────────────────────
              _buildSectionHeader(
                icon: Icons.badge_outlined,
                title: context.tr.producerDetails,
              ),
              const SizedBox(height: 12),

              _buildFieldLabel(context.tr.fullNameFarmLead),
              _buildTextInput(
                controller: _nameCtrl,
                hintText: 'e.g., K. M. Bandara',
                icon: Icons.person_outline_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
              ),

              const SizedBox(height: 14),

              _buildFieldLabel(context.tr.nicLabel),
              _buildTextInput(
                controller: _nicCtrl,
                hintText: 'e.g., 198214502341 or 821452341V',
                icon: Icons.credit_card_outlined,
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFieldLabel(context.tr.mobileNumber),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: _otpVerified
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _otpVerified
                          ? context.tr.smsOtpVerified
                          : context.tr.smsOtpVerification,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _otpVerified
                            ? const Color(0xFF15803D)
                            : const Color(0xFFE65100),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _otpVerified
                        ? const Color(0xFF15803D)
                        : const Color(0xFFE2E8F0),
                    width: _otpVerified ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Text(
                        '+94',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        enabled: !_otpVerified,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          hintText: '77 234 5678',
                          hintStyle: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.textHint,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton(
                        onPressed: _otpSending
                            ? null
                            : (_otpVerified ? null : _sendOtp),
                        style: TextButton.styleFrom(
                          backgroundColor: _otpVerified
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFF15803D),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _otpSending
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_otpVerified) ...[
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 14,
                                      color: Color(0xFF15803D),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      context.tr.verified,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ] else ...[
                                    const Icon(
                                      Icons.sms_outlined,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      context.tr.sendOtp,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _buildFieldLabel(context.tr.farmNameLabel),
              _buildTextInput(
                controller: _farmNameCtrl,
                hintText: 'e.g., Hakgala Mountain Organic Gardens',
                icon: Icons.local_florist_outlined,
              ),

              const SizedBox(height: 22),

              // ── Section 2: Location & Logistics Hub ────────────────────────
              _buildSectionHeader(
                icon: Icons.location_on_outlined,
                title: context.tr.locationLogisticsHub,
              ),
              const SizedBox(height: 12),

              _buildFieldLabel(context.tr.farmingRegionDistrict),
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDistrict,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                          onChanged: (val) =>
                              setState(() => _selectedDistrict = val),
                          items: _districts.map((d) {
                            return DropdownMenuItem(value: d, child: Text(d));
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _buildFieldLabel(context.tr.nearestAgrarianCenter),
              _buildTextInput(
                controller: _agrarianCenterCtrl,
                hintText: 'e.g., Hakgala Agrarian Center #04',
                icon: Icons.storefront_outlined,
              ),

              const SizedBox(height: 22),

              // ── Section 3: Crops & Scale ───────────────────────────────────
              _buildSectionHeader(
                icon: Icons.grass_rounded,
                title: context.tr.cropsAndScale,
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFieldLabel(context.tr.primaryCropsHarvestTypes),
                  Text(
                    context.tr.selectMultiple,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _cropOptions.map((crop) {
                  final isSel = _selectedCrops.contains(crop);
                  return FilterChip(
                    label: Text(crop),
                    selected: isSel,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCrops.add(crop);
                        } else {
                          _selectedCrops.remove(crop);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF15803D),
                    checkmarkColor: Colors.white,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSel
                            ? const Color(0xFF15803D)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isSel ? Colors.white : AppColors.textDark,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              _buildFieldLabel(context.tr.totalCultivationArea),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: _scaleOptions.map((scale) {
                  final isSel = _selectedScale == scale;
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedScale = scale);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFFDCFCE7) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFE2E8F0),
                          width: isSel ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSel
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            size: 16,
                            color: isSel
                                ? const Color(0xFF16A34A)
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              scale,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight:
                                    isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel
                                    ? const Color(0xFF166534)
                                    : AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              _buildFieldLabel(context.tr.farmingPracticeCertification),
              Column(
                children: _practiceOptions.map((prac) {
                  final isSel = _selectedPractice == prac;
                  final isTopRate = prac.contains('Certified Organic');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedPractice = prac);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFDCFCE7) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFE2E8F0),
                            width: isSel ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSel
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              size: 16,
                              color: isSel
                                  ? const Color(0xFF16A34A)
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                prac,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      isSel ? FontWeight.w700 : FontWeight.w500,
                                  color: isSel
                                      ? const Color(0xFF166534)
                                      : AppColors.textDark,
                                ),
                              ),
                            ),
                            if (isTopRate)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBBF7D0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  context.tr.topRate,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // ── Section 4: Direct Bank Payouts ─────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader(
                    icon: Icons.account_balance_outlined,
                    title: context.tr.directBankPayouts,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      context.tr.dailyWeekly,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.tr.zeroCommissionBankSettlement,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              _buildFieldLabel(context.tr.bankNameBranch),
              _buildTextInput(
                controller: _bankCtrl,
                hintText: 'e.g., Bank of Ceylon - Nuwara Eliya Branch',
                icon: Icons.account_balance_rounded,
              ),

              const SizedBox(height: 14),

              _buildFieldLabel(context.tr.accountNumberLabel),
              _buildTextInput(
                controller: _accountNumberCtrl,
                hintText: 'e.g., 008432198001',
                icon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 22),

              // ── Section 5: Certificates & Land Deed ────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader(
                    icon: Icons.document_scanner_outlined,
                    title: context.tr.certificatesLandDeed,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      context.tr.optionalNow,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.tr.uploadLandDeedDesc,
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isAttached = !_isAttached);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isAttached
                            ? 'Documents attached successfully!'
                            : 'Documents cleared',
                      ),
                      backgroundColor: const Color(0xFF1E8342),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _isAttached
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isAttached
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isAttached
                            ? Icons.check_circle_rounded
                            : Icons.attach_file_rounded,
                        size: 18,
                        color: const Color(0xFF15803D),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isAttached
                            ? 'Agrarian_Deed_Doc.pdf Attached'
                            : context.tr.attachPhotosDocuments,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // ── Submit Button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.tr.registerMyFarm,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Already registered? Log In ─────────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.tr.alreadyRegisteredFarmer,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.phoneAuth),
                      child: Text(
                        context.tr.login,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF15803D),
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

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF15803D)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 13,
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

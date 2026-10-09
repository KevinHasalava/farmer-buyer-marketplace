import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../services/auth_service.dart';
import '../../../services/notify_sms_service.dart';
import '../../../widgets/premium/google_brand_button.dart';
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

  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    if (SupabaseConfig.isInitialized) {
      _authSubscription =
          SupabaseConfig.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        if (session != null && mounted) {
          final sbUser = session.user;
          final metadata = sbUser.userMetadata ?? {};
          await context.read<AppSettings>().setRole(UserRole.farmer);
          final effectiveName = (metadata['full_name'] as String?) ??
              sbUser.email?.split('@').first ??
              'Farmer';
          await FarmerProfileManager.instance.updateProfile(
            name: effectiveName,
            email: sbUser.email,
          );
          if (mounted) {
            context.go(AppRoutes.farmerDashboard);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _nameCtrl.dispose();
    _nicCtrl.dispose();
    _phoneCtrl.dispose();
    _farmNameCtrl.dispose();
    _agrarianCenterCtrl.dispose();
    _bankCtrl.dispose();
    _accountNumberCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    try {
      await _authService.signInWithGoogle();
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtp() async {
    final rawPhone = _phoneCtrl.text.trim();
    if (rawPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr.enterPhoneFirst),
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
          context.tr.registerFarmerTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
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
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.agriculture_rounded,
                color: Color(0xFF15803D),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Header Banner ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF15803D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF15803D).withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🌱', style: TextStyle(fontSize: 12)),
                              SizedBox(width: 5),
                              Text(
                                'FARMER REGISTRATION',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => context.go(AppRoutes.roleSelection),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.tr.changeRole,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.swap_horiz_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      context.tr.registerFarmerTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr.farmerRegisterSub,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Fast 1-Click Social Sign-Up Card ────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: Color(0xFF2563EB),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'FAST 1-CLICK REGISTRATION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'RECOMMENDED',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GoogleBrandButton(
                      onPressed: _isLoading ? null : _signUpWithGoogle,
                      label: 'Sign up with Google',
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Instant verification • No password needed',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Elegant Divider ──────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Color(0xFFCBD5E1)],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'OR COMPLETE FARM DETAILS',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFCBD5E1), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ── Section 1: Producer Details ────────────────────────────────
              _buildSectionCard(
                title: context.tr.producerDetails,
                icon: Icons.badge_outlined,
                children: [
                  _buildFieldLabel(context.tr.fullNameFarmLead),
                  _buildTextInput(
                    controller: _nameCtrl,
                    hintText: 'e.g., K. M. Bandara',
                    icon: Icons.person_outline_rounded,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                  ),

                  const SizedBox(height: 16),

                  _buildFieldLabel(context.tr.nicLabel),
                  _buildTextInput(
                    controller: _nicCtrl,
                    hintText: 'e.g., 198214502341 or 821452341V',
                    icon: Icons.credit_card_outlined,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFieldLabel(context.tr.mobileNumber),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _otpVerified
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _otpVerified
                              ? context.tr.smsOtpVerified
                              : context.tr.smsOtpVerification,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: _otpVerified
                                ? const Color(0xFF15803D)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🇱🇰', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Text(
                                '+94',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            enabled: !_otpVerified,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: const InputDecoration(
                              hintText: '77 234 5678',
                              hintStyle: TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF94A3B8),
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
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFF15803D),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
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

                  const SizedBox(height: 16),

                  _buildFieldLabel(context.tr.farmNameLabel),
                  _buildTextInput(
                    controller: _farmNameCtrl,
                    hintText: 'e.g., Hakgala Mountain Organic Gardens',
                    icon: Icons.local_florist_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Section 2: Location & Hub ──────────────────────────────────
              _buildSectionCard(
                title: context.tr.locationLogisticsHub,
                icon: Icons.location_on_outlined,
                children: [
                  _buildFieldLabel(context.tr.farmingRegionDistrict),
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDistrict,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
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

                  const SizedBox(height: 16),

                  _buildFieldLabel(context.tr.nearestAgrarianCenter),
                  _buildTextInput(
                    controller: _agrarianCenterCtrl,
                    hintText: 'e.g., Hakgala Agrarian Center #04',
                    icon: Icons.storefront_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Section 3: Crops & Scale ───────────────────────────────────
              _buildSectionCard(
                title: context.tr.cropsAndScale,
                icon: Icons.grass_rounded,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFieldLabel(context.tr.primaryCropsHarvestTypes),
                      Text(
                        context.tr.selectMultiple,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF64748B),
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
                        backgroundColor: const Color(0xFFF8FAFC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSel
                                ? const Color(0xFF15803D)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        labelStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isSel ? Colors.white : const Color(0xFF334155),
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
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFDCFCE7) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
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
                                    : const Color(0xFF94A3B8),
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
                                        : const Color(0xFF334155),
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
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFFDCFCE7) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
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
                                      : const Color(0xFF94A3B8),
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
                                          : const Color(0xFF334155),
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
                ],
              ),

              const SizedBox(height: 16),

              // ── Section 4: Bank Payouts & Docs ─────────────────────────────
              _buildSectionCard(
                title: context.tr.directBankPayouts,
                icon: Icons.account_balance_outlined,
                children: [
                  Text(
                    context.tr.zeroCommissionBankSettlement,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
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

                  const SizedBox(height: 16),

                  _buildFieldLabel(context.tr.accountNumberLabel),
                  _buildTextInput(
                    controller: _accountNumberCtrl,
                    hintText: 'e.g., 008432198001',
                    icon: Icons.numbers_rounded,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  // Documents attach button
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
                            : const Color(0xFFF8FAFC),
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
                ],
              ),

              const SizedBox(height: 22),

              // ── Primary Submit CTA Button ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: const Color(0xFF15803D).withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
                                fontSize: 15.5,
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
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    Text(
                      context.tr.alreadyRegisteredFarmer,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.phoneAuth),
                      child: Text(
                        context.tr.login,
                        style: const TextStyle(
                          fontSize: 13,
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF15803D), size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF334155),
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 13.5,
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.6),
        ),
      ),
    );
  }
}

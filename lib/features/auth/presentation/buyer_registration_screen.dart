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
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/notify_sms_service.dart';
import '../../../widgets/premium/google_brand_button.dart';
import '../../buyer/services/buyer_profile_manager.dart';
import 'otp_verification_dialog.dart';

/// Buyer Registration Screen — matching Farm2Home design.
class BuyerRegistrationScreen extends StatefulWidget {
  const BuyerRegistrationScreen({super.key});

  @override
  State<BuyerRegistrationScreen> createState() =>
      _BuyerRegistrationScreenState();
}

class _BuyerRegistrationScreenState extends State<BuyerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = const AuthService();

  // Form Controllers
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // State
  String _buyerType = 'Family'; // Family, Restaurant, Bulk Co-op
  String? _selectedHub = 'Colombo Regional Hub (Western Province)';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = true;
  bool _isLoading = false;
  bool _otpVerified = false;
  bool _otpSending = false;

  final Set<String> _producePreferences = {
    '100% Organic',
    'Low-Country Fruits',
  };

  final List<String> _hubList = [
    'Colombo Regional Hub (Western Province)',
    'Kandy Central Hub (Central Province)',
    'Galle Hub (Southern Province)',
    'Nuwara Eliya Hub (Upcountry)',
    'Kurunegala Hub (North Western)',
    'Gampaha Delivery Hub',
  ];

  final List<String> _prefChips = [
    '100% Organic',
    'Pesticide-Free',
    'Highland Veggies',
    'Low-Country Fruits',
    'Heirloom Rice',
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
          await context.read<AppSettings>().setRole(UserRole.buyer);
          final effectiveName = (metadata['full_name'] as String?) ??
              sbUser.email?.split('@').first ??
              'Buyer';
          await BuyerProfileManager.instance.updateProfile(
            name: effectiveName,
            email: sbUser.email,
          );
          if (mounted) {
            context.go(AppRoutes.dashboard);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    try {
      await _authService.signInWithGoogle();
    } on AuthException catch (e) {
      if (mounted) _showSnackBar(e.message);
    } catch (e) {
      if (mounted) _showSnackBar('Google Sign-In: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtp() async {
    final rawPhone = _phoneCtrl.text.trim();
    if (rawPhone.isEmpty) {
      _showSnackBar('Please enter your mobile phone number first.');
      return;
    }

    if (!NotifySmsService.isValidSriLankanMobile(rawPhone)) {
      _showSnackBar('Please enter a valid Sri Lankan mobile number (e.g., 77 123 4567).');
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
      _showSnackBar(res.error ?? 'Could not send SMS.');
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
      _showSnackBar('Please verify your mobile number with the SMS OTP code first.');
      _sendOtp();
      return;
    }

    if (!_agreeTerms) {
      _showSnackBar('Please agree to the Terms of Service & Privacy Policy.');
      return;
    }

    if (_passwordCtrl.text.isNotEmpty &&
        _passwordCtrl.text != _confirmCtrl.text) {
      _showSnackBar('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final password = _passwordCtrl.text;
      final phone = _phoneCtrl.text.trim();
      final address = _addressCtrl.text.trim();
      final buyerType = _buyerType;
      final hub = _selectedHub ?? 'Colombo Regional Hub (Western Province)';
      final prefs = _producePreferences.toList();

      UserModel? user;
      if (email.isNotEmpty && password.isNotEmpty) {
        user = await _authService.signUp(
          email: email,
          password: password,
          fullName: name.isNotEmpty ? name : 'Chaminda Perera',
          isFarmer: false,
          extraData: {
            'phone': phone,
            'address': address,
            'hub': hub,
            'buyer_type': buyerType,
            'preferences': prefs,
            'role': 'buyer',
          },
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
      }

      // Persist real registration data into profile manager & DB
      await BuyerProfileManager.instance.saveRegistrationData(
        name: name,
        email: email,
        phone: phone,
        address: address,
        buyerType: buyerType,
        hub: hub,
        preferences: prefs,
        userId: user?.id,
      );

      if (!mounted) return;
      await context.read<AppSettings>().setRole(UserRole.buyer);

      if (mounted) {
        _showSuccessDialog();
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message);
    } catch (e) {
      _showSnackBar('Registration error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              context.tr.buyerAccountCreated,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr.buyerWelcomeMsg,
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
                  context.go(AppRoutes.dashboard);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E8342),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  context.tr.exploreFreshProduce,
                  style: TextStyle(
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
          context.tr.registerAsBuyerTitle,
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
              // ── Role Profile Pill ──────────────────────────────────────────
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
                        Icons.shopping_basket_rounded,
                        color: Color(0xFF1E8342),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr.roleProfile,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          context.tr.roleProfileBuyer,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.roleSelection),
                      child: Row(
                        children: [
                          Text(
                            context.tr.changeRole,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E8342),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Pure Field Origin Badge ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF1E8342).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '🌱 Pure Field Origin',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Title & Subtitle ───────────────────────────────────────────
              Text(
                context.tr.registerAsBuyerTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Direct farm-fresh harvest delivered straight from rural fields to your doorstep.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 14),

              // ── Produce Hero Banner Image ──────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800&auto=format&fit=crop&q=80',
                      height: 135,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 135,
                        color: const Color(0xFF0F3E26),
                        child: const Center(
                          child: Icon(
                            Icons.eco_rounded,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🌿', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 5),
                            Text(
                              'Harvested at dawn, delivered by evening',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Fast Google Sign Up Button ─────────────────────────────────
              const SizedBox(height: 18),
              GoogleBrandButton(
                onPressed: _isLoading ? null : _signUpWithGoogle,
                label: 'Fast Sign up with Google',
                isLoading: _isLoading,
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
                          colors: [Colors.transparent, Color(0xFFE2E8F0)],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'OR COMPLETE FORM BELOW',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFE2E8F0), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Select Buyer Type ──────────────────────────────────────────
              Text(
                context.tr.buyerTypeLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Family', 'Restaurant', 'Bulk Co-op'].map((type) {
                  final isSel = _buyerType == type;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _buyerType = type);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xFF15803D)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              color: isSel ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // ── Full Name ──────────────────────────────────────────────────
              _buildFieldLabel(context.tr.fullNameLabel),
              _buildTextInput(
                controller: _nameCtrl,
                hintText: 'e.g., Chaminda Perera',
                icon: Icons.person_outline_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
              ),

              const SizedBox(height: 14),

              // ── Mobile Number ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFieldLabel(context.tr.mobileNumberLabel),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇱🇰', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            '+94',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
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
                          hintText: '77 123 4567',
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
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.check_box_outlined,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'We will send a 6-digit OTP code to verify your mobile number',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Email Address ──────────────────────────────────────────────
              _buildFieldLabel(context.tr.emailLabel),
              _buildTextInput(
                controller: _emailCtrl,
                hintText: 'name@example.com',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 14),

              // ── Delivery City / Hub Area Dropdown ───────────────────────────
              _buildFieldLabel(context.tr.regionalHubLabel),
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
                      Icons.location_on_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedHub,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                          onChanged: (val) => setState(() => _selectedHub = val),
                          items: _hubList.map((hub) {
                            return DropdownMenuItem(
                              value: hub,
                              child: Text(
                                hub,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Default Street Address ─────────────────────────────────────
              _buildFieldLabel(context.tr.deliveryAddressLabel),
              _buildTextInput(
                controller: _addressCtrl,
                hintText: 'House / Apartment number, Road name, Landmark',
                icon: Icons.home_outlined,
              ),

              const SizedBox(height: 14),

              // ── Password ───────────────────────────────────────────────────
              _buildFieldLabel(context.tr.passwordLabel),
              _buildTextInput(
                controller: _passwordCtrl,
                hintText: 'At least 8 characters',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 14),

              // ── Confirm Password ───────────────────────────────────────────
              _buildFieldLabel(context.tr.confirmPasswordLabel),
              _buildTextInput(
                controller: _confirmCtrl,
                hintText: 'Repeat your password',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscureConfirm,
                suffix: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),

              const SizedBox(height: 20),

              // ── Produce & Harvest Preferences ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr.producePreferencesLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Customized box recommendations',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _prefChips.map((chip) {
                  final isSel = _producePreferences.contains(chip);
                  return FilterChip(
                    label: Text(chip),
                    selected: isSel,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _producePreferences.add(chip);
                        } else {
                          _producePreferences.remove(chip);
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

              const SizedBox(height: 20),

              // ── Buyer Freshness Promise Card ───────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF1E8342).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFF1E8342),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr.buyerFreshnessPromise,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F3E26),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            context.tr.freshnessPromiseBody,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: const Color(0xFF2D5A40),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Terms & Conditions Checkbox ────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeTerms,
                      activeColor: const Color(0xFF1E8342),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr.agreeTermsBuyer,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

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
                              context.tr.createBuyerAccountBtn,
                              style: TextStyle(
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

              // ── Already have account? Log In ──────────────────────────────
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.phoneAuth),
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF15803D),
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
    bool obscureText = false,
    Widget? suffix,
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
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          suffixIcon: suffix,
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

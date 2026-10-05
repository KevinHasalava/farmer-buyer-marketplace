import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/premium/premium_widgets.dart';
import 'role_meta.dart';

enum _AuthStep { phone, otp, name }

/// Step 5: Phone OTP Authentication Screen — matching original Login Screen style.
class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  static const _demoCode = '123456';
  static const _resendSeconds = 30;

  final _authService = const AuthService();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _otpFocus = FocusNode();

  _AuthStep _step = _AuthStep.phone;
  bool _loading = false;
  bool _demoMode = false;
  String? _error;
  int _secondsLeft = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _nameCtrl.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  String? get _e164 {
    var digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('94')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (digits.length != 9 || !digits.startsWith('7')) return null;
    return '+94$digits';
  }

  String get _prettyPhone {
    final p = _e164 ?? '';
    if (p.length != 12) return p;
    return '+94 ${p.substring(3, 5)} ${p.substring(5, 8)} ${p.substring(8)}';
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) t.cancel();
    });
  }

  void _goStep(_AuthStep s) {
    setState(() {
      _step = s;
      _error = null;
    });
    if (s == _AuthStep.otp) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _otpFocus.requestFocus();
      });
    }
  }

  void _goHome() {
    final role = context.settings.role ?? UserRole.buyer;
    context.go(AppRoutes.homeFor(role));
  }

  Future<void> _sendOtp() async {
    final tr = context.settings.strings;
    final phone = _e164;
    if (phone == null) {
      setState(() => _error = tr.invalidPhone);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authService.sendPhoneOtp(phone);
      _demoMode = false;
    } catch (_) {
      _demoMode = true;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (!mounted) return;
    _otpCtrl.clear();
    _startTimer();
    _goStep(_AuthStep.otp);
  }

  Future<void> _verify() async {
    final tr = context.settings.strings;
    final code = _otpCtrl.text;
    if (code.length != 6) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_demoMode) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (code != _demoCode) throw Exception('bad code');
        if (mounted) _goStep(_AuthStep.name);
        return;
      }

      final user =
          await _authService.verifyPhoneOtp(phone: _e164!, token: code);
      final existingName = user?.userMetadata?['full_name'] as String?;
      if (!mounted) return;
      if (existingName != null && existingName.trim().isNotEmpty) {
        await _authService.updateProfile(
          fullName: existingName,
          role: context.settings.role?.name ?? 'buyer',
        );
        if (mounted) _goHome();
      } else {
        _goStep(_AuthStep.name);
      }
    } catch (_) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        setState(() => _error = tr.invalidOtp);
        _otpCtrl.clear();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _finish() async {
    final tr = context.settings.strings;
    final name = _nameCtrl.text.trim();
    if (name.length < 2) {
      setState(() => _error = tr.nameRequired);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (!_demoMode) {
        await _authService.updateProfile(
          fullName: name,
          role: context.settings.role?.name ?? 'buyer',
        );
      }
      if (mounted) _goHome();
    } catch (_) {
      if (mounted) setState(() => _error = tr.somethingWrong);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _back() {
    switch (_step) {
      case _AuthStep.phone:
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.roleSelection);
        }
      case _AuthStep.otp:
        _goStep(_AuthStep.phone);
      case _AuthStep.name:
        _goStep(_AuthStep.otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final role = context.watch<AppSettings>().role ?? UserRole.buyer;

    final (String title, String sub) = switch (_step) {
      _AuthStep.phone => (
          tr.enterPhone.replaceAll('\n', ' '),
          tr.enterPhoneSub,
        ),
      _AuthStep.otp => (
          tr.enterOtp.replaceAll('\n', ' '),
          '${tr.otpSentTo} $_prettyPhone',
        ),
      _AuthStep.name => (
          tr.yourName.replaceAll('\n', ' '),
          tr.yourNameSub,
        ),
    };

    final (String cta, VoidCallback? onCta) = switch (_step) {
      _AuthStep.phone => (tr.sendOtp, _sendOtp),
      _AuthStep.otp => (tr.verify, _otpCtrl.text.length == 6 ? _verify : null),
      _AuthStep.name => (tr.finish, _finish),
    };

    return PopScope(
      canPop: _step == _AuthStep.phone,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Column(
          children: [
            // ── Signature Curved Header matching login_screen.dart ──────────
            AppHeaderBanner(
              title: title,
              subtitle: sub,
              badgeText: role.label(tr).toUpperCase(),
              showBack: true,
              onBack: _back,
              trailing: const AppLanguagePill(isDarkHeader: true),
              heightFactor: 0.27,
            ),

            // ── Step Form ───────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spaceLG,
                  AppDimensions.spaceMD,
                  AppDimensions.spaceLG,
                  AppDimensions.spaceLG,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_step == _AuthStep.phone) _buildPhoneSection(tr),
                    if (_step == _AuthStep.otp) _buildOtpSection(tr),
                    if (_step == _AuthStep.name) _buildNameSection(tr),

                    // Error Message
                    if (_error != null) ...[
                      const SizedBox(height: AppDimensions.spaceMD),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSM),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: GoogleFonts.poppins(
                                  color: AppColors.error,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppDimensions.spaceLG),

                    // Legacy Email Sign In Link & Sign Up Navigation
                    if (_step == _AuthStep.phone) ...[
                      Center(
                        child: TextButton.icon(
                          onPressed: () => context.go(AppRoutes.login),
                          icon: const Icon(Icons.mail_outline_rounded, size: 16),
                          label: Text(
                            'Or sign in with email & password',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                final currentRole =
                                    context.read<AppSettings>().role ??
                                        UserRole.buyer;
                                context.push(AppRoutes.registerFor(currentRole));
                              },
                              child: Text(
                                'Sign Up',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryGreen,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: InkWell(
                          onTap: () {
                            final currentRole =
                                context.read<AppSettings>().role ??
                                    UserRole.buyer;
                            context.push(AppRoutes.registerFor(currentRole));
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryGreen.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  role.icon,
                                  size: 16,
                                  color: AppColors.primaryGreen,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  switch (role) {
                                    UserRole.buyer => 'Register as a Buyer',
                                    UserRole.farmer => 'Register as a Farm Producer',
                                    UserRole.driver => 'Register as a Transit Driver',
                                  },
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: AppColors.primaryGreen,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Bottom Continue CTA ──────────────────────────────────────────
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spaceLG,
                  0,
                  AppDimensions.spaceLG,
                  AppDimensions.spaceLG,
                ),
                child: AppPrimaryButton(
                  label: cta,
                  isLoading: _loading,
                  onPressed: onCta,
                  icon: _step == _AuthStep.name
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Phone Input (matching _PremiumPhoneField in login_screen.dart) ─────────
  Widget _buildPhoneSection(AppStrings tr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ENTER YOUR MOBILE NUMBER',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: AppColors.divider),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇱🇰', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      '+94',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (_) => _sendOtp(),
                  decoration: InputDecoration(
                    hintText: '77 123 4567',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        Row(
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              tr.secureNote,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── OTP Boxes (clean light theme) ─────────────────────────────────────────
  Widget _buildOtpSection(AppStrings tr) {
    final code = _otpCtrl.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_demoMode) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFE65100),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tr.demoNotice,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF795548),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMD),
        ],

        Text(
          'ENTER 6-DIGIT VERIFICATION CODE',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMD),

        Stack(
          children: [
            Opacity(
              opacity: 0,
              child: SizedBox(
                height: 56,
                child: TextField(
                  controller: _otpCtrl,
                  focusNode: _otpFocus,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onChanged: (v) {
                    setState(() => _error = null);
                    if (v.length == 6) _verify();
                  },
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _otpFocus.requestFocus(),
              child: Row(
                children: List.generate(6, (i) {
                  final filled = i < code.length;
                  final active = i == code.length && _otpFocus.hasFocus;
                  return Expanded(
                    child: Container(
                      height: 56,
                      margin: EdgeInsets.only(right: i == 5 ? 0 : 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: filled
                            ? const Color(0xFFE8F8EF)
                            : AppColors.surfaceWhite,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD),
                        border: Border.all(
                          color: _error != null
                              ? AppColors.error
                              : (active || filled)
                                  ? AppColors.primaryGreen
                                  : AppColors.border,
                          width: (active || filled) ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        filled ? code[i] : '',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.spaceMD),

        Row(
          children: [
            if (_secondsLeft > 0)
              Text(
                '${tr.resendIn} 00:${_secondsLeft.toString().padLeft(2, '0')}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              )
            else
              GestureDetector(
                onTap: _loading ? null : _sendOtp,
                child: Text(
                  tr.resend,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            const Spacer(),
            GestureDetector(
              onTap: () => _goStep(_AuthStep.phone),
              child: Text(
                tr.changeNumber,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Name Field (matching _PremiumField in login_screen.dart) ───────────────
  Widget _buildNameSection(AppStrings tr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR FULL NAME',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  onSubmitted: (_) => _finish(),
                  decoration: InputDecoration(
                    hintText: tr.fullName,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

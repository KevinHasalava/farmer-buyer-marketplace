import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/premium/premium_widgets.dart';
import 'role_meta.dart';

enum _AuthStep { phone, otp, name }

/// Step 4 — password-less registration / login with mobile number + OTP.
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

  // ── Helpers ─────────────────────────────────────────────────────────────
  /// Normalises `0771234567` / `771234567` → `+94771234567`.
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
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) _otpFocus.requestFocus();
      });
    }
  }

  void _goHome() {
    final role = context.settings.role ?? UserRole.buyer;
    context.go(AppRoutes.homeFor(role));
  }

  // ── Actions ─────────────────────────────────────────────────────────────
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
      // SMS provider not configured → allow testing the flow in demo mode.
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
        await Future.delayed(const Duration(milliseconds: 600));
        if (code != _demoCode) throw Exception('bad code');
        if (mounted) _goStep(_AuthStep.name);
        return;
      }

      final user =
          await _authService.verifyPhoneOtp(phone: _e164!, token: code);
      final existingName = user?.userMetadata?['full_name'] as String?;
      if (!mounted) return;
      if (existingName != null && existingName.trim().isNotEmpty) {
        // Returning user — keep their role in sync and go home.
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

  // ── UI ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final role = context.watch<AppSettings>().role ?? UserRole.buyer;
    final g = role.gradient;
    final fg = role == UserRole.buyer ? AppColors.forestDeep : Colors.white;

    final (String cta, VoidCallback? onCta) = switch (_step) {
      _AuthStep.phone => (tr.sendOtp, _sendOtp),
      _AuthStep.otp =>
        (tr.verify, _otpCtrl.text.length == 6 ? _verify : null),
      _AuthStep.name => (tr.finish, _finish),
    };

    return PopScope(
      canPop: _step == _AuthStep.phone,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AuroraBackground(
          accent: g.first,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top bar ───────────────────────────────────────────────
                  Row(
                    children: [
                      GlassIconButton(
                          icon: Icons.arrow_back_rounded, onTap: _back),
                      const SizedBox(width: 12),
                      _RoleBadge(
                          label: role.label(tr), icon: role.icon, colors: g),
                      const Spacer(),
                      const LanguagePill(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  StepIndicator(total: 4, current: 3, activeColors: g),
                  const SizedBox(height: 28),

                  // ── Step body ─────────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 380),
                        switchInCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0.08, 0),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(_step),
                          child: switch (_step) {
                            _AuthStep.phone => _buildPhone(tr, g),
                            _AuthStep.otp => _buildOtp(tr, g),
                            _AuthStep.name => _buildName(tr, g),
                          },
                        ),
                      ),
                    ),
                  ),

                  // ── Error ─────────────────────────────────────────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _error == null
                        ? const SizedBox(width: double.infinity)
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: Color(0xFFFF8A80), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Color(0xFFFF8A80),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  GradientButton(
                    label: cta,
                    colors: g,
                    foreground: fg,
                    isLoading: _loading,
                    onPressed: onCta,
                    icon: _step == _AuthStep.name
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heading(String title, String sub) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            sub,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14.5,
              height: 1.5,
            ),
          ),
        ],
      );

  // Step A — phone number
  Widget _buildPhone(AppStrings tr, List<Color> g) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(tr.enterPhone, tr.enterPhoneSub),
        const SizedBox(height: 32),
        Text(
          tr.phoneLabel.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11.5,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          radius: 20,
          borderColor: g.first.withValues(alpha: 0.5),
          borderWidth: 1.4,
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                child: const Row(
                  children: [
                    Text('🇱🇰', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text(
                      '+94',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneCtrl,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  cursorColor: g.first,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (_) => _sendOtp(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: '77 123 4567',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Icon(Icons.lock_rounded,
                size: 16, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tr.secureNote,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Step B — OTP boxes
  Widget _buildOtp(AppStrings tr, List<Color> g) {
    final code = _otpCtrl.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(tr.enterOtp, '${tr.otpSentTo}  $_prettyPhone'),
        if (_demoMode) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.gold.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.science_rounded,
                    color: AppColors.gold, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tr.demoNotice,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),

        // Hidden field drives the visual boxes
        Stack(
          children: [
            Opacity(
              opacity: 0,
              child: SizedBox(
                height: 64,
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 64,
                      margin: EdgeInsets.only(right: i == 5 ? 0 : 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: filled
                            ? g.first.withValues(alpha: 0.14)
                            : Colors.white.withValues(alpha: 0.06),
                        border: Border.all(
                          color: _error != null
                              ? const Color(0xFFFF8A80)
                              : (active || filled)
                                  ? g.first
                                  : Colors.white.withValues(alpha: 0.12),
                          width: active ? 2 : 1.3,
                        ),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: g.first.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                ),
                              ]
                            : null,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder: (c, a) =>
                            ScaleTransition(scale: a, child: c),
                        child: Text(
                          filled ? code[i] : '',
                          key: ValueKey('$i${filled ? code[i] : ''}'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            if (_secondsLeft > 0)
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(text: '${tr.resendIn} '),
                    TextSpan(
                      text: '00:${_secondsLeft.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: g.first,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: _loading ? null : _sendOtp,
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, color: g.first, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      tr.resend,
                      style: TextStyle(
                        color: g.first,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            GestureDetector(
              onTap: () => _goStep(_AuthStep.phone),
              child: Text(
                tr.changeNumber,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Step C — name (new users only)
  Widget _buildName(AppStrings tr, List<Color> g) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: g),
            boxShadow: [
              BoxShadow(color: g.last.withValues(alpha: 0.5), blurRadius: 24),
            ],
          ),
          child: const Icon(Icons.verified_user_rounded,
              color: Colors.white, size: 30),
        ),
        const SizedBox(height: 22),
        _heading(tr.yourName, tr.yourNameSub),
        const SizedBox(height: 28),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          radius: 20,
          borderColor: g.first.withValues(alpha: 0.5),
          borderWidth: 1.4,
          child: TextField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            cursorColor: g.first,
            onSubmitted: (_) => _finish(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              icon: Icon(Icons.person_rounded, color: g.first),
              hintText: tr.fullName,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({
    required this.label,
    required this.icon,
    required this.colors,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: colors.first.withValues(alpha: 0.15),
          border: Border.all(color: colors.first.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.first, size: 15),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.first,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

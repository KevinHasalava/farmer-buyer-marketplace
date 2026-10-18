import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../../../widgets/premium/google_brand_button.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../services/auth_service.dart';
import '../../../services/notify_sms_service.dart';
import '../../farmer/services/farmer_profile_manager.dart';
import '../../buyer/services/buyer_profile_manager.dart';
import '../../driver/services/driver_profile_manager.dart';
import '../../admin/services/admin_auth_service.dart';
import 'otp_verification_dialog.dart';

/// Premium Login / Create Account screen — Farm2Home
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.buyer;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Language & Smart detection helpers
  bool get _isSinhala => context.currentLanguage == AppLanguage.sinhala;
  bool get _isTamil => context.currentLanguage == AppLanguage.tamil;

  bool get _isPhone => _isPhoneInput(_identifierCtrl.text.trim());

  static bool _isPhoneInput(String input) {
    final clean = input.replaceAll(RegExp(r'[\s\-]'), '');
    if (clean.isEmpty) return false;
    if (clean.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(clean)) {
      return false;
    }
    return RegExp(r'^\+?[0-9]{3,}$').hasMatch(clean);
  }

  // Form controllers
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl   = TextEditingController();

  final _authService  = const AuthService();
  StreamSubscription<AuthState>? _authSubscription;

  late final AnimationController _headerController;
  late final AnimationController _formController;
  late final Animation<double> _leafFade;
  late final Animation<Offset> _formSlide;
  late final Animation<double> _formFade;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _leafFade = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );

    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic),
    );

    _formFade = CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOut,
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _formController.forward();
    });

    if (SupabaseConfig.isInitialized) {
      // Email/password sign-in is handled by _submit(); this only covers the
      // return from an OAuth (Google) redirect.
      _authSubscription =
          SupabaseConfig.auth.onAuthStateChange.listen((data) async {
        if (data.event == AuthChangeEvent.signedIn &&
            data.session != null &&
            mounted &&
            !_isLoading) {
          try {
            await _enterApp();
          } on AuthException catch (e) {
            _showError(e.message);
          }
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final role = context.read<AppSettings>().role;
    if (role != null) {
      _selectedRole = role;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _headerController.dispose();
    _formController.dispose();
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Supabase sign-in ─────────────────────────────────────────────────
  bool _entering = false;

  /// Reads the role from the database and opens the matching home screen.
  /// If the user has no profile yet (new Google sign-in), redirects to the
  /// role-selection / registration flow instead of showing an error.
  Future<void> _enterApp() async {
    if (_entering) return;
    _entering = true;
    try {
      String? roleStr;
      try {
        roleStr = await _authService.fetchRole();
      } on AuthException catch (e) {
        // Profile row not found = brand-new Google/OAuth user who hasn't registered yet.
        if (e.message == 'profile_not_found' ||
            e.message.toLowerCase().contains('not found') ||
            e.message.toLowerCase().contains('no rows')) {
          if (mounted) {
            final chosen = context.read<AppSettings>().role;
            context.go(chosen != null
                ? AppRoutes.registerFor(chosen)
                : AppRoutes.roleSelection);
          }
          return;
        }
        rethrow;
      }

      if (!mounted) return;

      if (roleStr == 'admin') {
        final ok = await AdminAuthService.instance.adoptCurrentSession();
        if (ok && mounted) context.go(AppRoutes.adminPanel);
        return;
      }

      final targetRole = UserRole.fromName(roleStr) ?? UserRole.buyer;
      await context.read<AppSettings>().setRole(targetRole);

      final user = _authService.currentUser;
      final effectiveName = (user?.name.isNotEmpty ?? false)
          ? user!.name
          : (user?.email.split('@').first ?? '');
      final email = user?.email;
      final phone = user?.phone ?? '';

      if (targetRole == UserRole.farmer) {
        await FarmerProfileManager.instance.updateProfile(
          name: effectiveName,
          email: email,
          phone: phone.isNotEmpty ? phone : null,
        );
      } else if (targetRole == UserRole.buyer) {
        await BuyerProfileManager.instance.updateProfile(
          name: effectiveName,
          email: email,
          phone: phone.isNotEmpty ? phone : null,
        );
      } else if (targetRole == UserRole.driver) {
        await DriverProfileManager.instance.updateProfile(
          fullName: effectiveName,
          mobileNumber: phone.isNotEmpty ? phone : null,
        );
      }

      if (mounted) {
        context.go(AppRoutes.entering, extra: {
          'role': targetRole.name,
          'name': effectiveName,
        });
      }
    } finally {
      _entering = false;
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final input = _identifierCtrl.text.trim();
    if (_isPhoneInput(input)) {
      await _loginWithPhoneOtp(input);
    } else {
      await _submitEmailPassword(input, _passwordCtrl.text);
    }
  }

  Future<void> _submitEmailPassword(String email, String password) async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    // ── Dedicated Master Admin Access ─────────────────────────────────
    if (email.toLowerCase() == AdminAuthService.masterAdminEmail.toLowerCase() &&
        password == AdminAuthService.masterAdminPassword) {
      try {
        await AdminAuthService.instance.authenticateMasterAdmin(
          email,
          'Master Administrator',
        );

        try {
          if (SupabaseConfig.isInitialized) {
            await SupabaseConfig.auth.signInWithPassword(
              email: email,
              password: password,
            );
          }
        } catch (_) {}

        if (!mounted) return;
        context.go(AppRoutes.adminPanel);
        return;
      } catch (e) {
        _showError('Admin login failed: $e');
        return;
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }

    try {
      await _authService.signIn(
        email: email,
        password: password,
      );
      if (!mounted) return;
      await _enterApp();
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Sign in failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    try {
      await _authService.signInWithGoogle();
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } catch (e) {
      if (mounted) _showError('Google Sign-In: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Sends an OTP to the phone and shows the verification sheet.
  /// On success, looks up the profile by phone and enters the app.
  Future<void> _loginWithPhoneOtp(String phone) async {
    if (!NotifySmsService.isValidSriLankanMobile(phone)) {
      _showError(_isSinhala
          ? 'වලංගු ශ්‍රී ලාංකික ජංගම දුරකථන අංකයක් ඇතුළත් කරන්න (උදා: 077 123 4567)'
          : 'Please enter a valid Sri Lankan mobile number (e.g. 077 123 4567)');
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    final result = await NotifySmsService.instance.sendOtp(phone);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!result.success && result.otpCode == null) {
      _showError(result.error ?? 'Could not send OTP. Please try again.');
      return;
    }

    if (!mounted) return;
    final verified = await OtpVerificationSheet.show(
      context,
      rawPhone: phone,
      onVerified: () {},
    );

    if (!mounted) return;
    if (verified != true) return;

    // OTP verified – find the account by phone number and sign in
    setState(() => _isLoading = true);
    try {
      final normalized = NotifySmsService.formatPhone(phone);
      // Look up profile by phone (try both formats: +94... and 94...)
      final rows = await SupabaseConfig.client
          .from('profiles')
          .select('id, role')
          .or('phone.eq.+$normalized,phone.eq.0${normalized.substring(2)},'
              'phone.eq.+94${normalized.substring(2)},')
          .limit(1);

      if (rows.isEmpty) {
        _showError(_isSinhala
            ? 'මෙම අංකයට ගිණුමක් හමු නොවීය. කරුණාකර පළමුව ලියාපදිංචි වන්න.'
            : 'No account found for this number. Please register first.');
        return;
      }

      final roleStr = (rows.first['role'] as String).toLowerCase();

      // Attempt Supabase phone OTP if configured
      try {
        await SupabaseConfig.auth.signInWithOtp(
          phone: '+$normalized',
          shouldCreateUser: false,
        );
      } catch (_) {
        // Supabase phone provider not configured – that's fine, we already
        // verified the phone ourselves via Notify.lk. Continue.
      }

      if (!mounted) return;
      // Enter the app using the profile we found
      await context.read<AppSettings>().setRole(UserRole.fromName(roleStr) ?? UserRole.buyer);
      if (!mounted) return;
      context.go(AppRoutes.entering, extra: {
        'role': roleStr,
        'name': '',
      });
    } catch (e) {
      _showError('Sign in failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  // ── Registration & Guest Navigation with pre-selected role ─────────
  void _onRegisterTap(BuildContext ctx) {
    HapticFeedback.lightImpact();
    final role = ctx.read<AppSettings>().role ?? _selectedRole;
    ctx.push(AppRoutes.registerFor(role));
  }


  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentRole = context.watch<AppSettings>().role ?? _selectedRole;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // ── Premium Curved Header ──────────────────────────────────────
          _PremiumHeader(
            leafFade: _leafFade,
            screenHeight: size.height,
            currentRole: currentRole,
            onBack: () => context.go(AppRoutes.roleSelection),
          ),

          // ── Scrollable Form ───────────────────────────────────────────
          Expanded(
            child: SlideTransition(
              position: _formSlide,
              child: FadeTransition(
                opacity: _formFade,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.spaceLG,
                    AppDimensions.spaceSM,
                    AppDimensions.spaceLG,
                    AppDimensions.spaceXXL,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Title
                        Text(
                          context.tr.signInToYourAccount,
                          style: AppTheme.fontStyle(
                            context.currentLanguage,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isPhone
                              ? (_isSinhala
                                  ? 'ඉදිරියට යාමට ඔබගේ දුරකථන අංකය ඇතුළත් කරන්න'
                                  : (_isTamil
                                      ? 'தொடர உங்கள் மொபைல் எண்ணை உள்ளிடவும்'
                                      : 'Enter your mobile number to receive an SMS OTP'))
                              : (_isSinhala
                                  ? 'ඉදිරියට යාමට ඔබගේ විද්‍යුත් තැපෑල හෝ දුරකථන අංකය ඇතුළත් කරන්න'
                                  : (_isTamil
                                      ? 'தொடர உங்கள் மின்னஞ்சல் அல்லது மொபைல் எண்ணை உள்ளிடவும்'
                                      : 'Enter your email or mobile number to continue')),
                          style: AppTheme.fontStyle(
                            context.currentLanguage,
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceMD),

                        // ── Unified Email or Mobile Number Input ──────────
                        _PremiumField(
                          label: _isPhone
                              ? (_isSinhala
                                  ? 'ජංගම දුරකථන අංකය'
                                  : (_isTamil ? 'கைபேசி எண்' : 'Mobile number'))
                              : (_isSinhala
                                  ? 'විද්‍යුත් තැපෑල හෝ දුරකථන අංකය'
                                  : (_isTamil
                                      ? 'மின்னஞ்சல் அல்லது தொலைபேசி எண்'
                                      : 'Email or Mobile number')),
                          hint: _isPhone
                              ? '077 123 4567'
                              : 'your.email@example.com / 077 123 4567',
                          icon: _isPhone
                              ? Icons.phone_android_rounded
                              : Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          controller: _identifierCtrl,
                          onChanged: (_) => setState(() {}),
                          validator: (v) {
                            final val = (v ?? '').trim();
                            if (val.isEmpty) {
                              return _isSinhala
                                  ? 'විද්‍යුත් තැපෑල හෝ දුරකථන අංකය ඇතුළත් කරන්න'
                                  : 'Email or mobile number is required';
                            }
                            if (_isPhoneInput(val)) {
                              final raw = val.replaceAll(RegExp(r'[\s\-]'), '');
                              if (!RegExp(r'^(\+94|0)?7\d{8}$').hasMatch(raw)) {
                                return _isSinhala
                                    ? 'වලංගු දුරකථන අංකයක් ඇතුළත් කරන්න (උදා: 077 123 4567)'
                                    : 'Enter a valid Sri Lankan number (e.g. 077 123 4567)';
                              }
                            } else {
                              if (!val.contains('@') || !val.contains('.')) {
                                return context.tr.invalidEmail;
                              }
                            }
                            return null;
                          },
                        ),

                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 250),
                          crossFadeState: _isPhone
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: AppDimensions.spaceMD),

                              // Password
                              _PremiumPasswordField(
                                obscure: _obscurePassword,
                                controller: _passwordCtrl,
                                onToggle: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                validator: (v) {
                                  if (_isPhone) return null;
                                  return (v == null || v.length < 6)
                                      ? context.tr.passwordMinLength
                                      : null;
                                },
                              ),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => context.push(AppRoutes.forgotPassword),
                                  child: AutoText(
                                    'Forgot password?',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          secondChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: AppDimensions.spaceMD),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: const Color(0xFFBBF7D0)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.sms_outlined,
                                          size: 18, color: Color(0xFF15803D)),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _isSinhala
                                            ? 'මෙම අංකයට තහවුරු කිරීමේ SMS OTP කේතයක් යවනු ලැබේ'
                                            : (_isTamil
                                                ? 'இந்த எண்ணுக்கு சரிபார்ப்பு SMS OTP குறியீடு அனுப்பப்படும்'
                                                : 'An SMS verification code (OTP) will be sent to this number'),
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF166534),
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spaceSM),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceSM),

                        // CTA Button
                        _PremiumCTAButton(
                          label: _isPhone
                              ? (_isSinhala
                                  ? 'OTP ලබාගන්න'
                                  : (_isTamil ? 'OTP பெறவும்' : 'Send OTP'))
                              : context.tr.signIn,
                          icon: _isPhone
                              ? Icons.sms_rounded
                              : Icons.arrow_forward_rounded,
                          isLoading: _isLoading,
                          onPressed: _submit,
                        ),

                        const SizedBox(height: 20),

                        // ── Divider: OR CONTINUE WITH ───────────────────────
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                context.tr.orDivider.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
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

                        const SizedBox(height: 18),

                        // ── Modern Vector Google Sign-In Button ─────────────
                        GoogleBrandButton(
                          onPressed: _isLoading ? null : _loginWithGoogle,
                          label: 'Continue with Google',
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 22),

                        // ── Register / Sign Up Prompt Card ──────────────────
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Text(
                                  context.tr.dontHaveAccount,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _onRegisterTap(context),
                                  child: Text(
                                    context.tr.registerNow,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF15803D),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium curved header with animated leaf motif & dynamic role badge
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader({
    required this.leafFade,
    required this.screenHeight,
    required this.currentRole,
    this.onBack,
  });

  final Animation<double> leafFade;
  final double screenHeight;
  final UserRole currentRole;
  final VoidCallback? onBack;

  String _roleBadgeText(BuildContext context, UserRole role) {
    final tr = context.tr;
    return switch (role) {
      UserRole.farmer => tr.roleFarmerTitle,
      UserRole.buyer => tr.roleBuyerTitle,
      UserRole.driver => tr.roleDriverTitle,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          width: double.infinity,
          height: screenHeight * 0.28,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF021E12),
                Color(0xFF063924),
                Color(0xFF0D5A3A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Decorative arcs
        Positioned.fill(
          child: CustomPaint(painter: _HeaderArcPainter()),
        ),

        // Floating leaf decoration
        Positioned(
          right: -20,
          top: -10,
          child: FadeTransition(
            opacity: leafFade,
            child: Transform.rotate(
              angle: -0.3,
              child: Icon(
                Icons.eco_rounded,
                size: 120,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
        ),
        Positioned(
          left: -30,
          bottom: 20,
          child: FadeTransition(
            opacity: leafFade,
            child: Transform.rotate(
              angle: 0.4,
              child: Icon(
                Icons.local_florist_rounded,
                size: 90,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
        ),

        // Back Navigation Button
        Positioned(
          top: 12,
          left: 16,
          child: SafeArea(
            child: GestureDetector(
              onTap: onBack ??
                  () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      context.go(AppRoutes.roleSelection);
                    }
                  },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        // Content
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Unified Loading Screen Emblem & Wordmark
                const AppBrandLogo(size: 60, hasGlow: true),
                const SizedBox(height: 8),
                const AppBrandWordmark(fontSize: 26, isLight: true),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(),
                    const SizedBox(width: 6),
                    Text(
                      context.tr.freshDirectHonest,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _dot(),
                  ],
                ),
                const SizedBox(height: 8),
                // Dynamic Role Badge Chip (Tappable to Switch Role)
                GestureDetector(
                  onTap: () => context.go(AppRoutes.roleSelection),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.28),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          currentRole == UserRole.farmer
                              ? Icons.agriculture_rounded
                              : currentRole == UserRole.driver
                                  ? Icons.local_shipping_rounded
                                  : Icons.shopping_basket_rounded,
                          size: 13,
                          color: const Color(0xFFFBBF24),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _roleBadgeText(context, currentRole),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.swap_horiz_rounded,
                          size: 13,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Top-right Language Selector Pill
        const Positioned(
          top: 12,
          right: 16,
          child: SafeArea(
            child: AppLanguagePill(isDarkHeader: true),
          ),
        ),

        // Bottom wave clip
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: _BottomWaveClipper(),
            child: Container(
              height: 32,
              color: AppColors.backgroundLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dot() => Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.accentOrange,
          shape: BoxShape.circle,
        ),
      );
}

class _HeaderArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path1 = Path();
    path1.addArc(
      Rect.fromCircle(center: Offset(size.width * 0.8, 0), radius: 120),
      0,
      math.pi * 2,
    );
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.addArc(
      Rect.fromCircle(center: Offset(size.width * 0.1, size.height), radius: 80),
      0,
      math.pi * 2,
    );
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.25, 0,
      size.width * 0.5, size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.8,
      size.width, 0,
    );
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Text Field
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumField extends StatelessWidget {
  const _PremiumField({
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.validator,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.fontStyle(
            context.currentLanguage,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: const Color(0xFF15803D)),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 56, minHeight: 48),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF16A34A),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Password field
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumPasswordField extends StatelessWidget {
  const _PremiumPasswordField({
    required this.obscure,
    required this.onToggle,
    this.controller,
    this.validator,
  });

  final bool obscure;
  final VoidCallback onToggle;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr.password,
          style: AppTheme.fontStyle(
            context.currentLanguage,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: '••••••••••••',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 19,
                  color: Color(0xFF15803D),
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 56, minHeight: 48),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: const Color(0xFF64748B),
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF16A34A),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium CTA Button with gradient + shimmer feel
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumCTAButton extends StatefulWidget {
  const _PremiumCTAButton({
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.icon,
  });
  final VoidCallback onPressed;
  final String label;
  final bool isLoading;
  final IconData? icon;

  @override
  State<_PremiumCTAButton> createState() => _PremiumCTAButtonState();
}

class _PremiumCTAButtonState extends State<_PremiumCTAButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => _controller.reverse(),
      onTapUp: widget.isLoading
          ? null
          : (_) {
              _controller.forward();
              widget.onPressed();
            },
      onTapCancel: widget.isLoading ? null : () => _controller.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF16A34A), Color(0xFF15803D), Color(0xFF0F5132)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16A34A).withValues(alpha: 0.38),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      widget.icon ?? Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}


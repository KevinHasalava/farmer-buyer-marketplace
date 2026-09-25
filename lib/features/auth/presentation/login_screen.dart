import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/constants.dart';
import '../../../core/routes/app_router.dart';
import '../../../services/auth_service.dart';

/// Premium Login / Create Account screen — Farm2Home
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isBuyer = true;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  int _passwordStrength = 0;
  bool _isSignInMode = false;  // toggle between Sign Up / Sign In
  bool _isLoading = false;

  // Form controllers
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  final _authService  = const AuthService();

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
  }

  @override
  void dispose() {
    _headerController.dispose();
    _formController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── Supabase submit ──────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreedToTerms && !_isSignInMode) {
      _showError('Please accept the Terms & Privacy Policy.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isSignInMode) {
        // ── Sign In ──────────────────────────────────────────────────
        await _authService.signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      } else {
        // ── Sign Up ──────────────────────────────────────────────────
        if (_passwordCtrl.text != _confirmCtrl.text) {
          _showError('Passwords do not match.');
          return;
        }
        await _authService.signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          fullName: _nameCtrl.text.trim(),
          isFarmer: !_isBuyer,
        );
      }

      if (mounted) context.go(AppRoutes.dashboard);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('rate limit')) {
        // Attempt sign in in case user account was created in a previous attempt
        try {
          await _authService.signIn(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
          );
          if (mounted) {
            context.go(AppRoutes.dashboard);
            return;
          }
        } catch (_) {
          // If signIn fails, show the rate limit resolution dialog with bypass
          if (mounted) {
            _showRateLimitDialog();
            return;
          }
        }
      }
      _showError(e.message);
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRateLimitDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.hourglass_top_rounded, color: Color(0xFFE65100), size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Email Rate Limit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supabase free tier limits confirmation emails to 3 per hour. Since you tested multiple times, Supabase has paused sending confirmation emails temporarily.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: const Text(
                '💡 Tip: To permanently fix this in Supabase, go to Authentication > Providers > Email and turn OFF "Confirm email".',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF795548),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Would you like to enter directly into the app now?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF235D3A),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isSignInMode = true);
            },
            child: const Text(
              'Switch to Sign In',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.dashboard);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF235D3A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Continue to App'),
          ),
        ],
      ),
    );
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

  void _updatePasswordStrength(String value) {
    int strength = 0;
    if (value.length >= 8) strength++;
    if (value.contains(RegExp(r'[A-Z]'))) strength++;
    if (value.contains(RegExp(r'[0-9]'))) strength++;
    if (value.contains(RegExp(r'[!@#\$%^&*]'))) strength++;
    setState(() => _passwordStrength = strength);
  }

  Color get _strengthColor {
    if (_passwordStrength <= 1) return AppColors.error;
    if (_passwordStrength == 2) return AppColors.warning;
    if (_passwordStrength == 3) return AppColors.accentOrange;
    return AppColors.success;
  }

  String get _strengthLabel {
    if (_passwordStrength == 0) return '';
    if (_passwordStrength <= 1) return 'Weak';
    if (_passwordStrength == 2) return 'Fair';
    if (_passwordStrength == 3) return 'Good';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // ── Premium Curved Header ──────────────────────────────────────
          _PremiumHeader(
            leafFade: _leafFade,
            screenHeight: size.height,
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
                    AppDimensions.spaceMD,
                    AppDimensions.spaceLG,
                    AppDimensions.spaceXXL,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Text(
                          'Create your account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Takes less than a minute',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceLG),

                        // ── Account Type ───────────────────────────────
                        _SectionLabel('SELECT YOUR ACCOUNT TYPE'),
                        const SizedBox(height: AppDimensions.spaceXS),
                        Row(
                          children: [
                            Expanded(
                              child: _PremiumAccountCard(
                                label: "I'm Buying",
                                sublabel: 'Household & Dining',
                                icon: Icons.shopping_basket_rounded,
                                isSelected: _isBuyer,
                                onTap: () => setState(() => _isBuyer = true),
                              ),
                            ),
                            const SizedBox(width: AppDimensions.spaceSM),
                            Expanded(
                              child: _PremiumAccountCard(
                                label: "I'm Farming",
                                sublabel: 'Sell Direct Harvest',
                                icon: Icons.agriculture_rounded,
                                isSelected: !_isBuyer,
                                onTap: () => setState(() => _isBuyer = false),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppDimensions.spaceLG),

                        // ── Fields ────────────────────────────────────
                        if (!_isSignInMode) ...[
                          _PremiumField(
                            label: 'Full Name',
                            hint: 'Kasun Perera',
                            icon: Icons.person_outline_rounded,
                            controller: _nameCtrl,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Enter your name' : null,
                          ),
                          const SizedBox(height: AppDimensions.spaceSM),
                        ],

                        _PremiumField(
                          label: 'Email Address',
                          hint: 'kasun.perera@gmail.com',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailCtrl,
                          validator: (v) =>
                              (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                        ),
                        const SizedBox(height: AppDimensions.spaceSM),

                        if (!_isSignInMode) ...[
                          // Phone with country code
                          _PremiumPhoneField(controller: _phoneCtrl),
                          const SizedBox(height: AppDimensions.spaceSM),

                          // Delivery Location
                          _PremiumField(
                            label: 'Delivery Location',
                            hint: 'Colombo, Western Province',
                            icon: Icons.location_on_outlined,
                            suffixIcon: Icons.keyboard_arrow_down_rounded,
                            controller: _locationCtrl,
                          ),
                          const SizedBox(height: AppDimensions.spaceSM),
                        ],

                        // Password
                        _PremiumPasswordField(
                          obscure: _obscurePassword,
                          controller: _passwordCtrl,
                          onToggle: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                          onChanged: _isSignInMode ? null : _updatePasswordStrength,
                          validator: (v) =>
                              (v == null || v.length < 6) ? 'Min. 6 characters' : null,
                        ),

                        // Strength bar
                        if (_passwordStrength > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ...List.generate(4, (i) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: i < _passwordStrength
                                            ? _strengthColor
                                            : AppColors.border,
                                        borderRadius:
                                            BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(width: 8),
                              Text(
                                'Strength: $_strengthLabel',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _strengthColor,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: AppDimensions.spaceSM),

                        // Confirm Password (sign-up only)
                        if (!_isSignInMode) _PremiumField(
                          label: 'Confirm Password',
                          hint: '••••••••••••',
                          icon: Icons.shield_outlined,
                          obscureText: true,
                          controller: _confirmCtrl,
                          suffixIcon: Icons.check_circle_rounded,
                          suffixColor: AppColors.success,
                        ),

                        const SizedBox(height: AppDimensions.spaceMD),

                        // Terms
                        _TermsRow(
                          agreed: _agreedToTerms,
                          onChanged: (v) =>
                              setState(() => _agreedToTerms = v ?? false),
                        ),

                        const SizedBox(height: AppDimensions.spaceLG),

                        // CTA Button
                        _PremiumCTAButton(
                          label: _isSignInMode ? 'Sign In' : 'Create Account',
                          isLoading: _isLoading,
                          onPressed: _submit,
                        ),

                        const SizedBox(height: AppDimensions.spaceMD),

                        // Mode toggle link
                        Center(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isSignInMode = !_isSignInMode;
                              _formKey.currentState?.reset();
                            }),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: _isSignInMode
                                        ? "Don't have an account? "
                                        : 'Already have an account? ',
                                  ),
                                  TextSpan(
                                    text: _isSignInMode ? 'Create Account' : 'Sign In',
                                    style: const TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceLG),

                        // ── Demo / Skip Mode ────────────────────────────
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                          ],
                        ),

                        const SizedBox(height: AppDimensions.spaceMD),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => context.go(AppRoutes.dashboard),
                            icon: const Icon(
                              Icons.flash_on_rounded,
                              size: 18,
                              color: Color(0xFF235D3A),
                            ),
                            label: const Text(
                              'Skip & Explore as Demo User',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF235D3A),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF235D3A),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSM,
                                ),
                              ),
                              backgroundColor:
                                  const Color(0xFF235D3A).withValues(alpha: 0.05),
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
// Premium curved header with animated leaf motif
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader({
    required this.leafFade,
    required this.screenHeight,
  });

  final Animation<double> leafFade;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          width: double.infinity,
          height: screenHeight * 0.26,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF032B1C),
                Color(0xFF063725),
                Color(0xFF0D5C38),
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

        // Content
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo circle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2ECC71), Color(0xFF1E8342)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Farm2Home',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(),
                    const SizedBox(width: 6),
                    Text(
                      'FRESH • DIRECT • HONEST',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _dot(),
                  ],
                ),
              ],
            ),
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
// Premium Account Type Card
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumAccountCard extends StatelessWidget {
  const _PremiumAccountCard({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFE8F8EF), Color(0xFFD0F0DF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primaryGreen
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 11,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.primaryGreen
                    : AppColors.textDark,
              ),
            ),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
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
    this.suffixIcon,
    this.suffixColor,
    this.obscureText = false,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final IconData? suffixIcon;
  final Color? suffixColor;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textDark,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            suffixIcon: suffixIcon != null
                ? Icon(
                    suffixIcon,
                    size: 18,
                    color: suffixColor ?? AppColors.textSecondary,
                  )
                : null,
            filled: true,
            fillColor: AppColors.surfaceWhite,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(
                color: AppColors.primaryGreen,
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
// Phone field with LK flag prefix
// ─────────────────────────────────────────────────────────────────────────────
class _PremiumPhoneField extends StatelessWidget {
  const _PremiumPhoneField({this.controller});
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: '77 123 4567',
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
            prefixIcon: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🇱🇰', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 4),
                  Text(
                    '+94',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 14, color: AppColors.textSecondary),
                ],
              ),
            ),
            filled: true,
            fillColor: AppColors.surfaceWhite,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide:
                  const BorderSide(color: AppColors.primaryGreen, width: 2),
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
    this.onChanged,
    this.validator,
  });

  final bool obscure;
  final VoidCallback onToggle;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: '••••••••••••',
            hintStyle:
                const TextStyle(fontSize: 14, color: AppColors.textHint),
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                size: 18, color: AppColors.textSecondary),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
            filled: true,
            fillColor: AppColors.surfaceWhite,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide:
                  const BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Terms Row
// ─────────────────────────────────────────────────────────────────────────────
class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.agreed, required this.onChanged});

  final bool agreed;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onChanged(!agreed),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: agreed ? AppColors.primaryGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: agreed ? AppColors.primaryGreen : AppColors.border,
                width: 1.5,
              ),
            ),
            child: agreed
                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              children: [
                TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms & Privacy Policy',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
  });
  final VoidCallback onPressed;
  final String label;
  final bool isLoading;

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
              colors: [Color(0xFF1E8342), Color(0xFF0D5C38)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }
}

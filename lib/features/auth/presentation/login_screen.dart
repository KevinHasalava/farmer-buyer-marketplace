import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../../../widgets/premium/google_brand_button.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../services/auth_service.dart';
import '../../farmer/services/farmer_profile_manager.dart';
import '../../buyer/services/buyer_profile_manager.dart';
import '../../driver/services/driver_profile_manager.dart';
import '../../admin/services/admin_auth_service.dart';
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

  // Form controllers
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

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
      _authSubscription =
          SupabaseConfig.auth.onAuthStateChange.listen((data) async {
        final session = data.session;
        if (session != null && mounted) {
          final sbUser = session.user;
          final metadata = sbUser.userMetadata ?? {};
          UserRole targetRole = _selectedRole;
          final registeredRoleStr =
              (metadata['role'] as String?)?.toLowerCase();
          if (registeredRoleStr == 'farmer' ||
              (metadata['is_farmer'] as bool? ?? false)) {
            targetRole = UserRole.farmer;
          } else if (registeredRoleStr == 'buyer') {
            targetRole = UserRole.buyer;
          } else if (registeredRoleStr == 'driver') {
            targetRole = UserRole.driver;
          }

          await context.read<AppSettings>().setRole(targetRole);
          final effectiveName = (metadata['full_name'] as String?) ??
              sbUser.email?.split('@').first ??
              'User';
          final phone = sbUser.phone ?? (metadata['phone'] as String? ?? '');

          if (targetRole == UserRole.farmer) {
            await FarmerProfileManager.instance.updateProfile(
              name: effectiveName,
              email: sbUser.email,
              phone: phone.isNotEmpty ? phone : null,
            );
          } else if (targetRole == UserRole.buyer) {
            await BuyerProfileManager.instance.updateProfile(
              name: effectiveName,
              email: sbUser.email,
              phone: phone.isNotEmpty ? phone : null,
            );
          } else if (targetRole == UserRole.driver) {
            await DriverProfileManager.instance.updateProfile(
              fullName: effectiveName,
              mobileNumber: phone.isNotEmpty ? phone : null,
            );
          }

          if (mounted) {
            context.go(AppRoutes.homeFor(targetRole));
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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Supabase submit ──────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final inputEmail = _emailCtrl.text.trim();
    final inputPassword = _passwordCtrl.text;

    // ── Master Admin Authentication Interceptor ─────────────────────────
    // Allows logging in as Master Admin from any role screen (Buyer, Farmer, Driver)
    if (AdminAuthService.instance.isMasterAdminEmail(inputEmail)) {
      if (AdminAuthService.instance.isValidAdminCredentials(inputEmail, inputPassword)) {
        setState(() => _isLoading = true);
        HapticFeedback.mediumImpact();

        final success = await AdminAuthService.instance.login(
          email: inputEmail,
          password: inputPassword,
          rememberSession: true,
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.shield_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '✓ Master Admin verified. Redirecting to Admin Console...',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF047857),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          context.go(AppRoutes.adminPanel);
          return;
        }
      } else {
        _showError('Invalid administrator password. Please check your credentials.');
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final user = await _authService.signIn(
        email: inputEmail,
        password: inputPassword,
      );

      if (!mounted) return;

      // Auto-detect registered role from Supabase metadata
      UserRole targetRole = _selectedRole;
      final registeredRoleStr =
          (user.userMetadata?['role'] as String?)?.toLowerCase();
      if (registeredRoleStr == 'farmer' || user.isFarmer) {
        targetRole = UserRole.farmer;
      } else if (registeredRoleStr == 'buyer') {
        targetRole = UserRole.buyer;
      } else if (registeredRoleStr == 'driver') {
        targetRole = UserRole.driver;
      }

      await context.read<AppSettings>().setRole(targetRole);

      final effectiveName =
          user.name.isNotEmpty && !user.name.startsWith('User ')
              ? user.name
              : _emailCtrl.text.trim().split('@').first;
      final phone = user.phone;

      if (targetRole == UserRole.farmer) {
        await FarmerProfileManager.instance.updateProfile(
          name: effectiveName,
          email: user.email,
          phone: phone.isNotEmpty ? phone : null,
        );
      } else if (targetRole == UserRole.buyer) {
        await BuyerProfileManager.instance.updateProfile(
          name: effectiveName,
          email: user.email,
          phone: phone.isNotEmpty ? phone : null,
        );
      } else if (targetRole == UserRole.driver) {
        await DriverProfileManager.instance.updateProfile(
          fullName: effectiveName,
          mobileNumber: phone.isNotEmpty ? phone : null,
        );
      }

      if (mounted) {
        context.go(AppRoutes.homeFor(targetRole));
      }
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('rate limit')) {
        if (mounted) {
          _showRateLimitDialog();
          return;
        }
      }
      _showError(e.message);
    } catch (e) {
      _showError('Authentication error: ${e.toString()}');
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

  void _showRateLimitDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.hourglass_top_rounded, color: Color(0xFFE65100), size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.tr.emailNoticeTitle,
                style: const TextStyle(
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
            Text(
              context.tr.emailNoticeBody,
              style: const TextStyle(
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
              child: Text(
                context.tr.emailNoticeTip,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF795548),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              context.tr.enterDirectlyPrompt,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF235D3A),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.tr.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final inputEmail = _emailCtrl.text.trim();
              if (inputEmail.isNotEmpty) {
                final derivedName = inputEmail.split('@').first;
                if (_selectedRole == UserRole.farmer) {
                  await FarmerProfileManager.instance.updateProfile(
                    name: derivedName,
                    email: inputEmail,
                  );
                } else if (_selectedRole == UserRole.buyer) {
                  await BuyerProfileManager.instance.updateProfile(
                    name: derivedName,
                    email: inputEmail,
                  );
                } else if (_selectedRole == UserRole.driver) {
                  await DriverProfileManager.instance.updateProfile(
                    fullName: derivedName,
                  );
                }
              }
              if (mounted) {
                context.go(AppRoutes.homeFor(_selectedRole));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF235D3A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(context.tr.continueToApp),
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

  Widget _buildRoleSegmentedPicker() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _buildRoleTab(UserRole.buyer, Icons.shopping_basket_rounded, context.tr.buyer),
          _buildRoleTab(UserRole.farmer, Icons.agriculture_rounded, context.tr.farmer),
          _buildRoleTab(UserRole.driver, Icons.local_shipping_rounded, context.tr.driver),
        ],
      ),
    );
  }

  Widget _buildRoleTab(UserRole role, IconData icon, String title) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedRole = role);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? const Color(0xFF15803D) : const Color(0xFF64748B),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            selectedRole: _selectedRole,
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
                        // ── Interactive Segmented Role Switcher ─────────────
                        _buildRoleSegmentedPicker(),

                        // Title
                        Text(
                          context.tr.signInToYourAccount,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr.enterEmailPassword,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceMD),

                        // ── Fields ────────────────────────────────────
                        _PremiumField(
                          label: context.tr.email,
                          hint: 'your.email@example.com',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailCtrl,
                          validator: (v) =>
                              (v == null || !v.contains('@')) ? context.tr.invalidEmail : null,
                        ),
                        const SizedBox(height: AppDimensions.spaceMD),

                        // Password
                        _PremiumPasswordField(
                          obscure: _obscurePassword,
                          controller: _passwordCtrl,
                          onToggle: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                          validator: (v) =>
                              (v == null || v.length < 6) ? context.tr.passwordMinLength : null,
                        ),

                        const SizedBox(height: AppDimensions.spaceLG),

                        // CTA Button
                        _PremiumCTAButton(
                          label: context.tr.signIn,
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

                        const SizedBox(height: 14),

                        // ── Mobile OTP Alternative Pill ─────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: TextButton.icon(
                            onPressed: () => context.go(AppRoutes.phoneAuth),
                            icon: const Icon(
                              Icons.phone_iphone_rounded,
                              size: 18,
                              color: Color(0xFF1E8342),
                            ),
                            label: Text(
                              context.tr.mobileOtpInstead,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E8342),
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F8F5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
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
                                  onTap: () => context.push(
                                    AppRoutes.registerFor(_selectedRole),
                                  ),
                                  child: Text(
                                    switch (_selectedRole) {
                                      UserRole.buyer => context.tr.registerAsBuyer,
                                      UserRole.farmer => context.tr.registerAsFarmer,
                                      UserRole.driver => context.tr.registerAsDriver,
                                    },
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

                        const SizedBox(height: 18),

                        // ── Guest / Demo Explore Mode (ලියාපදිංචි නොවී App එක බලන්න) ──
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              await context.read<AppSettings>().setRole(_selectedRole);
                              if (context.mounted) {
                                context.go(AppRoutes.homeFor(_selectedRole));
                              }
                            },
                            icon: const Icon(
                              Icons.explore_outlined,
                              size: 19,
                              color: Color(0xFF1E8342),
                            ),
                            label: Text(
                              context.tr.skipDemoUser,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E8342),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFA7F3D0),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              backgroundColor: const Color(0xFFF0FDF4),
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
    required this.selectedRole,
  });

  final Animation<double> leafFade;
  final double screenHeight;
  final UserRole selectedRole;

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

        // Content
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo circle
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2ECC71), Color(0xFF1E8342)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.45),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 8),
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
                // Dynamic Role Badge Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
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
                        switch (selectedRole) {
                          UserRole.buyer => Icons.shopping_basket_rounded,
                          UserRole.farmer => Icons.agriculture_rounded,
                          UserRole.driver => Icons.local_shipping_rounded,
                        },
                        size: 13,
                        color: const Color(0xFFFBBF24),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        switch (selectedRole) {
                          UserRole.buyer => '${context.tr.buyer} Portal',
                          UserRole.farmer => '${context.tr.farmer} Portal',
                          UserRole.driver => '${context.tr.driver} Portal',
                        },
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
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
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
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
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: 0.1,
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
                    const Icon(
                      Icons.arrow_forward_rounded,
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


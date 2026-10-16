import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../services/auth_service.dart';

/// One simple registration form for Farmers, Buyers and Drivers.
///
/// Everything that can be chosen from a list is a dropdown. The details are
/// sent as sign-up metadata; the `handle_new_user` database trigger creates
/// the profile + the farmers / buyers / drivers row automatically.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.initialRole});

  final UserRole? initialRole;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _districts = <String>[
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kegalle',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Matara',
    'Monaragala',
    'Mullaitivu',
    'Nuwara Eliya',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya',
  ];
  static const _farmScales = <String>[
    'Under 1 Acre',
    '1 - 3 Acres',
    '3 - 10 Acres',
    '10+ Acres',
  ];
  static const _practices = <String>[
    'Certified Organic',
    'Chemical-Free / Natural',
    'Conventional (GAP)',
    'In Conversion',
  ];
  static const _crops = <String>[
    'Carrots & Root Vegetables',
    'Leeks & Cabbage',
    'Tomatoes',
    'Leafy Greens',
    'Beans & Pumpkin',
    'Fruits',
    'Rice & Grains',
    'Spices',
    'Other',
  ];
  static const _buyerTypes = <String>[
    'Family / Household',
    'Restaurant & Hospitality',
    'Retail Store',
    'Wholesaler',
    'Other',
  ];
  static const _vehicleTypes = <String>[
    'Motorbike',
    'Three-Wheeler',
    'Lorry (Small)',
    'Cargo Van',
    'Refrigerated Van',
    'Truck',
  ];
  static const _capacities = <String>[
    'Up to 100 kg',
    '100 - 500 kg',
    '500 kg - 1 ton',
    '1 - 3 tons',
    'Above 3 tons',
  ];

  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _farmNameCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();

  late UserRole _role = widget.initialRole ?? UserRole.farmer;
  String? _district;
  String? _scale;
  String? _practice;
  String? _crop;
  String? _buyerType;
  String? _vehicleType;
  String? _capacity;

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _phoneCtrl,
      _emailCtrl,
      _passCtrl,
      _confirmCtrl,
      _farmNameCtrl,
      _plateCtrl,
      _licenseCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── helpers ────────────────────────────────────────────────────────────

  /// True when the user already picked a role on the previous screen, so we
  /// must not ask for it again.
  bool get _roleLocked => widget.initialRole != null;

  String? _required(String? v, [String msg = 'Required']) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  String? _validatePhone(String? v) {
    final raw = (v ?? '').replaceAll(RegExp(r'[\s\-]'), '');
    if (raw.isEmpty) return 'Mobile number is required';
    if (!RegExp(r'^(\+94|0)?7\d{8}$').hasMatch(raw)) {
      return 'Enter a valid mobile number (e.g. 0771234567)';
    }
    return null;
  }

  String? _validateName(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Full name is required';
    if (s.length < 3) return 'Name must be at least 3 characters';
    if (!RegExp(r"^[\p{L}\p{M}\s.'-]+$", unicode: true).hasMatch(s)) {
      return 'Name can only contain letters';
    }
    return null;
  }

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(s)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Password is required';
    if (s.length < 6) return 'At least 6 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(s) || !RegExp(r'\d').hasMatch(s)) {
      return 'Use letters and numbers';
    }
    return null;
  }

  String? _validateConfirm(String? v) {
    if ((v ?? '').isEmpty) return 'Please confirm your password';
    if (v != _passCtrl.text) return 'Passwords do not match';
    return null;
  }

  String? _validateFarmName(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Farm name is required';
    if (s.length < 2) return 'Farm name is too short';
    return null;
  }

  String? _validatePlate(String? v) {
    final s = (v ?? '').trim().toUpperCase();
    if (s.isEmpty) return 'Vehicle number is required';
    if (!RegExp(r'^[A-Z0-9][A-Z0-9\s\-]{3,11}$').hasMatch(s) ||
        !RegExp(r'\d').hasMatch(s)) {
      return 'Enter a valid vehicle number (e.g. WP CAB-1234)';
    }
    return null;
  }

  String? _validateLicense(String? v) {
    final s = (v ?? '').trim().toUpperCase();
    if (s.isEmpty) return 'Licence number is required';
    if (!RegExp(r'^[A-Z0-9]{6,12}$').hasMatch(s)) {
      return 'Enter a valid licence number (e.g. B1234567)';
    }
    return null;
  }

  String _normalizePhone(String v) {
    final raw = v.replaceAll(RegExp(r'[\s\-]'), '');
    if (raw.startsWith('+94')) return raw;
    if (raw.startsWith('0')) return '+94${raw.substring(1)}';
    return '+94$raw';
  }

  String get _roleLabel => switch (_role) {
    UserRole.farmer => 'Farmer',
    UserRole.buyer => 'Buyer',
    UserRole.driver => 'Driver',
  };

  Map<String, dynamic> _details() {
    switch (_role) {
      case UserRole.farmer:
        return {
          'district': _district,
          'farm_name': _farmNameCtrl.text.trim(),
          'scale': _scale,
          'practice': _practice,
          'crops': [_crop],
        };
      case UserRole.buyer:
        return {'district': _district, 'buyer_type': _buyerType};
      case UserRole.driver:
        return {
          'district': _district,
          'vehicle_type': _vehicleType,
          'vehicle_number': _plateCtrl.text.trim().toUpperCase(),
          'license_number': _licenseCtrl.text.trim().toUpperCase(),
          'cargo_capacity': _capacity,
          'is_cold_box_equipped': _vehicleType == 'Refrigerated Van',
        };
    }
  }

  void _toast(String msg, {bool error = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg.trAuto(context)),
        backgroundColor: error ? AppColors.error : AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _loading = true);
    try {
      final signedIn = await const AuthService().signUpWithRole(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        fullName: _nameCtrl.text,
        role: _role.name,
        phone: _normalizePhone(_phoneCtrl.text),
        details: _details()..removeWhere((_, v) => v == null),
      );

      // Direct client-side sync backup to guarantee user is in tables
      try {
        final uid =
            const AuthService().lastCreatedUserId ??
            SupabaseConfig.auth.currentUser?.id;
        if (uid != null) {
          final cleanPhone = _normalizePhone(_phoneCtrl.text);
          await SupabaseConfig.client.from('profiles').upsert({
            'id': uid,
            'role': _role.name,
            'full_name': _nameCtrl.text.trim(),
            'email': _emailCtrl.text.trim(),
            'phone': cleanPhone,
            'district': _district,
            'address': _role == UserRole.buyer ? _district : '',
            'is_active': true,
          }, onConflict: 'id');

          if (_role == UserRole.buyer) {
            await SupabaseConfig.client.from('buyers').upsert({
              'id': uid,
              'full_name': _nameCtrl.text.trim(),
              'email': _emailCtrl.text.trim(),
              'phone': cleanPhone,
              'district': _district,
              'delivery_hub': _district,
              'buyer_type': _buyerType,
              'status': 'Active',
            }, onConflict: 'id');
          } else if (_role == UserRole.farmer) {
            await SupabaseConfig.client.from('farmers').upsert({
              'id': uid,
              'full_name': _nameCtrl.text.trim(),
              'email': _emailCtrl.text.trim(),
              'phone': cleanPhone,
              'farm_name': _farmNameCtrl.text.trim(),
              'district': _district,
              'scale': _scale,
              'practice': _practice,
              'crops': [_crop],
              'status': 'Active',
            }, onConflict: 'id');
          } else if (_role == UserRole.driver) {
            await SupabaseConfig.client.from('drivers').upsert({
              'id': uid,
              'full_name': _nameCtrl.text.trim(),
              'phone_number': cleanPhone,
              'license_number': _licenseCtrl.text.trim().toUpperCase(),
              'vehicle_type': _vehicleType,
              'vehicle_number': _plateCtrl.text.trim().toUpperCase(),
              'cargo_capacity': _capacity,
              'is_cold_box_equipped': _vehicleType == 'Refrigerated Van',
              'duty_status': true,
              'is_on_duty': true,
            }, onConflict: 'id');
          }
        }
      } catch (e) {
        debugPrint('[RegisterScreen] Client-side backup upsert note: $e');
      }

      if (!mounted) return;
      await context.read<AppSettings>().setRole(_role);
      if (!mounted) return;

      if (signedIn) {
        _toast('Welcome to Farm2Home!', error: false);
        context.go(AppRoutes.homeFor(_role));
      } else {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder:
              (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text('Check your email'),
                content: Text(
                  'We sent a confirmation link to ${_emailCtrl.text.trim()}. '
                  'Open it, then sign in.',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
        if (mounted) context.go(AppRoutes.login);
      }
    } on AuthException catch (e) {
      _toast(e.message);
    } catch (e) {
      _toast('Registration failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── UI ─────────────────────────────────────────────────────────────────

  static const _inputText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  IconData get _roleIcon => switch (_role) {
    UserRole.farmer => Icons.agriculture_rounded,
    UserRole.buyer => Icons.shopping_basket_rounded,
    UserRole.driver => Icons.local_shipping_rounded,
  };

  InputDecoration _deco(String label, IconData icon, {Widget? suffix}) {
    OutlineInputBorder b(Color c, [double w = 1.2]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      labelText: label.trAuto(context),
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColors.primaryGreen,
        fontWeight: FontWeight.w700,
      ),
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      errorMaxLines: 2,
      counterText: '',
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 10, right: 6),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.primaryGreen),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 40),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FAF9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
      border: b(const Color(0xFFE2E8F0)),
      enabledBorder: b(const Color(0xFFE2E8F0)),
      focusedBorder: b(AppColors.primaryGreen, 1.8),
      errorBorder: b(AppColors.error),
      focusedErrorBorder: b(AppColors.error, 1.8),
    );
  }

  Widget _text(
    TextEditingController c,
    String label,
    IconData icon, {
    TextInputType? type,
    String? Function(String?)? validator,
    bool obscure = false,
    Widget? suffix,
    TextCapitalization caps = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
    int? maxLength,
    bool last = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        obscureText: obscure,
        textCapitalization: caps,
        maxLength: maxLength,
        inputFormatters: formatters,
        style: _inputText,
        cursorColor: AppColors.primaryGreen,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (v) => (validator ?? _required)(v)?.trAuto(context),
        decoration: _deco(label, icon, suffix: suffix),
      ),
    );
  }

  Widget _drop({
    required String label,
    required IconData icon,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        key: ValueKey('${_role.name}-$label'),
        initialValue: value,
        isExpanded: true,
        style: _inputText,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.primaryGreen,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: _deco(label, icon),
        items: [
          for (final i in items)
            DropdownMenuItem(
              value: i,
              child: Text(
                i.trAuto(context),
                style: _inputText,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: onChanged,
        validator: (v) => v == null ? 'Please select'.trAuto(context) : null,
      ),
    );
  }

  Widget _section(String title, IconData icon) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 14),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF15803D), Color(0xFF34D399)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Text(
          title.trAuto(context),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: AppColors.darkGreen,
          ),
        ),
      ],
    ),
  );

  Widget _card(List<Widget> children) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFE8EEEA)),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryGreen.withValues(alpha: 0.07),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );

  /// Shown instead of the role dropdown when the role is already chosen.
  Widget _lockedRoleBadge() => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.primaryGreen.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.25)),
    ),
    child: Row(
      children: [
        Icon(_roleIcon, color: AppColors.primaryGreen, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${'Registering as'.trAuto(context)} ${_roleLabel.trAuto(context)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
              fontSize: 14,
            ),
          ),
        ),
        const Icon(
          Icons.verified_rounded,
          color: AppColors.primaryGreen,
          size: 20,
        ),
      ],
    ),
  );

  (String, IconData) get _roleSectionMeta => switch (_role) {
    UserRole.farmer => ('FARM DETAILS', Icons.agriculture_rounded),
    UserRole.buyer => ('BUYER DETAILS', Icons.storefront_rounded),
    UserRole.driver => ('VEHICLE DETAILS', Icons.local_shipping_rounded),
  };

  List<Widget> _roleFields() {
    switch (_role) {
      case UserRole.farmer:
        return [
          _text(
            _farmNameCtrl,
            'Farm name',
            Icons.agriculture_rounded,
            caps: TextCapitalization.words,
            maxLength: 60,
            validator: _validateFarmName,
          ),
          _drop(
            label: 'Farm size',
            icon: Icons.landscape_rounded,
            items: _farmScales,
            value: _scale,
            onChanged: (v) => setState(() => _scale = v),
          ),
          _drop(
            label: 'Farming method',
            icon: Icons.eco_rounded,
            items: _practices,
            value: _practice,
            onChanged: (v) => setState(() => _practice = v),
          ),
          _drop(
            label: 'Main crop',
            icon: Icons.grass_rounded,
            items: _crops,
            value: _crop,
            onChanged: (v) => setState(() => _crop = v),
          ),
        ];
      case UserRole.buyer:
        return [
          _drop(
            label: 'I am buying as',
            icon: Icons.storefront_rounded,
            items: _buyerTypes,
            value: _buyerType,
            onChanged: (v) => setState(() => _buyerType = v),
          ),
        ];
      case UserRole.driver:
        return [
          _drop(
            label: 'Vehicle type',
            icon: Icons.local_shipping_rounded,
            items: _vehicleTypes,
            value: _vehicleType,
            onChanged: (v) => setState(() => _vehicleType = v),
          ),
          _text(
            _plateCtrl,
            'Vehicle number (e.g. WP CAB-1234)',
            Icons.pin_rounded,
            caps: TextCapitalization.characters,
            maxLength: 12,
            formatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s\-]')),
            ],
            validator: _validatePlate,
          ),
          _text(
            _licenseCtrl,
            'Driving licence number',
            Icons.badge_rounded,
            caps: TextCapitalization.characters,
            maxLength: 12,
            formatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
            validator: _validateLicense,
          ),
          _drop(
            label: 'Load capacity',
            icon: Icons.scale_rounded,
            items: _capacities,
            value: _capacity,
            onChanged: (v) => setState(() => _capacity = v),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
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
              context.go(AppRoutes.login);
            }
          },
        ),
        title: AutoText(
          'Create account',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 550),
                      curve: Curves.easeOutCubic,
                      builder:
                          (_, t, child) => Opacity(
                            opacity: t,
                            child: Transform.translate(
                              offset: Offset(0, 16 * (1 - t)),
                              child: child,
                            ),
                          ),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF064E3B), Color(0xFF15803D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF064E3B,
                              ).withValues(alpha: 0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Icon(
                                _roleIcon,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoText(
                                    '${'Join Farm2Home as a'.trAuto(context)} ${_roleLabel.trAuto(context)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AutoText(
                                    'It only takes a minute.',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Only ask for the role if it was not already chosen earlier.
                    if (!_roleLocked)
                      _card([
                        _section('ACCOUNT TYPE', Icons.groups_rounded),
                        _drop(
                          label: 'I am a',
                          icon: Icons.groups_rounded,
                          items: const ['Farmer', 'Buyer', 'Driver'],
                          value: _roleLabel,
                          onChanged: (v) {
                            if (v == null) return;
                            setState(
                              () =>
                                  _role = UserRole.values.firstWhere(
                                    (r) => r.name == v.toLowerCase(),
                                  ),
                            );
                          },
                        ),
                      ])
                    else
                      _lockedRoleBadge(),

                    _card([
                      _section('YOUR DETAILS', Icons.person_rounded),
                      _text(
                        _nameCtrl,
                        'Full name',
                        Icons.person_rounded,
                        caps: TextCapitalization.words,
                        maxLength: 60,
                        validator: _validateName,
                      ),
                      _text(
                        _phoneCtrl,
                        'Mobile number',
                        Icons.phone_rounded,
                        type: TextInputType.phone,
                        maxLength: 13,
                        formatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+\s\-]'),
                          ),
                        ],
                        validator: _validatePhone,
                      ),
                      _drop(
                        label: 'District',
                        icon: Icons.location_on_rounded,
                        items: _districts,
                        value: _district,
                        onChanged: (v) => setState(() => _district = v),
                      ),
                    ]),

                    _card([
                      _section(_roleSectionMeta.$1, _roleSectionMeta.$2),
                      ..._roleFields(),
                    ]),

                    _card([
                      _section('SIGN-IN DETAILS', Icons.lock_rounded),
                      _text(
                        _emailCtrl,
                        'Email',
                        Icons.mail_rounded,
                        type: TextInputType.emailAddress,
                        maxLength: 80,
                        formatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        validator: _validateEmail,
                      ),
                      _text(
                        _passCtrl,
                        'Password (min 6 characters)',
                        Icons.lock_rounded,
                        obscure: _obscure,
                        maxLength: 64,
                        validator: _validatePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      _text(
                        _confirmCtrl,
                        'Confirm password',
                        Icons.lock_outline_rounded,
                        obscure: _obscure,
                        maxLength: 64,
                        last: true,
                        validator: _validateConfirm,
                      ),
                    ]),

                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF15803D), Color(0xFF1E8342)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child:
                            _loading
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.4,
                                  ),
                                )
                                : AutoText(
                                  'Create account',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: AutoText(
                          'Already have an account? Sign in',
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                          ),
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
    );
  }
}

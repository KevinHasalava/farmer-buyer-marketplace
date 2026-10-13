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
    'Ampara', 'Anuradhapura', 'Badulla', 'Batticaloa', 'Colombo', 'Galle',
    'Gampaha', 'Hambantota', 'Jaffna', 'Kalutara', 'Kandy', 'Kegalle',
    'Kilinochchi', 'Kurunegala', 'Mannar', 'Matale', 'Matara', 'Monaragala',
    'Mullaitivu', 'Nuwara Eliya', 'Polonnaruwa', 'Puttalam', 'Ratnapura',
    'Trincomalee', 'Vavuniya',
  ];
  static const _farmScales = <String>[
    'Under 1 Acre', '1 - 3 Acres', '3 - 10 Acres', '10+ Acres',
  ];
  static const _practices = <String>[
    'Certified Organic', 'Chemical-Free / Natural', 'Conventional (GAP)',
    'In Conversion',
  ];
  static const _crops = <String>[
    'Carrots & Root Vegetables', 'Leeks & Cabbage', 'Tomatoes', 'Leafy Greens',
    'Beans & Pumpkin', 'Fruits', 'Rice & Grains', 'Spices', 'Other',
  ];
  static const _buyerTypes = <String>[
    'Family / Household', 'Restaurant & Hospitality', 'Retail Store',
    'Wholesaler', 'Other',
  ];
  static const _vehicleTypes = <String>[
    'Motorbike', 'Three-Wheeler', 'Lorry (Small)', 'Cargo Van',
    'Refrigerated Van', 'Truck',
  ];
  static const _capacities = <String>[
    'Up to 100 kg', '100 - 500 kg', '500 kg - 1 ton', '1 - 3 tons',
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
      _nameCtrl, _phoneCtrl, _emailCtrl, _passCtrl, _confirmCtrl,
      _farmNameCtrl, _plateCtrl, _licenseCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── helpers ────────────────────────────────────────────────────────────

  String? _required(String? v, [String msg = 'Required']) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  String? _validatePhone(String? v) {
    final raw = (v ?? '').replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^(\+94|0)?7\d{8}$').hasMatch(raw)) {
      return 'Enter a valid mobile number (e.g. 0771234567)';
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
        return {
          'district': _district,
          'buyer_type': _buyerType,
        };
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : AppColors.primaryGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
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
        final uid = const AuthService().lastCreatedUserId ??
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
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  InputDecoration _deco(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label.trAuto(context),
      prefixIcon: Icon(icon, size: 20, color: AppColors.primaryGreen),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.6),
      ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        obscureText: obscure,
        textCapitalization: caps,
        validator: validator ?? _required,
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
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: _deco(label, icon),
        items: [
          for (final i in items)
            DropdownMenuItem(
              value: i,
              child: Text(i.trAuto(context), overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: onChanged,
        validator: (v) => v == null ? 'Please select' : null,
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 12),
        child: Text(
          title.trAuto(context),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AppColors.primaryGreen,
          ),
        ),
      );

  List<Widget> _roleFields() {
    switch (_role) {
      case UserRole.farmer:
        return [
          _section('FARM DETAILS'),
          _text(_farmNameCtrl, 'Farm name', Icons.agriculture_rounded,
              caps: TextCapitalization.words),
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
          _section('BUYER DETAILS'),
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
          _section('VEHICLE DETAILS'),
          _drop(
            label: 'Vehicle type',
            icon: Icons.local_shipping_rounded,
            items: _vehicleTypes,
            value: _vehicleType,
            onChanged: (v) => setState(() => _vehicleType = v),
          ),
          _text(_plateCtrl, 'Vehicle number (e.g. WP CAB-1234)',
              Icons.pin_rounded,
              caps: TextCapitalization.characters),
          _text(_licenseCtrl, 'Driving licence number', Icons.badge_rounded,
              caps: TextCapitalization.characters),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF064E3B), Color(0xFF15803D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.eco_rounded,
                          color: Colors.white, size: 34),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoText(
                              'Join Farm2Home as a $_roleLabel',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AutoText(
                              'It only takes a minute.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _section('ACCOUNT TYPE'),
                _drop(
                  label: 'I am a',
                  icon: Icons.groups_rounded,
                  items: const ['Farmer', 'Buyer', 'Driver'],
                  value: _roleLabel,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _role = UserRole.values
                        .firstWhere((r) => r.name == v.toLowerCase()));
                  },
                ),

                _section('YOUR DETAILS'),
                _text(_nameCtrl, 'Full name', Icons.person_rounded,
                    caps: TextCapitalization.words),
                _text(_phoneCtrl, 'Mobile number', Icons.phone_rounded,
                    type: TextInputType.phone, validator: _validatePhone),
                _drop(
                  label: 'District',
                  icon: Icons.location_on_rounded,
                  items: _districts,
                  value: _district,
                  onChanged: (v) => setState(() => _district = v),
                ),

                ..._roleFields(),

                _section('SIGN-IN DETAILS'),
                _text(
                  _emailCtrl,
                  'Email',
                  Icons.mail_rounded,
                  type: TextInputType.emailAddress,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)
                        ? null
                        : 'Enter a valid email address';
                  },
                ),
                _text(
                  _passCtrl,
                  'Password (min 6 characters)',
                  Icons.lock_rounded,
                  obscure: _obscure,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'At least 6 characters'
                      : null,
                  suffix: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                _text(
                  _confirmCtrl,
                  'Confirm password',
                  Icons.lock_outline_rounded,
                  obscure: _obscure,
                  validator: (v) =>
                      v != _passCtrl.text ? 'Passwords do not match' : null,
                ),

                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.4),
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
    );
  }
}

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../services/auth_service.dart';
import '../../../services/notify_sms_service.dart';
import 'otp_verification_dialog.dart';

/// Step-by-step registration for Farmers, Buyers and Drivers.
///
/// * Role already chosen earlier → it is never asked again.
/// * Signed in with Google (session exists, no profile yet) → the e-mail and
///   password steps are skipped, because Google already proved the identity.
/// * Normal sign-up → e-mail + password step is included.
///
/// The details are sent as sign-up metadata; the `handle_new_user` trigger
/// creates the profile + role row. A client-side upsert is a safety net (and
/// the main path for Google users, who have no sign-up metadata).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.initialRole});

  final UserRole? initialRole;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

enum _Step { personal, role, account, review }

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

  static const _inputText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

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

  int _stepIndex = 0;
  bool _social = false;
  String _socialEmail = '';
  bool _agreed = false;
  bool _agreeError = false;
  bool _obscure = true;
  bool _loading = false;

  // OTP verification state for phone number on personal step
  bool _phoneVerified = false;

  // Profile photo (optional). Kept in memory until the account exists.
  Uint8List? _photoBytes;
  String _photoExt = 'jpg';

  @override
  void initState() {
    super.initState();
    if (SupabaseConfig.isInitialized) {
      final u = SupabaseConfig.auth.currentUser;
      if (u != null) {
        _social = true;
        _socialEmail = u.email ?? '';
        final meta = u.userMetadata ?? {};
        final n = (meta['full_name'] ?? meta['name'] ?? '').toString().trim();
        if (n.isNotEmpty) _nameCtrl.text = n;
      }
    }
  }

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

  bool get _roleLocked => widget.initialRole != null;

  List<_Step> get _steps =>
      _social
          ? const [_Step.personal, _Step.role, _Step.review]
          : const [_Step.personal, _Step.role, _Step.account, _Step.review];

  _Step get _step => _steps[_stepIndex];
  bool get _isLast => _stepIndex == _steps.length - 1;

  String _stepTitle(_Step s) => switch (s) {
    _Step.personal => 'About you',
    _Step.role => switch (_role) {
      UserRole.farmer => 'Farm details',
      UserRole.buyer => 'Buyer details',
      UserRole.driver => 'Vehicle details',
    },
    _Step.account => 'Sign-in details',
    _Step.review => 'Review & confirm',
  };

  String get _roleLabel => switch (_role) {
    UserRole.farmer => 'Farmer',
    UserRole.buyer => 'Buyer',
    UserRole.driver => 'Driver',
  };

  IconData get _roleIcon => switch (_role) {
    UserRole.farmer => Icons.agriculture_rounded,
    UserRole.buyer => Icons.shopping_basket_rounded,
    UserRole.driver => Icons.local_shipping_rounded,
  };

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

  // ── navigation between steps ───────────────────────────────────────────

  void _next() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.mediumImpact();
      return;
    }
    if (_isLast) {
      if (!_agreed) {
        HapticFeedback.mediumImpact();
        setState(() => _agreeError = true);
        return;
      }
      _submit();
      return;
    }
    // ── Phone OTP gate on Step 0 (personal step) ────────────────────────
    // Social (Google) users skip OTP because their identity is already proven.
    if (_stepIndex == 0 && !_social && !_phoneVerified) {
      _sendAndVerifyPhoneOtp();
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _stepIndex++);
  }

  /// Sends an SMS OTP to the entered phone number and shows the verification
  /// sheet. On success, marks the phone as verified and advances to the next step.
  Future<void> _sendAndVerifyPhoneOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (!NotifySmsService.isValidSriLankanMobile(phone)) {
      _toast('Please enter a valid Sri Lankan mobile number');
      return;
    }

    setState(() => _loading = true);
    final result = await NotifySmsService.instance.sendOtp(phone);
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success) {
      // If SMS gateway fails, warn but still let the user continue
      // (dev/test mode or gateway unavailable) if we got the OTP code
      if (result.otpCode == null) {
        _toast(result.error ?? 'Could not send OTP. Please try again.');
        return;
      }
      // Gateway error but we have the code locally (test fallback)
      debugPrint('[RegisterScreen] SMS gateway error: ${result.error}. '
          'OTP is ${result.otpCode} (dev fallback active)');
    }

    if (!mounted) return;
    final verified = await OtpVerificationSheet.show(
      context,
      rawPhone: phone,
      onVerified: () {
        if (mounted) setState(() => _phoneVerified = true);
      },
    );

    if (!mounted) return;
    if (verified == true) {
      HapticFeedback.selectionClick();
      setState(() => _stepIndex++);
    }
  }

  void _goTo(int i) {
    FocusScope.of(context).unfocus();
    setState(() => _stepIndex = i);
  }

  Future<void> _leave() async {
    if (_stepIndex > 0) {
      _goTo(_stepIndex - 1);
      return;
    }
    if (_social) {
      await const AuthService().signOut();
      if (mounted) context.go(AppRoutes.login);
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  // ── saving ─────────────────────────────────────────────────────────────

  /// Lets the user choose a profile photo from camera / gallery (optional).
  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final x = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        _toast('Photo is too large (max 5 MB)');
        return;
      }
      final dot = x.name.lastIndexOf('.');
      final ext = dot == -1 ? 'jpg' : x.name.substring(dot + 1).toLowerCase();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _photoExt =
            const ['jpg', 'jpeg', 'png', 'webp'].contains(ext) ? ext : 'jpg';
      });
    } catch (e) {
      _toast('Could not open the photo picker');
    }
  }

  void _showPhotoSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Profile photo'.trAuto(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!kIsWeb)
                    ListTile(
                      leading: const Icon(
                        Icons.photo_camera_rounded,
                        color: AppColors.primaryGreen,
                      ),
                      title: Text('Take a photo'.trAuto(context)),
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickPhoto(ImageSource.camera);
                      },
                    ),
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primaryGreen,
                    ),
                    title: Text('Choose from gallery'.trAuto(context)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickPhoto(ImageSource.gallery);
                    },
                  ),
                  if (_photoBytes != null)
                    ListTile(
                      leading: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                      title: Text(
                        'Remove photo'.trAuto(context),
                        style: const TextStyle(color: AppColors.error),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() => _photoBytes = null);
                      },
                    ),
                ],
              ),
            ),
          ),
    );
  }

  /// Uploads the chosen photo to the public `avatars` bucket and returns its
  /// URL. Never blocks registration: returns null if anything goes wrong.
  Future<String?> _uploadPhoto(String uid) async {
    final bytes = _photoBytes;
    if (bytes == null) return null;
    try {
      final path =
          '$uid/avatar-${DateTime.now().millisecondsSinceEpoch}.$_photoExt';
      final store = SupabaseConfig.client.storage.from('avatars');
      await store.uploadBinary(
        path,
        bytes,
        fileOptions: sb.FileOptions(
          contentType: _photoExt == 'jpg' ? 'image/jpeg' : 'image/$_photoExt',
          upsert: true,
        ),
      );
      return store.getPublicUrl(path);
    } catch (e) {
      debugPrint('[RegisterScreen] photo upload note: $e');
      _toast(
        'Account saved, but the photo could not be uploaded. '
        'You can add it later from your profile.',
      );
      return null;
    }
  }

  /// Writes the profile + role row directly. Needed for Google users (no
  /// sign-up metadata for the trigger) and used as a safety net otherwise.
  Future<void> _syncTables(
    String uid,
    String email, {
    String? avatarUrl,
  }) async {
    final cleanPhone = _normalizePhone(_phoneCtrl.text);
    final name = _nameCtrl.text.trim();
    final db = SupabaseConfig.client;

    await db.from('profiles').upsert({
      'id': uid,
      'role': _role.name,
      'full_name': name,
      'email': email,
      'phone': cleanPhone,
      'district': _district,
      'address': _role == UserRole.buyer ? _district : '',
      'is_active': true,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    }, onConflict: 'id');

    switch (_role) {
      case UserRole.buyer:
        await db.from('buyers').upsert({
          'id': uid,
          'full_name': name,
          'email': email,
          'phone': cleanPhone,
          'district': _district,
          'delivery_hub': _district,
          'buyer_type': _buyerType,
          'status': 'Active',
        }, onConflict: 'id');
      case UserRole.farmer:
        await db.from('farmers').upsert({
          'id': uid,
          'full_name': name,
          'email': email,
          'phone': cleanPhone,
          'farm_name': _farmNameCtrl.text.trim(),
          'district': _district,
          'scale': _scale,
          'practice': _practice,
          'crops': [_crop],
          'status': 'Active',
        }, onConflict: 'id');
      case UserRole.driver:
        await db.from('drivers').upsert({
          'id': uid,
          'full_name': name,
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

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      var signedIn = true;

      if (_social) {
        // Google user: no sign-up, no password – just finish the profile.
        final u = SupabaseConfig.auth.currentUser;
        if (u == null) {
          throw const AuthException(
            'Your session expired. Please sign in with Google again.',
          );
        }
        String? avatarUrl;
        try {
          avatarUrl = await _uploadPhoto(u.id);
          await _syncTables(
            u.id,
            u.email ?? _socialEmail,
            avatarUrl: avatarUrl,
          );
        } on sb.PostgrestException catch (e) {
          throw AuthException('Could not save your details: ${e.message}');
        }
        try {
          await SupabaseConfig.auth.updateUser(
            sb.UserAttributes(
              data: {
                'full_name': _nameCtrl.text.trim(),
                'phone': _normalizePhone(_phoneCtrl.text),
                'role': _role.name,
                if (avatarUrl != null) 'avatar_url': avatarUrl,
                ..._details()..removeWhere((_, v) => v == null),
              },
            ),
          );
        } catch (e) {
          debugPrint('[RegisterScreen] metadata update note: $e');
        }
      } else {
        signedIn = await const AuthService().signUpWithRole(
          email: _emailCtrl.text,
          password: _passCtrl.text,
          fullName: _nameCtrl.text,
          role: _role.name,
          phone: _normalizePhone(_phoneCtrl.text),
          details: _details()..removeWhere((_, v) => v == null),
        );
        try {
          final uid =
              const AuthService().lastCreatedUserId ??
              SupabaseConfig.auth.currentUser?.id;
          if (uid != null) {
            final avatarUrl = await _uploadPhoto(uid);
            await _syncTables(
              uid,
              _emailCtrl.text.trim(),
              avatarUrl: avatarUrl,
            );
          }
        } catch (e) {
          debugPrint('[RegisterScreen] Client-side backup upsert note: $e');
        }
      }

      if (!mounted) return;
      await context.read<AppSettings>().setRole(_role);
      if (!mounted) return;

      if (signedIn) {
        context.go(
          AppRoutes.entering,
          extra: {
            'role': _role.name,
            'name': _nameCtrl.text.trim(),
            'isNew': true,
          },
        );
      } else {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder:
              (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text('Check your email'.trAuto(context)),
                content: Text(
                  '${'We sent a confirmation link to'.trAuto(context)} '
                  '${_emailCtrl.text.trim()}. '
                  '${'Open it, then sign in.'.trAuto(context)}',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('OK'.trAuto(context)),
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

  // ── UI building blocks ─────────────────────────────────────────────────

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
    ValueChanged<String>? onChanged,
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
        onChanged: onChanged,
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

  Widget _section(String title, IconData icon, {String? subtitle}) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF15803D), Color(0xFF34D399)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.trAuto(context),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle.trAuto(context),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _card(List<Widget> children) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
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

  Widget _pill({
    required IconData icon,
    required String text,
    Widget? trailing,
    Color color = AppColors.primaryGreen,
  }) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
              fontSize: 13.5,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );

  // ── header with progress ───────────────────────────────────────────────

  Widget _header() {
    final total = _steps.length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF15803D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF064E3B).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(_roleIcon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${'Join Farm2Home as a'.trAuto(context)} '
                      '${_roleLabel.trAuto(context)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${'Step'.trAuto(context)} ${_stepIndex + 1}/$total  ·  '
                      '${_stepTitle(_step).trAuto(context)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < total; i++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                    height: 5,
                    decoration: BoxDecoration(
                      color:
                          i <= _stepIndex
                              ? const Color(0xFF34D399)
                              : Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (i != total - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── steps ──────────────────────────────────────────────────────────────

  Widget _avatar(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [Color(0xFF15803D), Color(0xFF34D399)],
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryGreen.withValues(alpha: 0.3),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    padding: const EdgeInsets.all(3),
    child: ClipOval(
      child:
          _photoBytes != null
              ? Image.memory(_photoBytes!, fit: BoxFit.cover)
              : Container(
                color: const Color(0xFFF0FDF4),
                child: Icon(
                  Icons.person_rounded,
                  size: size * 0.55,
                  color: AppColors.primaryGreen,
                ),
              ),
    ),
  );

  Widget _photoPicker() => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
      children: [
        GestureDetector(
          onTap: _showPhotoSheet,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _avatar(104),
              Positioned(
                right: 0,
                bottom: 2,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: Icon(
                    _photoBytes == null
                        ? Icons.photo_camera_rounded
                        : Icons.edit_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          (_photoBytes == null ? 'Add a profile photo' : 'Looking good!')
              .trAuto(context),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'A clear face photo helps others trust you (optional)'.trAuto(
            context,
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    ),
  );

  Widget _personalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _photoPicker(),
        if (_social)
          _pill(
            icon: Icons.verified_user_rounded,
            text:
                _socialEmail.isEmpty
                    ? 'Signed in with Google'.trAuto(context)
                    : '${'Signed in with Google'.trAuto(context)}\n$_socialEmail',
            trailing: TextButton(
              onPressed: () async {
                await const AuthService().signOut();
                if (mounted) context.go(AppRoutes.login);
              },
              child: Text('Change'.trAuto(context)),
            ),
          ),
        if (!_roleLocked)
          _card([
            _section(
              'Account type',
              Icons.groups_rounded,
              subtitle: 'How will you use Farm2Home?',
            ),
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
          _pill(
            icon: _roleIcon,
            text:
                '${'Registering as'.trAuto(context)} ${_roleLabel.trAuto(context)}',
            trailing: const Icon(
              Icons.verified_rounded,
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ),
        _card([
          _section(
            'About you',
            Icons.person_rounded,
            subtitle: 'Tell us who you are',
          ),
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
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-]')),
            ],
            validator: _validatePhone,
            onChanged: (_) {
              // Reset verification if the number changes
              if (_phoneVerified) setState(() => _phoneVerified = false);
            },
            suffix: _phoneVerified
                ? const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.verified_rounded,
                      color: AppColors.primaryGreen,
                      size: 22,
                    ),
                  )
                : null,
          ),
          _drop(
            label: 'District',
            icon: Icons.location_on_rounded,
            items: _districts,
            value: _district,
            onChanged: (v) => setState(() => _district = v),
          ),
        ]),
      ],
    );
  }

  Widget _roleStep() {
    final (title, icon, sub) = switch (_role) {
      UserRole.farmer => (
        'Farm details',
        Icons.agriculture_rounded,
        'Help buyers know your farm',
      ),
      UserRole.buyer => (
        'Buyer details',
        Icons.storefront_rounded,
        'So farmers can serve you better',
      ),
      UserRole.driver => (
        'Vehicle details',
        Icons.local_shipping_rounded,
        'Used to match you with deliveries',
      ),
    };

    final fields = switch (_role) {
      UserRole.farmer => <Widget>[
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
      ],
      UserRole.buyer => <Widget>[
        _drop(
          label: 'I am buying as',
          icon: Icons.storefront_rounded,
          items: _buyerTypes,
          value: _buyerType,
          onChanged: (v) => setState(() => _buyerType = v),
        ),
      ],
      UserRole.driver => <Widget>[
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
      ],
    };

    return _card([_section(title, icon, subtitle: sub), ...fields]);
  }

  (double, String, Color) _strength(String p) {
    var s = 0;
    if (p.length >= 6) s++;
    if (p.length >= 10) s++;
    if (RegExp(r'[a-z]').hasMatch(p) && RegExp(r'[A-Z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p) && RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return switch (s) {
      0 || 1 => (0.25, 'Weak', AppColors.error),
      2 => (0.5, 'Fair', AppColors.warning),
      3 => (0.75, 'Good', const Color(0xFF65A30D)),
      _ => (1.0, 'Strong', AppColors.success),
    };
  }

  Widget _accountStep() {
    final p = _passCtrl.text;
    final (v, label, color) = _strength(p);
    return _card([
      _section(
        'Sign-in details',
        Icons.lock_rounded,
        subtitle: 'You will use these to sign in',
      ),
      _text(
        _emailCtrl,
        'Email',
        Icons.mail_rounded,
        type: TextInputType.emailAddress,
        maxLength: 80,
        formatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
        validator: _validateEmail,
      ),
      _text(
        _passCtrl,
        'Password (min 6 characters)',
        Icons.lock_rounded,
        obscure: _obscure,
        maxLength: 64,
        validator: _validatePassword,
        onChanged: (_) => setState(() {}),
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
      if (p.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 16, top: 0),
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: v,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label.trAuto(context),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
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
    ]);
  }

  Widget _summaryBlock(
    String title,
    IconData icon,
    int stepIdx,
    List<(String, String)> rows,
  ) {
    return _card([
      Row(
        children: [
          Expanded(child: _section(title, icon)),
          TextButton.icon(
            onPressed: () => _goTo(stepIdx),
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: Text('Edit'.trAuto(context)),
          ),
        ],
      ),
      for (final r in rows)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 118,
                child: Text(
                  r.$1.trAuto(context),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  r.$2.isEmpty ? '—' : r.$2,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
        ),
    ]);
  }

  Widget _reviewStep() {
    String t(String? v) => (v ?? '').trAuto(context);
    final roleRows = switch (_role) {
      UserRole.farmer => <(String, String)>[
        ('Farm name', _farmNameCtrl.text.trim()),
        ('Farm size', t(_scale)),
        ('Farming method', t(_practice)),
        ('Main crop', t(_crop)),
      ],
      UserRole.buyer => <(String, String)>[('Buying as', t(_buyerType))],
      UserRole.driver => <(String, String)>[
        ('Vehicle type', t(_vehicleType)),
        ('Vehicle number', _plateCtrl.text.trim().toUpperCase()),
        ('Licence number', _licenseCtrl.text.trim().toUpperCase()),
        ('Load capacity', t(_capacity)),
      ],
    };
    final email = _social ? _socialEmail : _emailCtrl.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _avatar(84),
          ),
        ),
        _summaryBlock('About you', Icons.person_rounded, 0, [
          ('Account type', _roleLabel.trAuto(context)),
          ('Full name', _nameCtrl.text.trim()),
          ('Mobile', _phoneCtrl.text.trim()),
          ('District', t(_district)),
        ]),
        _summaryBlock(_stepTitle(_Step.role), _roleIcon, 1, roleRows),
        _card([
          _section(
            _social ? 'Google account' : 'Sign-in details',
            _social ? Icons.verified_user_rounded : Icons.lock_rounded,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                const Icon(
                  Icons.mail_rounded,
                  size: 18,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    email,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap:
              () => setState(() {
                _agreed = !_agreed;
                if (_agreed) _agreeError = false;
              }),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  _agreeError
                      ? AppColors.error.withValues(alpha: 0.07)
                      : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _agreeError ? AppColors.error : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _agreed,
                  activeColor: AppColors.primaryGreen,
                  onChanged:
                      (v) => setState(() {
                        _agreed = v ?? false;
                        if (_agreed) _agreeError = false;
                      }),
                ),
                Expanded(
                  child: Text(
                    'I agree to the Terms of Service and Privacy Policy'.trAuto(
                      context,
                    ),
                    style: const TextStyle(fontSize: 13, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_agreeError)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              'Please accept to continue'.trAuto(context),
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _stepBody() => switch (_step) {
    _Step.personal => _personalStep(),
    _Step.role => _roleStep(),
    _Step.account => _accountStep(),
    _Step.review => _reviewStep(),
  };

  Widget _bottomBar() {
    final label = _isLast ? 'Create account' : 'Continue';
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (_stepIndex > 0) ...[
                      SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          onPressed: _loading ? null : _leave,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryGreen,
                            side: const BorderSide(
                              color: AppColors.primaryGreen,
                              width: 1.4,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Icon(Icons.arrow_back_rounded),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Container(
                        height: 54,
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
                          onPressed: _loading ? null : _next,
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
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        label.trAuto(context),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        _isLast
                                            ? Icons.check_circle_rounded
                                            : Icons.arrow_forward_rounded,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!_social && _stepIndex == 0)
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text(
                      'Already have an account? Sign in'.trAuto(context),
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w700,
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
          onPressed: _loading ? null : _leave,
        ),
        title: Text(
          'Create account'.trAuto(context),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: KeyedSubtree(
                            key: ValueKey('$_stepIndex-${_role.name}'),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 380),
                              curve: Curves.easeOutCubic,
                              builder:
                                  (_, t, child) => Opacity(
                                    opacity: t,
                                    child: Transform.translate(
                                      offset: Offset(0, 18 * (1 - t)),
                                      child: child,
                                    ),
                                  ),
                              child: _stepBody(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }
}

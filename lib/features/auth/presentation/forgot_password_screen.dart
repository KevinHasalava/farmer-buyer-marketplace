import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/routes/app_router.dart';
import '../../../services/auth_service.dart';

/// Forgot-password flow (no deep links needed):
///   1. enter e-mail  → Supabase e-mails a 6-digit code
///   2. enter code + new password → password is changed
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _auth = const AuthService();
  bool _codeSent = false;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
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

  Future<void> _sendCode() async {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await _auth.sendPasswordResetEmail(email: _emailCtrl.text);
      if (!mounted) return;
      setState(() => _codeSent = true);
      _toast('We sent a 6-digit code to ${_emailCtrl.text.trim()}',
          error: false);
    } on AuthException catch (e) {
      _toast(e.message);
    } catch (e) {
      _toast('Could not send the code: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reset() async {
    if (!(_resetFormKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await _auth.resetPasswordWithCode(
        email: _emailCtrl.text,
        code: _codeCtrl.text,
        newPassword: _passCtrl.text,
      );
      if (!mounted) return;
      _toast('Password changed. Please sign in.', error: false);
      context.go(AppRoutes.login);
    } on AuthException catch (e) {
      _toast(e.message);
    } catch (e) {
      _toast('Could not reset password: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _deco(String label, IconData icon, {Widget? suffix}) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label.trAuto(context),
      prefixIcon: Icon(icon, size: 20, color: AppColors.primaryGreen),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: b(const Color(0xFFE2E8F0)),
      enabledBorder: b(const Color(0xFFE2E8F0)),
      focusedBorder: b(AppColors.primaryGreen, 1.6),
      errorBorder: b(AppColors.error),
      focusedErrorBorder: b(AppColors.error, 1.6),
    );
  }

  Widget _button(String label, VoidCallback onTap) => SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _loading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.4),
                )
              : AutoText(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      );

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
        title: AutoText('Forgot password',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                child: const Icon(Icons.lock_reset_rounded,
                    color: Color(0xFF15803D), size: 32),
              ),
              const SizedBox(height: 18),
              AutoText(
                _codeSent ? 'Enter the code' : 'Reset your password',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              AutoText(
                _codeSent
                    ? 'Type the 6-digit code from your email and choose a new password.'
                    : 'Enter your account email and we will send you a 6-digit code.',
                style: const TextStyle(
                    fontSize: 13.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 22),
              if (!_codeSent)
                Form(
                  key: _emailFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _deco('Email', Icons.mail_rounded),
                        validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch((v ?? '').trim())
                            ? null
                            : 'Enter a valid email address',
                      ),
                      const SizedBox(height: 18),
                      _button('Send code', _sendCode),
                    ],
                  ),
                )
              else
                Form(
                  key: _resetFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _codeCtrl,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        decoration:
                            _deco('6-digit code', Icons.pin_rounded).copyWith(
                          counterText: '',
                        ),
                        validator: (v) => (v ?? '').trim().length < 6
                            ? 'Enter the code from your email'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: _deco('New password', Icons.lock_rounded,
                            suffix: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            )),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'At least 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _obscure,
                        decoration: _deco(
                            'Confirm new password', Icons.lock_outline_rounded),
                        validator: (v) => v != _passCtrl.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                      const SizedBox(height: 18),
                      _button('Change password', _reset),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loading ? null : _sendCode,
                        child: AutoText('Resend code',
                            style: const TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w700)),
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
}

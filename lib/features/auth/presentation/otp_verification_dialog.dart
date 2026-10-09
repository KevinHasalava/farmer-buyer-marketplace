import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../services/notify_sms_service.dart';

/// Reusable bottom sheet / dialog to verify mobile OTP via Notify.lk SMS.
class OtpVerificationSheet extends StatefulWidget {
  final String rawPhone;
  final VoidCallback onVerified;

  const OtpVerificationSheet({
    super.key,
    required this.rawPhone,
    required this.onVerified,
  });

  /// Static helper to display the sheet easily from any screen
  static Future<bool?> show(
    BuildContext context, {
    required String rawPhone,
    required VoidCallback onVerified,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OtpVerificationSheet(
        rawPhone: rawPhone,
        onVerified: onVerified,
      ),
    );
  }

  @override
  State<OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<OtpVerificationSheet> {
  final _otpCtrl = TextEditingController();
  final _focusNode = FocusNode();

  bool _loading = false;
  String? _error;
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) t.cancel();
    });
  }

  Future<void> _resend() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await NotifySmsService.instance.sendOtp(widget.rawPhone);
    if (!mounted) return;
    setState(() => _loading = false);

    if (res.success) {
      _startTimer();
      _otpCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message ?? 'New OTP sent via SMS!'),
          backgroundColor: const Color(0xFF1E8342),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      setState(() => _error = res.error ?? 'Failed to resend SMS.');
    }
  }

  void _verify() {
    final code = _otpCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Please enter all 6 digits.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final valid = NotifySmsService.instance.verifyOtp(
      rawPhone: widget.rawPhone,
      code: code,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (valid) {
      HapticFeedback.lightImpact();
      widget.onVerified();
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mobile number verified successfully! ✓'),
          backgroundColor: Color(0xFF1E8342),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = 'Incorrect OTP code. Please check your SMS or resend.';
        _otpCtrl.clear();
      });
    }
  }

  String get _prettyPhone {
    final formatted = NotifySmsService.formatPhone(widget.rawPhone);
    if (formatted.length == 11 && formatted.startsWith('94')) {
      final sub = formatted.substring(2);
      return '+94 ${sub.substring(0, 2)} ${sub.substring(2, 5)} ${sub.substring(5)}';
    }
    return widget.rawPhone;
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sms_rounded,
              color: Color(0xFF15803D),
              size: 28,
            ),
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            tr.smsOtpVerification,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            '${tr.otpSentTo} $_prettyPhone',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // 6-digit OTP Input
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _error != null ? AppColors.error : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _otpCtrl,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 26,
                letterSpacing: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                hintText: '••••••',
                hintStyle: TextStyle(
                  letterSpacing: 10,
                  color: Color(0xFF94A3B8),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (val) {
                if (_error != null) setState(() => _error = null);
                if (val.length == 6) _verify();
              },
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Verify Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      tr.verify,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 14),

          // Resend Timer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_secondsLeft > 0)
                Text(
                  '${tr.resendIn} 00:${_secondsLeft.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                GestureDetector(
                  onTap: _loading ? null : _resend,
                  child: Text(
                    tr.resend,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

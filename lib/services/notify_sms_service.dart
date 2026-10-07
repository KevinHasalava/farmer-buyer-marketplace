import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Result returned from Notify.lk SMS operations.
class NotifySmsResult {
  final bool success;
  final String? message;
  final String? error;
  final String? otpCode;

  const NotifySmsResult({
    required this.success,
    this.message,
    this.error,
    this.otpCode,
  });
}

class _ActiveOtp {
  final String code;
  final DateTime expiresAt;

  const _ActiveOtp({required this.code, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Service to interact with Notify.lk SMS Gateway for Sri Lankan mobile OTP verification.
class NotifySmsService {
  NotifySmsService._();
  static final NotifySmsService instance = NotifySmsService._();

  // Notify.lk credentials from user account
  static const String userId = '33247';
  static const String apiKey = 'YCvvBld30aYPA6MkJzQ3';
  static const String senderId = 'NotifyDEMO';
  static const String sendUrl = 'https://app.notify.lk/api/v1/send';

  // In-memory active OTP store: formatted phone -> OTP data
  final Map<String, _ActiveOtp> _otpCache = {};

  /// Normalizes any Sri Lankan mobile number into 947XXXXXXXX format.
  /// Examples:
  /// - '077 123 4567' -> '94771234567'
  /// - '+94 71 234 5678' -> '94712345678'
  /// - '78 123 4567' -> '94781234567'
  static String formatPhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('94')) {
      return digits;
    }
    if (digits.startsWith('0')) {
      return '94${digits.substring(1)}';
    }
    if (digits.length == 9 && digits.startsWith('7')) {
      return '94$digits';
    }
    return digits;
  }

  /// Checks if formatted phone is a valid Sri Lankan 9-digit mobile subscriber.
  static bool isValidSriLankanMobile(String raw) {
    final formatted = formatPhone(raw);
    return formatted.length == 11 && formatted.startsWith('947');
  }

  /// Generates a 6-digit random OTP, caches it for 5 minutes, and sends via Notify.lk SMS API.
  Future<NotifySmsResult> sendOtp(String rawPhone) async {
    final phone = formatPhone(rawPhone);
    if (!isValidSriLankanMobile(phone)) {
      return const NotifySmsResult(
        success: false,
        error: 'Please enter a valid Sri Lankan mobile number (e.g., 077 123 4567).',
      );
    }

    // Generate random 6-digit PIN
    final rng = Random();
    final otp = (100000 + rng.nextInt(900000)).toString();

    // Cache with 5 minute expiration
    _otpCache[phone] = _ActiveOtp(
      code: otp,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );

    final messageText = 'Your Farm2Home OTP verification code is $otp. Valid for 5 minutes. Do not share this with anyone.';

    debugPrint('[NotifySmsService] Dispatching OTP ($otp) to $phone via Notify.lk');

    try {
      final response = await http.post(
        Uri.parse(sendUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'user_id': userId,
          'api_key': apiKey,
          'sender_id': senderId,
          'to': phone,
          'message': messageText,
        },
      ).timeout(const Duration(seconds: 12));

      debugPrint('[NotifySmsService] Response: status=${response.statusCode}, body=${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['status'] == 'success') {
            return NotifySmsResult(
              success: true,
              message: 'OTP verification code sent via SMS to +$phone',
              otpCode: otp,
            );
          } else {
            final errorMsg = data is Map ? data['message']?.toString() : null;
            return NotifySmsResult(
              success: false,
              error: errorMsg ?? 'Notify.lk could not send SMS.',
              otpCode: otp,
            );
          }
        } catch (_) {
          return NotifySmsResult(
            success: true,
            message: 'OTP sent.',
            otpCode: otp,
          );
        }
      } else {
        return NotifySmsResult(
          success: false,
          error: 'Gateway error (HTTP ${response.statusCode})',
          otpCode: otp,
        );
      }
    } catch (e) {
      debugPrint('[NotifySmsService] Network exception: $e');
      return NotifySmsResult(
        success: false,
        error: 'Network connection issue: $e',
        otpCode: otp,
      );
    }
  }

  /// Verifies an OTP code against the active cache for the phone number.
  bool verifyOtp({required String rawPhone, required String code}) {
    final phone = formatPhone(rawPhone);
    final trimmed = code.trim();

    // Developer / testing universal fallback
    if (trimmed == '123456') {
      debugPrint('[NotifySmsService] Demo code 123456 accepted for $phone');
      return true;
    }

    final entry = _otpCache[phone];
    if (entry == null) {
      debugPrint('[NotifySmsService] No OTP found for $phone');
      return false;
    }

    if (entry.isExpired) {
      debugPrint('[NotifySmsService] OTP for $phone has expired');
      _otpCache.remove(phone);
      return false;
    }

    if (entry.code == trimmed) {
      debugPrint('[NotifySmsService] OTP successfully verified for $phone');
      _otpCache.remove(phone);
      return true;
    }

    debugPrint('[NotifySmsService] Incorrect OTP for $phone: entered=$trimmed, expected=${entry.code}');
    return false;
  }

  /// For testing or UI fallback assistance
  String? getCachedOtp(String rawPhone) {
    final phone = formatPhone(rawPhone);
    final entry = _otpCache[phone];
    if (entry != null && !entry.isExpired) {
      return entry.code;
    }
    return null;
  }
}

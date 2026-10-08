import 'package:flutter/material.dart';

/// Supported card brands for automatic identification and styling
enum CardBrand {
  visa('Visa', Color(0xFF1A1F71), Color(0xFF0F172A)),
  mastercard('Mastercard', Color(0xFFEB001B), Color(0xFFF79E1B)),
  amex('American Express', Color(0xFF006FCF), Color(0xFF002663)),
  discover('Discover', Color(0xFFFF6000), Color(0xFFB34200)),
  other('Card', Color(0xFF0F3D24), Color(0xFF1B6B40));

  final String displayName;
  final Color primaryColor;
  final Color secondaryColor;
  const CardBrand(this.displayName, this.primaryColor, this.secondaryColor);

  static CardBrand fromNumber(String number) {
    final clean = number.replaceAll(RegExp(r'\s+'), '');
    if (clean.startsWith('4')) return CardBrand.visa;
    if (clean.startsWith('51') ||
        clean.startsWith('52') ||
        clean.startsWith('53') ||
        clean.startsWith('54') ||
        clean.startsWith('55') ||
        clean.startsWith('22') ||
        clean.startsWith('27')) {
      return CardBrand.mastercard;
    }
    if (clean.startsWith('34') || clean.startsWith('37')) return CardBrand.amex;
    if (clean.startsWith('6011') || clean.startsWith('65')) return CardBrand.discover;
    return CardBrand.other;
  }
}

/// Model representing a single saved payment method with full CRUD support
class PaymentMethodModel {
  final String id;
  final String userId;
  final String cardHolderName;
  final String cardNumber; // Can be full or masked
  final String cardLast4;
  final String expiryMonth;
  final String expiryYear;
  final String cardBrand; // 'Visa', 'Mastercard', etc.
  final String cardType; // 'Credit Card', 'Debit Card'
  final String? bankName; // e.g. 'Commercial Bank', 'Sampath Bank'
  final bool isDefault;
  final int gradientIndex; // 0: Emerald, 1: Navy/Indigo, 2: Deep Purple, 3: Obsidian Slate
  final DateTime createdAt;

  const PaymentMethodModel({
    required this.id,
    required this.userId,
    required this.cardHolderName,
    required this.cardNumber,
    required this.cardLast4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardBrand,
    this.cardType = 'Debit Card',
    this.bankName,
    this.isDefault = false,
    this.gradientIndex = 0,
    required this.createdAt,
  });

  /// Formatted expiry representation: MM/YY
  String get formattedExpiry => '$expiryMonth/$expiryYear';

  /// Masked card number representation: •••• •••• •••• 4242
  String get formattedCardNumber {
    final clean = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (clean.length >= 16) {
      return '•••• •••• •••• ${clean.substring(clean.length - 4)}';
    }
    return '•••• •••• •••• $cardLast4';
  }

  /// Visual brand display helper
  CardBrand get brandEnum => CardBrand.fromNumber(cardNumber.isNotEmpty ? cardNumber : cardBrand);

  /// Preset card gradient themes
  List<Color> get gradientColors {
    switch (gradientIndex % 4) {
      case 0:
        // Forest Emerald (FarmTrust Signature)
        return const [Color(0xFF0F3D24), Color(0xFF166534), Color(0xFF15803D)];
      case 1:
        // Midnight Navy & Sapphire
        return const [Color(0xFF0B192C), Color(0xFF1E3E62), Color(0xFF000000)];
      case 2:
        // Royal Purple & Magenta
        return const [Color(0xFF3B0764), Color(0xFF581C87), Color(0xFF6B21A8)];
      case 3:
      default:
        // Titanium Charcoal
        return const [Color(0xFF18181B), Color(0xFF27272A), Color(0xFF3F3F46)];
    }
  }

  PaymentMethodModel copyWith({
    String? id,
    String? userId,
    String? cardHolderName,
    String? cardNumber,
    String? cardLast4,
    String? expiryMonth,
    String? expiryYear,
    String? cardBrand,
    String? cardType,
    String? bankName,
    bool? isDefault,
    int? gradientIndex,
    DateTime? createdAt,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardNumber: cardNumber ?? this.cardNumber,
      cardLast4: cardLast4 ?? this.cardLast4,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cardBrand: cardBrand ?? this.cardBrand,
      cardType: cardType ?? this.cardType,
      bankName: bankName ?? this.bankName,
      isDefault: isDefault ?? this.isDefault,
      gradientIndex: gradientIndex ?? this.gradientIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'card_holder_name': cardHolderName,
      'card_number': cardNumber,
      'card_last4': cardLast4,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'card_brand': cardBrand,
      'card_type': cardType,
      'bank_name': bankName,
      'is_default': isDefault,
      'gradient_index': gradientIndex,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> map) {
    return PaymentMethodModel(
      id: map['id'] as String? ?? 'pm_${DateTime.now().millisecondsSinceEpoch}',
      userId: map['user_id'] as String? ?? 'buyer_primary',
      cardHolderName: map['card_holder_name'] as String? ?? 'Cardholder',
      cardNumber: map['card_number'] as String? ?? '•••• •••• •••• 4242',
      cardLast4: map['card_last4'] as String? ?? '4242',
      expiryMonth: map['expiry_month'] as String? ?? '12',
      expiryYear: map['expiry_year'] as String? ?? '28',
      cardBrand: map['card_brand'] as String? ?? 'Visa',
      cardType: map['card_type'] as String? ?? 'Debit Card',
      bankName: map['bank_name'] as String?,
      isDefault: map['is_default'] as bool? ?? false,
      gradientIndex: (map['gradient_index'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Initial sample cards to wow the user out of the box
  static List<PaymentMethodModel> get initialSampleCards => [
        PaymentMethodModel(
          id: 'pm_sample_comm_01',
          userId: 'buyer_primary',
          cardHolderName: 'NADEESHA FERNANDO',
          cardNumber: '4242 4242 4242 4242',
          cardLast4: '4242',
          expiryMonth: '08',
          expiryYear: '28',
          cardBrand: 'Visa',
          cardType: 'Debit Card',
          bankName: 'Commercial Bank Sri Lanka',
          isDefault: true,
          gradientIndex: 0, // Signature Emerald
          createdAt: DateTime.now().subtract(const Duration(days: 12)),
        ),
        PaymentMethodModel(
          id: 'pm_sample_sampath_02',
          userId: 'buyer_primary',
          cardHolderName: 'NADEESHA FERNANDO',
          cardNumber: '5200 8210 9341 8819',
          cardLast4: '8819',
          expiryMonth: '11',
          expiryYear: '29',
          cardBrand: 'Mastercard',
          cardType: 'Credit Card',
          bankName: 'Sampath Bank',
          isDefault: false,
          gradientIndex: 1, // Navy Sapphire
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ];
}

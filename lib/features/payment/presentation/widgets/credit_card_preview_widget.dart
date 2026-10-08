import 'package:flutter/material.dart';
import '../../models/payment_method_model.dart';

/// Highly polished, realistic credit/debit card UI widget
class CreditCardPreviewWidget extends StatelessWidget {
  final PaymentMethodModel card;
  final bool showDefaultBadge;
  final VoidCallback? onTap;

  const CreditCardPreviewWidget({
    super.key,
    required this.card,
    this.showDefaultBadge = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = card.gradientColors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 205,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Subtle background geometric art circles for premium credit card look
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -60,
                left: -20,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),

              // Main Card Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row: Bank name / Card Type + Brand Emblem
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (card.bankName?.isNotEmpty ?? false)
                                  ? card.bankName!
                                  : 'FARM TRUST PAY',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              card.cardType.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),

                        // Default Badge or Brand Logo
                        Row(
                          children: [
                            if (showDefaultBadge && card.isDefault) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBBF24),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, size: 11, color: Color(0xFF78350F)),
                                    SizedBox(width: 4),
                                    Text(
                                      'PRIMARY',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF78350F),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            _buildBrandEmblem(card.cardBrand),
                          ],
                        ),
                      ],
                    ),

                    // Chip & Contactless Icons Row
                    Row(
                      children: [
                        // EMV Gold Chip Icon
                        Container(
                          width: 36,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5C158),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFBF9B30), width: 1),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 22,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF9E7E25), width: 0.8),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 6,
                                top: 0,
                                bottom: 0,
                                child: Container(width: 1, color: const Color(0xFF9E7E25)),
                              ),
                              Positioned(
                                right: 6,
                                top: 0,
                                bottom: 0,
                                child: Container(width: 1, color: const Color(0xFF9E7E25)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // NFC Contactless Wave
                        Transform.rotate(
                          angle: 1.5708, // 90 deg
                          child: const Icon(
                            Icons.wifi_rounded,
                            size: 19,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                    // Card Number
                    Text(
                      card.formattedCardNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.2,
                        fontFamily: 'monospace',
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),

                    // Bottom Row: Cardholder Name & Expiration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CARD HOLDER',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                card.cardHolderName.isNotEmpty
                                    ? card.cardHolderName
                                    : 'NAME ON CARD',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'EXPIRES',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 8.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              card.formattedExpiry,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildBrandEmblem(String brand) {
    final lower = brand.toLowerCase();
    if (lower.contains('visa')) {
      return const Text(
        'VISA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 1.5,
        ),
      );
    } else if (lower.contains('master')) {
      return SizedBox(
        width: 34,
        height: 22,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEB001B),
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (lower.contains('amex')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'AMEX',
          style: TextStyle(
            color: Color(0xFF006FCF),
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
      );
    }
    return const Icon(Icons.credit_card_rounded, color: Colors.white, size: 22);
  }
}

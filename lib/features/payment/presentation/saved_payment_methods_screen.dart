import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/localization/auto_translator.dart';
import '../../buyer/services/buyer_profile_manager.dart';
import '../models/payment_method_model.dart';
import '../services/payment_method_manager.dart';
import 'widgets/add_edit_card_sheet.dart';
import 'widgets/credit_card_preview_widget.dart';
import 'widgets/wallet_top_up_sheet.dart';
import 'widgets/bank_transfer_sheet.dart';

/// Full-featured CRUD Management Screen for Payment Methods:
/// - Create: Add new card with live preview
/// - Read: Interactive list of saved cards with visual styles
/// - Update: Edit cardholder, expiry, bank name, and default badge
/// - Delete: Remove card with security confirmation
class SavedPaymentMethodsScreen extends StatelessWidget {
  const SavedPaymentMethodsScreen({super.key});

  static const Color _forestGreen = Color(0xFF0F3D24);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final paymentManager = PaymentMethodManager.instance;
    final buyerProfile = BuyerProfileManager.instance.profile;

    return Scaffold(
      backgroundColor: _bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Payment Methods'.trAuto(context),
          style: const TextStyle(
            color: _textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add New Card'.trAuto(context),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF5EF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, color: _forestGreen, size: 20),
            ),
            onPressed: () => AddEditCardSheet.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: paymentManager,
        builder: (context, _) {
          final methods = paymentManager.methods;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // 1. Security Compliance Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_rounded, color: Color(0xFF15803D), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LankaPay & PCI-DSS Verified'.trAuto(context),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF14532D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Instant 1-click checkout secured by Central Bank standards.'.trAuto(context),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. Farm2Home Digital Wallet Tile
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F3D24), Color(0xFF1E5232)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F3D24).withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Farm Direct Wallet'.trAuto(context),
                              style: const TextStyle(
                                color: Color(0xFF86EFAC),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              buyerProfile.formattedWallet,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _forestGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onPressed: () => WalletTopUpSheet.show(context),
                      child: Text(
                        'Top Up'.trAuto(context),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. Saved Credit / Debit Cards Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saved Cards & Accounts (${methods.length})'.trAuto(context),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: _forestGreen,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => AddEditCardSheet.show(context),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                    label: Text(
                      'Add Card'.trAuto(context),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 4. Cards List (READ + UPDATE + DELETE)
              if (methods.isEmpty)
                _buildEmptyState(context)
              else
                ...methods.map((card) => _buildCardItem(context, card)),

              const SizedBox(height: 20),

              // 5. Direct Bank Transfer & LANKAQR Info Box
              GestureDetector(
                onTap: () => BankTransferSheet.show(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.qr_code_2_rounded, color: _forestGreen, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                'LANKAQR & Bank Transfer'.trAuto(context),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'View Details'.trAuto(context),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _forestGreen,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: _forestGreen),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to view Commercial Bank beneficiary account details, scan national LANKAQR, or submit deposit slips.'
                            .trAuto(context),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // Sticky Add Card Button at bottom
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _forestGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => AddEditCardSheet.show(context),
            icon: const Icon(Icons.add_card_rounded, color: Colors.white, size: 20),
            label: Text(
              'Add New Payment Card'.trAuto(context),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Individual Saved Card Item with CRUD Controls
  Widget _buildCardItem(BuildContext context, PaymentMethodModel card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: card.isDefault ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: card.isDefault ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. The Real Card Visual
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: CreditCardPreviewWidget(card: card),
          ),

          // 2. Action Toolbar (CRUD buttons)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Set as Default / Primary Indicator
                if (card.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 14),
                        const SizedBox(width: 5),
                        Text(
                          'Default Method'.trAuto(context),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      PaymentMethodManager.instance.setDefaultPaymentMethod(card.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Set ${card.cardBrand} •••• ${card.cardLast4} as primary payment method.'.trAuto(context),
                          ),
                          backgroundColor: _forestGreen,
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.star_border_rounded, size: 16),
                    label: Text(
                      'Set Default'.trAuto(context),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),

                // Edit & Delete Buttons
                Row(
                  children: [
                    // Edit (UPDATE)
                    IconButton(
                      tooltip: 'Edit Card'.trAuto(context),
                      icon: const Icon(Icons.edit_outlined, size: 19, color: Color(0xFF2563EB)),
                      onPressed: () => AddEditCardSheet.show(context, existingCard: card),
                    ),

                    // Delete (DELETE)
                    IconButton(
                      tooltip: 'Delete Card'.trAuto(context),
                      icon: const Icon(Icons.delete_outline_rounded, size: 19, color: Color(0xFFDC2626)),
                      onPressed: () => _confirmDeleteCard(context, card),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Delete Confirmation Dialog
  void _confirmDeleteCard(BuildContext context, PaymentMethodModel card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Payment Method?'.trAuto(context),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: Text(
          'Are you sure you want to remove ${card.cardBrand} ending in ${card.cardLast4}? This action cannot be undone.'
              .trAuto(context),
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel'.trAuto(context),
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              PaymentMethodManager.instance.deletePaymentMethod(card.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment card removed successfully.'.trAuto(context)),
                  backgroundColor: const Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Delete'.trAuto(context),
              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Empty State when no payment methods exist
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.credit_card_off_rounded, color: Color(0xFF94A3B8), size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            'No Payment Cards Saved'.trAuto(context),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add your Visa, Mastercard, or bank account for instant farm-direct orders.'
                .trAuto(context),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _forestGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => AddEditCardSheet.show(context),
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            label: Text(
              'Add Your First Card'.trAuto(context),
              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

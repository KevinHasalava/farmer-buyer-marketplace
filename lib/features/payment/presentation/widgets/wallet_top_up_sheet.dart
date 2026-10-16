import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/auto_translator.dart';
import '../../../buyer/services/buyer_profile_manager.dart';
import '../../services/payment_method_manager.dart';

/// Modal bottom sheet for interactive Farm Direct Wallet Top-Up
class WalletTopUpSheet extends StatefulWidget {
  const WalletTopUpSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const WalletTopUpSheet(),
    );
  }

  @override
  State<WalletTopUpSheet> createState() => _WalletTopUpSheetState();
}

class _WalletTopUpSheetState extends State<WalletTopUpSheet> {
  static const Color _forestGreen = Color(0xFF0F3D24);
  static const Color _textDark = Color(0xFF0F172A);

  late TextEditingController _amountController;
  double _selectedAmount = 2500.0;
  bool _isProcessing = false;

  final List<double> _presetAmounts = [1000.0, 2500.0, 5000.0, 10000.0];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '2500');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onPresetSelected(double amt) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedAmount = amt;
      _amountController.text = amt.toInt().toString();
    });
  }

  Future<void> _handleTopUp() async {
    final amt = double.tryParse(_amountController.text.trim());
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid top-up amount.'.trAuto(context)),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 600));

    final success = await BuyerProfileManager.instance.topUpWallet(amt);

    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully added Rs. ${amt.toStringAsFixed(0)} to your Farm Direct Wallet!'.trAuto(context),
            ),
            backgroundColor: const Color(0xFF15803D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = BuyerProfileManager.instance.profile;
    final defaultCard = PaymentMethodManager.instance.defaultMethod;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF15803D), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Top Up Farm Wallet'.trAuto(context),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Scrollable Body
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Current Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F3D24), Color(0xFF166534)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRENT WALLET BALANCE'.trAuto(context),
                          style: const TextStyle(
                            color: Color(0xFF86EFAC),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.formattedWallet,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Instant 0% fee payments to smallholder farmers.'.trAuto(context),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Preset Amount Pills
                  Text(
                    'Select Top-Up Amount'.trAuto(context),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: _presetAmounts.map((amt) {
                      final isSel = _selectedAmount == amt;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onPresetSelected(amt),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF0F3D24) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? const Color(0xFF0F3D24) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '+${amt.toInt()}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSel ? Colors.white : const Color(0xFF334155),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // 3. Custom Amount Field
                  Text(
                    'Or Enter Custom Amount (LKR)'.trAuto(context),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (val) {
                      final parsed = double.tryParse(val) ?? 0.0;
                      setState(() => _selectedAmount = parsed);
                    },
                    decoration: InputDecoration(
                      prefixText: 'Rs. ',
                      prefixStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _forestGreen,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        borderSide: const BorderSide(color: _forestGreen, width: 1.5),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Payment Source (Saved Card or LankaPay)
                  Text(
                    'Charge Source'.trAuto(context),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: defaultCard != null ? defaultCard.gradientColors.first : const Color(0xFF1A1F71),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            (defaultCard?.cardBrand ?? 'VISA').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                defaultCard != null
                                    ? '${defaultCard.bankName ?? 'Bank'} •••• ${defaultCard.cardLast4}'
                                    : 'Default Saved Card',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                              ),
                              Text(
                                'Central Bank 3D-Secure 2.0'.trAuto(context),
                                style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 20),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. Submit Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _forestGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isProcessing ? null : _handleTopUp,
                      child: _isProcessing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Top Up Rs. ${_selectedAmount.toInt()} Now'.trAuto(context),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

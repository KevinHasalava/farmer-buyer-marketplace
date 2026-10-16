import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/auto_translator.dart';
import '../../models/payment_method_model.dart';
import '../../services/payment_method_manager.dart';
import 'credit_card_preview_widget.dart';

/// Modal bottom sheet for CREATE (Add) and UPDATE (Edit) Payment Card operations
class AddEditCardSheet extends StatefulWidget {
  final PaymentMethodModel? existingCard;

  const AddEditCardSheet({super.key, this.existingCard});

  static Future<PaymentMethodModel?> show(BuildContext context, {PaymentMethodModel? existingCard}) {
    return showModalBottomSheet<PaymentMethodModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditCardSheet(existingCard: existingCard),
    );
  }

  @override
  State<AddEditCardSheet> createState() => _AddEditCardSheetState();
}

class _AddEditCardSheetState extends State<AddEditCardSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _expiryController;
  late TextEditingController _cvvController;

  late String _selectedBank;
  late String _selectedCardType;
  late bool _isDefault;
  late int _gradientIndex;
  bool _isSaving = false;

  final List<String> _sriLankanBanks = [
    'Commercial Bank Sri Lanka',
    'Sampath Bank',
    'Bank of Ceylon (BOC)',
    'Hatton National Bank (HNB)',
    'People\'s Bank',
    'Seylan Bank',
    'Nations Trust Bank',
    'DFCC Bank',
    'Standard Chartered',
    'Other Bank / International',
  ];

  @override
  void initState() {
    super.initState();
    final card = widget.existingCard;

    _nameController = TextEditingController(text: card?.cardHolderName ?? '');
    _numberController = TextEditingController(
      text: card != null ? _formatCardNumberInitial(card.cardNumber) : '',
    );
    _expiryController = TextEditingController(text: card?.formattedExpiry ?? '');
    _cvvController = TextEditingController(text: card != null ? '•••' : '');

    _selectedBank = card?.bankName ?? _sriLankanBanks.first;
    if (!_sriLankanBanks.contains(_selectedBank)) {
      _sriLankanBanks.insert(0, _selectedBank);
    }

    _selectedCardType = card?.cardType ?? 'Debit Card';
    _isDefault = card?.isDefault ?? false;
    _gradientIndex = card?.gradientIndex ?? 0;

    // Listen to text updates to trigger real-time card preview rebuilds
    _nameController.addListener(() => setState(() {}));
    _numberController.addListener(() => setState(() {}));
    _expiryController.addListener(() => setState(() {}));
  }

  String _formatCardNumberInitial(String raw) {
    final clean = raw.replaceAll(RegExp(r'\s+'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }

  @override
  void dispose() {
    _nameController.disposeexhaustive();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  PaymentMethodModel _buildLivePreviewModel() {
    final cleanNumber = _numberController.text.replaceAll(RegExp(r'\s+'), '');
    final last4 = cleanNumber.length >= 4
        ? cleanNumber.substring(cleanNumber.length - 4)
        : (cleanNumber.isNotEmpty ? cleanNumber : '4242');

    final expParts = _expiryController.text.split('/');
    final expMonth = expParts.isNotEmpty && expParts[0].isNotEmpty
        ? expParts[0].padLeft(2, '0')
        : '12';
    final expYear = expParts.length > 1 && expParts[1].isNotEmpty ? expParts[1] : '28';

    final brand = CardBrand.fromNumber(cleanNumber).displayName;

    return PaymentMethodModel(
      id: widget.existingCard?.id ?? 'preview',
      userId: 'current',
      cardHolderName: _nameController.text.trim().toUpperCase(),
      cardNumber: cleanNumber,
      cardLast4: last4,
      expiryMonth: expMonth,
      expiryYear: expYear,
      cardBrand: brand,
      cardType: _selectedCardType,
      bankName: _selectedBank,
      isDefault: _isDefault,
      gradientIndex: _gradientIndex,
      createdAt: DateTime.now(),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final name = _nameController.text.trim().toUpperCase();
      final number = _numberController.text.replaceAll(RegExp(r'\s+'), '');
      final expiry = _expiryController.text.trim();
      final cvv = _cvvController.text.trim();

      PaymentMethodModel resultCard;

      if (widget.existingCard != null) {
        // UPDATE (U)
        final parts = expiry.split('/');
        final expMonth = parts.isNotEmpty ? parts[0].padLeft(2, '0') : '12';
        final expYear = parts.length > 1 ? parts[1] : '28';
        final last4 = number.length >= 4 ? number.substring(number.length - 4) : widget.existingCard!.cardLast4;

        final updated = widget.existingCard!.copyWith(
          cardHolderName: name,
          cardNumber: number.isNotEmpty ? number : widget.existingCard!.cardNumber,
          cardLast4: last4,
          expiryMonth: expMonth,
          expiryYear: expYear,
          cardBrand: CardBrand.fromNumber(number).displayName,
          cardType: _selectedCardType,
          bankName: _selectedBank,
          isDefault: _isDefault,
          gradientIndex: _gradientIndex,
        );

        await PaymentMethodManager.instance.updatePaymentMethod(updated);
        resultCard = updated;
      } else {
        // CREATE (C)
        resultCard = await PaymentMethodManager.instance.addPaymentMethod(
          cardHolderName: name,
          cardNumber: number,
          expiry: expiry,
          cvv: cvv,
          bankName: _selectedBank,
          cardType: _selectedCardType,
          isDefault: _isDefault,
          gradientIndex: _gradientIndex,
        );
      }

      if (mounted) {
        Navigator.pop(context, resultCard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving card: $e'.trAuto(context)),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCard != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
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
                Text(
                  (isEditing ? 'Edit Payment Card' : 'Add New Payment Card').trAuto(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
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
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Live Interactive Card Preview
                    CreditCardPreviewWidget(
                      card: _buildLivePreviewModel(),
                      showDefaultBadge: _isDefault,
                    ),

                    const SizedBox(height: 16),

                    // Color theme selector for card
                    Row(
                      children: [
                        Text(
                          'Card Color Style:'.trAuto(context),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ...List.generate(4, (index) {
                          final isSel = _gradientIndex == index;
                          final sampleColors = PaymentMethodModel(
                            id: '',
                            userId: '',
                            cardHolderName: '',
                            cardNumber: '',
                            cardLast4: '',
                            expiryMonth: '',
                            expiryYear: '',
                            cardBrand: '',
                            gradientIndex: index,
                            createdAt: DateTime.now(),
                          ).gradientColors;

                          return GestureDetector(
                            onTap: () => setState(() => _gradientIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: sampleColors),
                                border: isSel
                                    ? Border.all(color: const Color(0xFF0F3D24), width: 2.5)
                                    : null,
                                boxShadow: [
                                  if (isSel)
                                    BoxShadow(
                                      color: sampleColors.first.withValues(alpha: 0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: isSel
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 2. Issuing Bank Dropdown
                    _buildFieldLabel('Issuing Bank / Financial Institution'.trAuto(context)),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBank,
                      decoration: _inputDecoration(
                        prefixIcon: const Icon(Icons.account_balance_rounded, color: Color(0xFF0F3D24), size: 20),
                      ),
                      items: _sriLankanBanks
                          .map((b) => DropdownMenuItem(
                                value: b,
                                child: Text(b, style: const TextStyle(fontSize: 13.5)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBank = val);
                      },
                    ),

                    const SizedBox(height: 16),

                    // 3. Cardholder Name
                    _buildFieldLabel('Cardholder Name (as on card)'.trAuto(context)),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _inputDecoration(
                        hintText: 'e.g. NADEESHA FERNANDO',
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF0F3D24), size: 20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter cardholder name'.trAuto(context);
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 4. Card Number
                    _buildFieldLabel('Card Number'.trAuto(context)),
                    TextFormField(
                      controller: _numberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        _CardNumberFormatter(),
                      ],
                      decoration: _inputDecoration(
                        hintText: '4242 •••• •••• 4242',
                        prefixIcon: const Icon(Icons.credit_card_rounded, color: Color(0xFF0F3D24), size: 20),
                      ),
                      validator: (val) {
                        final digits = (val ?? '').replaceAll(RegExp(r'\s+'), '');
                        if (digits.length < 15) {
                          return 'Please enter valid 16-digit card number'.trAuto(context);
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // 5. Expiry Date & CVV (Side by side)
                    Row(
                      children: [
                        // Expiry (MM/YY)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('Expiry (MM/YY)'.trAuto(context)),
                              TextFormField(
                                controller: _expiryController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                  _CardExpiryFormatter(),
                                ],
                                decoration: _inputDecoration(
                                  hintText: 'MM/YY',
                                  prefixIcon: const Icon(Icons.calendar_month_outlined, color: Color(0xFF0F3D24), size: 20),
                                ),
                                validator: (val) {
                                  if (val == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(val)) {
                                    return 'Use MM/YY'.trAuto(context);
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        // CVV
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel('CVV / CVC Code'.trAuto(context)),
                              TextFormField(
                                controller: _cvvController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                decoration: _inputDecoration(
                                  hintText: '•••',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF0F3D24), size: 20),
                                ),
                                validator: (val) {
                                  if (val == null || val.length < 3) {
                                    return '3-4 digits'.trAuto(context);
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 6. Card Type Selector (Debit vs Credit)
                    Row(
                      children: [
                        _buildTypePill('Debit Card', _selectedCardType == 'Debit Card'),
                        const SizedBox(width: 10),
                        _buildTypePill('Credit Card', _selectedCardType == 'Credit Card'),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 7. Make Primary Switch
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 22),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Set as Primary Card'.trAuto(context),
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Use automatically for 1-click orders'.trAuto(context),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Switch.adaptive(
                            value: _isDefault,
                            activeTrackColor: const Color(0xFF0F3D24),
                            activeThumbColor: Colors.white,
                            onChanged: (val) => setState(() => _isDefault = val),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Security Guarantee Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDCFCE7)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_rounded, color: Color(0xFF15803D), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'End-to-end encrypted with 256-bit AES. FarmTrust does not store full card numbers.'
                                  .trAuto(context),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF166534),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F3D24),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isSaving ? null : _handleSave,
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isEditing ? Icons.check_circle_outline_rounded : Icons.add_card_rounded,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    (isEditing ? 'Save Changes' : 'Add Card to Marketplace')
                                        .trAuto(context),
                                    style: const TextStyle(
                                      fontSize: 15.5,
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
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF475569),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildTypePill(String type, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedCardType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0F3D24) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF0F3D24) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Center(
            child: Text(
              type.trAuto(context),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F3D24), width: 1.5),
      ),
    );
  }
}

extension on TextEditingController {
  void disposeexhaustive() {
    dispose();
  }
}

/// Formatter that automatically inserts spaces after every 4 digits: 4242 4242 4242 4242
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\s+'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter that automatically formats expiry date: MM/YY
class _CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

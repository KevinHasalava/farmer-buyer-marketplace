import 'package:flutter/material.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/constants/constants.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../services/pre_order_manager.dart';

class CreatePreOrderScreen extends StatefulWidget {
  const CreatePreOrderScreen({super.key});

  @override
  State<CreatePreOrderScreen> createState() => _CreatePreOrderScreenState();
}

class _CreatePreOrderScreenState extends State<CreatePreOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _cropNameCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qualityCtrl = TextEditingController();
  final _deliveryLocationCtrl = TextEditingController();
  final _packagingCtrl = TextEditingController();
  final _advancePaymentCtrl = TextEditingController();
  
  String _selectedPaymentTerm = 'Negotiable';
  final List<String> _paymentTerms = [
    'Negotiable',
    'Cash on Delivery',
    'Bank Transfer',
    'Advance Payment (Partial)',
    'Full Advance'
  ];

  DateTime? _selectedDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _cropNameCtrl.dispose();
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    _qualityCtrl.dispose();
    _deliveryLocationCtrl.dispose();
    _packagingCtrl.dispose();
    _advancePaymentCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr.pleaseSelectDeliveryDate)),
        );
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Typically you get buyer ID from Auth. Hardcoded for demo.
      await PreOrderManager.instance.createPreOrder(
        buyerId: 'buyer_primary',
        buyerName: 'Premium Supermarkets Ltd',
        cropName: _cropNameCtrl.text.trim(),
        requiredQuantityKg: double.parse(_quantityCtrl.text.trim()),
        offeredPricePerKg: double.parse(_priceCtrl.text.trim()),
        expectedDeliveryDate: _selectedDate!,
        qualityRequirements: _qualityCtrl.text.trim(),
        deliveryLocation: _deliveryLocationCtrl.text.trim(),
        packagingRequirements: _packagingCtrl.text.trim().isNotEmpty ? _packagingCtrl.text.trim() : 'Standard Packaging',
        paymentTerms: _selectedPaymentTerm,
        advancePaymentRs: _advancePaymentCtrl.text.trim().isNotEmpty ? double.parse(_advancePaymentCtrl.text.trim()) : 0.0,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          AppHeaderBanner(
            title: 'Create Pre-Order',
            subtitle: 'Contract farming for premium crops',
            showBack: true,
            badgeText: 'BUYER',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Crop Name / Variety'),
                    TextFormField(
                      controller: _cropNameCtrl,
                      decoration: _inputDeco('e.g. Organic Carrots, Red Onions'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Required Qty (Kg)'),
                              TextFormField(
                                controller: _quantityCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _inputDeco('e.g. 500'),
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Offered Price/Kg (Rs)'),
                              TextFormField(
                                controller: _priceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _inputDeco('e.g. 350'),
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Expected Delivery Date'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'Select Date'
                                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                              style: TextStyle(
                                color: _selectedDate == null ? AppColors.textHint : AppColors.textDark,
                                fontSize: 15,
                              ),
                            ),
                            const Icon(Icons.calendar_month_rounded, color: AppColors.primaryGreen),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Quality Requirements'),
                    TextFormField(
                      controller: _qualityCtrl,
                      maxLines: 3,
                      decoration: _inputDeco('Mention size, organic certification, packing etc.'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Delivery Location'),
                    TextFormField(
                      controller: _deliveryLocationCtrl,
                      decoration: _inputDeco('e.g. Dambulla Dedicated Economic Centre'),
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Packaging Requirements'),
                    TextFormField(
                      controller: _packagingCtrl,
                      decoration: _inputDeco('e.g. 50Kg Gunny Bags, Plastic Crates'),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Payment Terms'),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedPaymentTerm,
                                    isExpanded: true,
                                    icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryGreen),
                                    items: _paymentTerms.map((term) {
                                      return DropdownMenuItem(
                                        value: term,
                                        child: Text(term, style: const TextStyle(fontSize: 14)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _selectedPaymentTerm = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Advance Payment (Rs)'),
                              TextFormField(
                                controller: _advancePaymentCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _inputDeco('e.g. 50000'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    AppPrimaryButton(
                      label: 'Create Pre-Order Contract',
                      isLoading: _isSubmitting,
                      onPressed: _submit,
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
    );
  }
}

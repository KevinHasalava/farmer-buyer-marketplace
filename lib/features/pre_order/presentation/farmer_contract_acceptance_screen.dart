import 'package:flutter/material.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/constants/constants.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../services/pre_order_manager.dart';

class FarmerContractAcceptanceScreen extends StatefulWidget {
  final String preOrderId;
  final String cropName;
  final double requestedQuantity;

  const FarmerContractAcceptanceScreen({
    super.key,
    required this.preOrderId,
    required this.cropName,
    required this.requestedQuantity,
  });

  @override
  State<FarmerContractAcceptanceScreen> createState() => _FarmerContractAcceptanceScreenState();
}

class _FarmerContractAcceptanceScreenState extends State<FarmerContractAcceptanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yieldController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _harvestDate;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _yieldController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
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
    if (picked != null) {
      setState(() => _harvestDate = picked);
    }
  }

  Future<void> _submitAcceptance() async {
    if (!_formKey.currentState!.validate()) return;
    if (_harvestDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr.pleaseSelectHarvestDate)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await PreOrderManager.instance.updatePreOrderStatus(
        widget.preOrderId,
        'In Progress',
        farmerId: 'farmer_123', // Hardcoded for demo
        farmerName: 'Sunil Silva',
        farmerExpectedHarvestDate: _harvestDate,
        farmerEstimatedYieldKg: double.parse(_yieldController.text),
        farmerLocation: _locationController.text,
        farmerNotes: _notesController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr.contractAccepted)),
      );
      Navigator.pop(context, true); // Return true indicating success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(context.tr.acceptContract, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primaryGreen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You are accepting a contract for ${widget.requestedQuantity} Kg of ${widget.cropName}. Please provide your farming details below.',
                        style: const TextStyle(color: AppColors.textDark, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(context.tr.expectedHarvestDate, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _harvestDate == null 
                          ? 'Select Date' 
                          : '${_harvestDate!.day}/${_harvestDate!.month}/${_harvestDate!.year}',
                        style: TextStyle(
                          color: _harvestDate == null ? AppColors.textSecondary : AppColors.textDark,
                          fontSize: 16,
                        ),
                      ),
                      const Icon(Icons.calendar_today_rounded, color: AppColors.primaryGreen, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _yieldController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Estimated Yield (Kg) *',
                  hintText: 'e.g. ${widget.requestedQuantity}',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Farm Location / City *',
                  hintText: 'e.g. Nuwara Eliya',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Additional Notes / Farming Method',
                  hintText: 'Any specific conditions, organic methods, or land size...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 40),

              AppPrimaryButton(
                label: 'Submit & Accept',
                isLoading: _isSubmitting,
                onPressed: _submitAcceptance,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

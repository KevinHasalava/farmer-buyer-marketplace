import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../services/pre_order_manager.dart';

class AddProgressUpdateScreen extends StatefulWidget {
  final String preOrderId;

  const AddProgressUpdateScreen({super.key, required this.preOrderId});

  @override
  State<AddProgressUpdateScreen> createState() => _AddProgressUpdateScreenState();
}

class _AddProgressUpdateScreenState extends State<AddProgressUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  
  String _updateType = 'Progress Update';
  final List<String> _updateTypes = ['Progress Update', 'Report Delay', 'Report Issue'];

  String _selectedStage = 'Land Preparation';
  final List<String> _stages = [
    'Land Preparation',
    'Seeds Planted',
    'Fertilizer Applied',
    'Flowering',
    'Harvesting Soon',
    'Ready for Pickup'
  ];

  String _selectedIssue = 'Weather / Rain';
  final List<String> _issueTypes = [
    'Weather / Rain',
    'Pest / Disease',
    'Labor Shortage',
    'Transport Issue',
    'Other'
  ];

  DateTime? _newExpectedDate;

  final List<String> _selectedImages = [];
  bool _isSubmitting = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await PreOrderManager.instance.addProgressUpdate(
        preOrderId: widget.preOrderId,
        stage: _updateType == 'Progress Update' ? _selectedStage : 'Alert',
        description: _descCtrl.text.trim(),
        images: _selectedImages,
        updateType: _updateType.split(' ').last, // 'Update', 'Delay', 'Issue'
        newExpectedDate: _newExpectedDate,
        issueType: _updateType == 'Report Issue' ? _selectedIssue : null,
      );

      if (!mounted) return;
      Navigator.pop(context);
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
          const AppHeaderBanner(
            title: 'Add Progress Update',
            subtitle: 'Keep your buyer informed',
            showBack: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Type of Update'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _updateType,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen),
                          items: _updateTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _updateType = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_updateType == 'Progress Update') ...[
                      _buildLabel('Current Stage'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStage,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen),
                            items: _stages.map((stage) {
                              return DropdownMenuItem(
                                value: stage,
                                child: Text(stage),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStage = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else if (_updateType == 'Report Issue') ...[
                      _buildLabel('Type of Issue'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedIssue,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.red),
                            items: _issueTypes.map((issue) {
                              return DropdownMenuItem(
                                value: issue,
                                child: Text(issue, style: const TextStyle(color: Colors.red)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedIssue = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else if (_updateType == 'Report Delay') ...[
                      _buildLabel('New Expected Harvest Date'),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => _newExpectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.orange.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _newExpectedDate == null 
                                  ? 'Select New Date' 
                                  : '${_newExpectedDate!.day}/${_newExpectedDate!.month}/${_newExpectedDate!.year}',
                                style: TextStyle(
                                  color: _newExpectedDate == null ? AppColors.textSecondary : Colors.orange.shade900,
                                  fontSize: 16,
                                ),
                              ),
                              Icon(Icons.calendar_today_rounded, color: Colors.orange.shade700, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    _buildLabel('Description / Notes'),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: _updateType == 'Progress Update'
                            ? 'What did you do today? How is the crop?'
                            : 'Please describe the situation in detail...',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(16),
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
                      ),
                      validator: (v) => v!.isEmpty ? 'Please enter a description' : null,
                    ),
                    const SizedBox(height: 24),

                    _buildLabel('Attach Photos (Important for Delays/Issues)'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ..._selectedImages.map((img) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(img, width: 80, height: 80, fit: BoxFit.cover),
                            ),
                            Positioned(
                              right: -6,
                              top: -6,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedImages.remove(img)),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        )),
                        GestureDetector(
                          onTap: () {
                            // Mock adding an image
                            setState(() {
                              _selectedImages.add('https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400&auto=format&fit=crop&q=60');
                            });
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.5), style: BorderStyle.solid),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined, color: AppColors.primaryGreen),
                                SizedBox(height: 4),
                                Text('Add', style: TextStyle(fontSize: 12, color: AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    AppPrimaryButton(
                      label: 'Post Update',
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
}

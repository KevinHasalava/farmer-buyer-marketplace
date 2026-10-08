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
  
  String _selectedStage = 'Land Preparation';
  final List<String> _stages = [
    'Land Preparation',
    'Seeds Planted',
    'Fertilizer Applied',
    'Flowering',
    'Harvesting Soon',
    'Ready for Pickup'
  ];

  final List<String> _selectedImages = [];
  bool _isSubmitting = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await PreOrderManager.instance.addProgressUpdate(
        preOrderId: widget.preOrderId,
        stage: _selectedStage,
        description: _descCtrl.text.trim(),
        images: _selectedImages,
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

                    _buildLabel('Description / Notes'),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'What did you do today? How is the crop?',
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

                    _buildLabel('Attach Photos (Optional)'),
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

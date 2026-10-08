import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../services/pre_order_manager.dart';
import 'add_progress_update_screen.dart';
import 'farmer_contract_acceptance_screen.dart';
import 'farmer_rating_dialog.dart';

class PreOrderDetailScreen extends StatefulWidget {
  final String preOrderId;
  final bool isFarmerMode;

  const PreOrderDetailScreen({
    super.key,
    required this.preOrderId,
    required this.isFarmerMode,
  });

  @override
  State<PreOrderDetailScreen> createState() => _PreOrderDetailScreenState();
}

class _PreOrderDetailScreenState extends State<PreOrderDetailScreen> {
  Future<void> _acceptContract(String cropName, double quantity) async {
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FarmerContractAcceptanceScreen(
          preOrderId: widget.preOrderId,
          cropName: cropName,
          requestedQuantity: quantity,
        ),
      ),
    );

    if (success == true) {
      if (mounted) setState(() {});
    }
  }

  Future<void> _rateFarmer(String cropName, String farmerName) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => FarmerRatingDialog(farmerName: farmerName, cropName: cropName),
    );

    if (result != null) {
      final rating = result['rating'] as double;
      final review = result['review'] as String;
      await PreOrderManager.instance.ratePreOrder(widget.preOrderId, rating, review);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: ListenableBuilder(
        listenable: PreOrderManager.instance,
        builder: (context, _) {
          final order = PreOrderManager.instance.preOrders.firstWhere(
            (o) => o.id == widget.preOrderId,
          );
          final progressList = PreOrderManager.instance.getProgressForOrder(widget.preOrderId);

          return Column(
            children: [
              AppHeaderBanner(
                title: 'Contract Details',
                showBack: true,
                badgeText: order.status.toUpperCase(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Contract Info Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.cropName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow('Required Quantity', '${order.requiredQuantityKg} Kg'),
                            _buildDetailRow('Offered Price', 'Rs ${order.offeredPricePerKg} / Kg'),
                            _buildDetailRow(
                              'Expected Delivery', 
                              '${order.expectedDeliveryDate.day}/${order.expectedDeliveryDate.month}/${order.expectedDeliveryDate.year}',
                            ),
                            _buildDetailRow('Buyer', order.buyerName),
                            if (order.farmerName != null) _buildDetailRow('Farmer', order.farmerName!),
                            
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(color: AppColors.divider),
                            ),
                            const Text('Premium Contract Terms', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                            const SizedBox(height: 12),
                            _buildDetailRow('Delivery Location', order.deliveryLocation.isNotEmpty ? order.deliveryLocation : 'To be discussed'),
                            _buildDetailRow('Payment Terms', order.paymentTerms),
                            _buildDetailRow('Packaging', order.packagingRequirements),
                            if (order.advancePaymentRs > 0)
                              _buildDetailRow('Advance Payment', 'Rs ${order.advancePaymentRs.toStringAsFixed(2)}'),
                            
                            const SizedBox(height: 12),
                            const Text(
                              'Quality Requirements:',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.qualityRequirements,
                              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ),
                      
                      // Farmer's Proposal Details (if Accepted / In Progress)
                      if (order.farmerExpectedHarvestDate != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFC8E6C9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Farmer\'s Proposal Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                'Estimated Harvest', 
                                '${order.farmerExpectedHarvestDate!.day}/${order.farmerExpectedHarvestDate!.month}/${order.farmerExpectedHarvestDate!.year}'
                              ),
                              if (order.farmerEstimatedYieldKg != null)
                                _buildDetailRow('Estimated Yield', '${order.farmerEstimatedYieldKg} Kg'),
                              if (order.farmerLocation.isNotEmpty)
                                _buildDetailRow('Farm Location', order.farmerLocation),
                              if (order.farmerNotes.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Text(
                                  'Additional Notes:',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order.farmerNotes,
                                  style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      // Rating Display (if rated)
                      if (order.farmerRating != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${order.farmerRating} / 5.0 Rating Given',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                  ),
                                ],
                              ),
                              if (order.farmerReview != null && order.farmerReview!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  '"${order.farmerReview}"',
                                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),

                      // Action Buttons for Farmer
                      if (widget.isFarmerMode && order.status == 'Pending')
                        AppPrimaryButton(
                          label: 'Accept Contract',
                          onPressed: () => _acceptContract(order.cropName, order.requiredQuantityKg),
                        ),

                      if (widget.isFarmerMode && order.status == 'In Progress')
                        AppPrimaryButton(
                          label: 'Add Progress Update',
                          icon: Icons.add_a_photo_rounded,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddProgressUpdateScreen(preOrderId: order.id),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Opening chat...')),
                           );
                        },
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        label: Text(widget.isFarmerMode ? 'Contact Buyer' : 'Contact Farmer'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),

                      // Buyer Actions
                      if (!widget.isFarmerMode && order.status == 'In Progress') ...[
                        const SizedBox(height: 16),
                        AppPrimaryButton(
                          label: 'Mark as Completed',
                          icon: Icons.check_circle_rounded,
                          onPressed: () async {
                            await PreOrderManager.instance.updatePreOrderStatus(order.id, 'Completed');
                            if (mounted) setState(() {});
                          },
                        ),
                      ],

                      if (!widget.isFarmerMode && order.status == 'Completed' && order.farmerRating == null && order.farmerName != null) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _rateFarmer(order.cropName, order.farmerName!),
                          icon: const Icon(Icons.star_rounded),
                          label: const Text('Rate Farmer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],

                      if (progressList.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        const Text(
                          'Progress Timeline',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...progressList.map((prog) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: prog.updateType == 'Issue' 
                                          ? Colors.red 
                                          : prog.updateType == 'Delay' 
                                              ? Colors.orange 
                                              : AppColors.primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 2,
                                    height: 70, // Slightly taller to accommodate more text
                                    color: (prog.updateType == 'Issue' 
                                          ? Colors.red 
                                          : prog.updateType == 'Delay' 
                                              ? Colors.orange 
                                              : AppColors.primaryGreen).withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          prog.updateType == 'Issue' && prog.issueType != null 
                                              ? 'Alert: ${prog.issueType}'
                                              : prog.updateType == 'Delay' 
                                                  ? 'Delay Reported'
                                                  : prog.stage,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: prog.updateType == 'Issue' 
                                              ? Colors.red.shade700 
                                              : prog.updateType == 'Delay' 
                                                  ? Colors.orange.shade800 
                                                  : AppColors.textDark,
                                          ),
                                        ),
                                        Text(
                                          '${prog.date.day}/${prog.date.month}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      prog.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    if (prog.newExpectedDate != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'New Harvest Date: ${prog.newExpectedDate!.day}/${prog.newExpectedDate!.month}/${prog.newExpectedDate!.year}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                    ],
                                    if (prog.images.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 80,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: prog.images.length,
                                          itemBuilder: (ctx, i) => Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                prog.images[i], 
                                                width: 80, 
                                                height: 80, 
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Container(
                                                  width: 80, height: 80, color: Colors.grey.shade300,
                                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/localization/app_settings.dart';

import '../../../core/constants/constants.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../models/pre_order_model.dart';
import '../services/pre_order_manager.dart';
import 'create_pre_order_screen.dart';
import 'pre_order_detail_screen.dart';

class PreOrderListScreen extends StatefulWidget {
  final bool isFarmerMode;
  final bool isEmbedded;

  const PreOrderListScreen({super.key, this.isFarmerMode = false, this.isEmbedded = false});

  @override
  State<PreOrderListScreen> createState() => _PreOrderListScreenState();
}

class _PreOrderListScreenState extends State<PreOrderListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PreOrderManager.instance.loadPreOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final listContent = ListenableBuilder(
      listenable: PreOrderManager.instance,
      builder: (context, _) {
        if (PreOrderManager.instance.isLoading && PreOrderManager.instance.preOrders.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
        }

        final orders = PreOrderManager.instance.preOrders;

        if (orders.isEmpty) {
          return Center(
            child: Text(context.tr.noPreOrdersFound, style: const TextStyle(color: AppColors.textSecondary)),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final order = orders[index];
            return _PreOrderCard(
              order: order,
              isFarmerMode: widget.isFarmerMode,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PreOrderDetailScreen(
                      preOrderId: order.id,
                      isFarmerMode: widget.isFarmerMode,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (widget.isEmbedded) {
      return listContent;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          AppHeaderBanner(
            title: 'Contract Farming',
            subtitle: widget.isFarmerMode 
                ? 'Accept pre-orders and guarantee sales' 
                : 'Request crops directly from farmers',
            showBack: true,
            badgeText: widget.isFarmerMode ? 'FARMER' : 'BUYER',
          ),
          Expanded(child: listContent),

        ],
      ),
      floatingActionButton: !widget.isFarmerMode
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePreOrderScreen()),
                );
              },
              backgroundColor: AppColors.primaryGreen,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(context.tr.newRequest, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }
}

class _PreOrderCard extends StatelessWidget {
  final PreOrderModel order;
  final bool isFarmerMode;
  final VoidCallback onTap;

  const _PreOrderCard({
    required this.order,
    required this.isFarmerMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (order.status == 'Pending') statusColor = AppColors.accentOrange;
    else if (order.status == 'In Progress') statusColor = Colors.blue;
    else if (order.status == 'Completed') statusColor = AppColors.primaryGreen;
    else statusColor = Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Text(
                    'Rs ${order.offeredPricePerKg}/Kg',
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${order.requiredQuantityKg} Kg of ${order.cropName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.storefront_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Buyer: ${order.buyerName}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              if (order.farmerName != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Farmer: ${order.farmerName}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: AppColors.divider),
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Due: ${order.expectedDeliveryDate.day}/${order.expectedDeliveryDate.month}/${order.expectedDeliveryDate.year}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

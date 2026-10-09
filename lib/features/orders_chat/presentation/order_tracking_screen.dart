import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../../../core/localization/app_settings.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../../cart/services/cart_state.dart';

/// Live Order Tracking screen showing farm-to-table progress
class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({
    super.key,
    required this.order,
  });

  final FarmOrder order;

  static const Color _forestGreen = Color(0xFF286A46);
  static const Color _bgSoft = Color(0xFFF8FAF9);
  static const Color _textDark = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MarketplaceState.instance,
      builder: (context, _) {
        final liveOrder = MarketplaceState.instance.orders.firstWhere(
          (o) => o.id.replaceAll('#', '').trim() == order.id.replaceAll('#', '').trim(),
          orElse: () => order,
        );

        final double progressValue = switch (liveOrder.status) {
          OrderStatus.pending || OrderStatus.confirmed => 0.25,
          OrderStatus.processing => 0.50,
          OrderStatus.inTransit => 0.75,
          OrderStatus.delivered => 1.0,
          OrderStatus.cancelled => 0.0,
        };
    return Scaffold(
      backgroundColor: _bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: _textDark,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          children: [
            Text(
              context.tr.trackOrder,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            Text(
              '#${order.id}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _forestGreen,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [
          Center(child: AppLanguagePill()),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        child: Column(
          children: [
            // Status Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF235D3A), Color(0xFF163E26)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _forestGreen.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_shipping_rounded,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              liveOrder.status.localizedLabel(context),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        liveOrder.preferredDateTime,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr.freshHarvestOnTheWay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr.pickedDirectly,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Progress line
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Assigned Rider & Cold Chain Fleet Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEDF2EF)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: const Icon(Icons.two_wheeler_rounded, color: _forestGreen, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ranjith Subha (NC-4982)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        Text(
                          'Chilled Fleet • +94 77 123 4567',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: liveOrder.status == OrderStatus.delivered
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: liveOrder.status == OrderStatus.delivered
                            ? const Color(0xFFA7F3D0)
                            : const Color(0xFFBFDBFE),
                      ),
                    ),
                    child: Text(
                      liveOrder.status == OrderStatus.delivered
                          ? 'Delivered'
                          : liveOrder.status == OrderStatus.inTransit
                              ? 'En Route'
                              : 'Assigned',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: liveOrder.status == OrderStatus.delivered
                            ? const Color(0xFF059669)
                            : const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Timeline Steps Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEDF2EF)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr.trackingTimeline,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A9BA8),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(liveOrder.trackingSteps.length, (index) {
                    final step = liveOrder.trackingSteps[index];
                    final isLast = index == liveOrder.trackingSteps.length - 1;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: step.isCompleted
                                      ? _forestGreen
                                      : const Color(0xFFE2E8F0),
                                ),
                                child: Icon(
                                  step.isCompleted
                                      ? Icons.check_rounded
                                      : Icons.circle,
                                  size: step.isCompleted ? 14 : 8,
                                  color: step.isCompleted
                                      ? Colors.white
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: step.isCompleted
                                        ? _forestGreen
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        step.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: step.isCurrent || step.isCompleted
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: _textDark,
                                        ),
                                      ),
                                      Text(
                                        step.time,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    step.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Delivery Details Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEDF2EF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr.destinationAndContact,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A9BA8),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: _forestGreen, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          liveOrder.deliveryAddress,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.phone_rounded,
                          color: _forestGreen, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        liveOrder.contactNumber,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}

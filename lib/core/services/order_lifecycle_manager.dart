import 'package:flutter/foundation.dart';
import '../../features/admin/models/admin_models.dart';
import '../../features/admin/services/admin_marketplace_service.dart';
import '../../features/cart/services/cart_state.dart';
import '../../features/driver/models/delivery_order_model.dart';
import '../../features/driver/services/driver_firestore_service.dart';
import '../../features/orders_chat/models/order_model.dart';

/// Rich data model representing an incoming or active order from the Farmer's perspective
class FarmerOrderItem {
  final String id;
  final String customer;
  final String customerPhone;
  final String deliveryAddress;
  final String amount;
  final double amountValue;
  final String status; // 'Pending', 'Packed & Ready', 'In Transit', 'Completed', 'Cancelled'
  final bool isPending;
  final String avatarUrl;
  final String handoverPin; // 4-digit security PIN to give the driver upon pickup
  final DateTime orderDate;
  final List<OrderItemSummary> items;
  final String deliveryMethod;
  final String preferredTime;
  final String paymentMethod;
  final String assignedDriverName;
  final String assignedDriverPhone;

  const FarmerOrderItem({
    required this.id,
    required this.customer,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.amount,
    required this.amountValue,
    required this.status,
    required this.isPending,
    required this.avatarUrl,
    required this.handoverPin,
    required this.orderDate,
    required this.items,
    required this.deliveryMethod,
    required this.preferredTime,
    required this.paymentMethod,
    this.assignedDriverName = 'Ranjith Subha (Assigned)',
    this.assignedDriverPhone = '+94 77 123 4567',
  });

  FarmerOrderItem copyWith({
    String? status,
    bool? isPending,
    String? assignedDriverName,
    String? assignedDriverPhone,
  }) {
    return FarmerOrderItem(
      id: id,
      customer: customer,
      customerPhone: customerPhone,
      deliveryAddress: deliveryAddress,
      amount: amount,
      amountValue: amountValue,
      status: status ?? this.status,
      isPending: isPending ?? this.isPending,
      avatarUrl: avatarUrl,
      handoverPin: handoverPin,
      orderDate: orderDate,
      items: items,
      deliveryMethod: deliveryMethod,
      preferredTime: preferredTime,
      paymentMethod: paymentMethod,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
      assignedDriverPhone: assignedDriverPhone ?? this.assignedDriverPhone,
    );
  }
}

/// Central Unified Order Lifecycle Coordinator
/// Seamlessly synchronizes order lifecycle states across Buyer, Farmer, Driver, and Admin.
class OrderLifecycleManager extends ChangeNotifier {
  OrderLifecycleManager._internal() {
    _initDefaults();
  }

  static final OrderLifecycleManager instance = OrderLifecycleManager._internal();
  factory OrderLifecycleManager() => instance;

  final List<FarmerOrderItem> _farmerOrders = [];
  List<FarmerOrderItem> get farmerOrders => List.unmodifiable(_farmerOrders);

  int get pendingFarmerOrdersCount =>
      _farmerOrders.where((o) => o.status == 'Pending' || o.isPending).length;

  int get completedFarmerOrdersCount =>
      _farmerOrders.where((o) => o.status == 'Completed').length;

  double get totalFarmerEarnings => _farmerOrders
      .where((o) => o.status == 'Completed')
      .fold(0.0, (sum, o) => sum + o.amountValue);

  void _initDefaults() {
    if (_farmerOrders.isEmpty) {
      _farmerOrders.addAll([
        FarmerOrderItem(
          id: '#FH-1025',
          customer: 'Nadeesha Fernando',
          customerPhone: '+94 71 889 2314',
          deliveryAddress: 'No. 42 Havelock Rd, Colombo 05',
          amount: 'Rs. 950',
          amountValue: 950.0,
          status: 'Pending',
          isPending: true,
          avatarUrl:
              'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
          handoverPin: '4921',
          orderDate: DateTime.now().subtract(const Duration(minutes: 45)),
          items: const [
            OrderItemSummary(
              name: 'Organic Tomatoes',
              quantity: 2,
              unitPrice: 250.0,
              unit: 'kg',
              emoji: '🍅',
            ),
            OrderItemSummary(
              name: 'Fresh Carrots',
              quantity: 1,
              unitPrice: 300.0,
              unit: 'kg',
              emoji: '🥕',
            ),
            OrderItemSummary(
              name: 'Highland Potatoes',
              quantity: 1,
              unitPrice: 150.0,
              unit: 'kg',
              emoji: '🥔',
            ),
          ],
          deliveryMethod: 'Home Delivery',
          preferredTime: '10:00 AM - 12:00 PM',
          paymentMethod: 'Cash on Delivery',
        ),
        FarmerOrderItem(
          id: '#FH-1024',
          customer: 'Kasun Perera',
          customerPhone: '+94 77 341 9082',
          deliveryAddress: 'De Fonseka Rd, Colombo 04',
          amount: 'Rs. 1,200',
          amountValue: 1200.0,
          status: 'Packed & Ready',
          isPending: false,
          avatarUrl:
              'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&auto=format&fit=crop&q=80',
          handoverPin: '6318',
          orderDate: DateTime.now().subtract(const Duration(hours: 2)),
          items: const [
            OrderItemSummary(
              name: 'Highland Potatoes',
              quantity: 4,
              unitPrice: 300.0,
              unit: 'kg',
              emoji: '🥔',
            ),
          ],
          deliveryMethod: 'Direct Farm Pickup',
          preferredTime: '02:00 PM - 04:00 PM',
          paymentMethod: 'Farm Wallet',
        ),
      ]);
    }
  }

  /// Called when Buyer checks out and places an order.
  /// Automatically fans out to Driver, Farmer, and Admin.
  void onBuyerOrderPlaced({
    required FarmOrder order,
    required String buyerName,
    required String buyerPhone,
    String? farmName,
    String? farmLocation,
  }) {
    final cleanId = order.id.replaceAll('#', '').trim();
    final formattedId = '#$cleanId';

    // 1. Generate unique 4-digit security PIN for Driver-Farmer handover
    final pin = (1000 + (DateTime.now().millisecond * 7) % 9000).toString();

    // 2. Produce summary
    final produceSummary = order.items.isNotEmpty
        ? order.items.map((i) => '${i.quantity} ${i.unit} ${i.name}').join(', ')
        : 'Fresh Farm Produce Basket';

    final effectiveFarmName = farmName ?? 'Sunil Perera Farm';
    final effectiveFarmAddress = farmLocation ?? 'Perera Agro Holdings, Welimada';

    // 3. Register with Driver Deliveries Service
    final driverFee = (order.totalAmount * 0.18).clamp(850.0, 3500.0);
    final deliveryOrder = DeliveryOrderModel(
      id: cleanId,
      orderNumber: formattedId,
      status: 'Ready for Pickup',
      crateCount: '${(order.items.length / 2).ceil()} Crates',
      pickupDueText: 'Pickup Due in 25m',
      farmerName: effectiveFarmName,
      farmerAddress: effectiveFarmAddress,
      buyerName: buyerName.isNotEmpty ? buyerName : 'Valued Buyer',
      buyerAddress: order.deliveryAddress,
      produceDescription: produceSummary,
      producePackageType: 'Chilled crate packed',
      driverFee: driverFee,
      isPriority: true,
      createdAt: order.orderDate,
      updatedAt: DateTime.now(),
    );

    DriverFirestoreService().addDeliveryOrder(deliveryOrder, handoverPin: pin);

    // 4. Register with Farmer Orders list
    final farmerOrder = FarmerOrderItem(
      id: formattedId,
      customer: buyerName.isNotEmpty ? buyerName : 'Valued Buyer',
      customerPhone: buyerPhone.isNotEmpty ? buyerPhone : order.contactNumber,
      deliveryAddress: order.deliveryAddress,
      amount: 'Rs. ${order.totalAmount.toStringAsFixed(0)}',
      amountValue: order.totalAmount,
      status: 'Pending',
      isPending: true,
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
      handoverPin: pin,
      orderDate: order.orderDate,
      items: order.items,
      deliveryMethod: order.deliveryMethod,
      preferredTime: order.preferredDateTime,
      paymentMethod: order.paymentMethod,
    );

    _farmerOrders.insert(0, farmerOrder);

    // 5. Register with Admin Console
    try {
      final adminOrder = AdminOrderModel(
        id: formattedId,
        customerName: farmerOrder.customer,
        customerPhone: farmerOrder.customerPhone,
        farmName: effectiveFarmName,
        itemsSummary: produceSummary,
        totalAmount: order.totalAmount,
        status: 'Pending',
        deliveryAddress: order.deliveryAddress,
        assignedDriverName: 'Ranjith Subha (NC-4982)',
        assignedDriverPhone: '+94 77 123 4567',
        orderDate: order.orderDate,
      );
      AdminMarketplaceService.instance.addOrder(adminOrder);
    } catch (_) {}

    notifyListeners();
  }

  /// Farmer updates order state (e.g. 'Packed & Ready', 'Ready for Pickup')
  void onFarmerStatusUpdated(String orderId, String newStatus) {
    final cleanId = orderId.replaceAll('#', '').trim();
    final idx = _farmerOrders.indexWhere((o) => o.id.replaceAll('#', '').trim() == cleanId);
    if (idx >= 0) {
      final current = _farmerOrders[idx];
      _farmerOrders[idx] = current.copyWith(
        status: newStatus,
        isPending: newStatus == 'Pending',
      );
      notifyListeners();
    }

    // Sync to Driver
    if (newStatus == 'Packed & Ready' || newStatus == 'Ready for Pickup') {
      DriverFirestoreService().updateDeliveryStatus(cleanId, 'Ready for Pickup');
    }

    // Sync to Buyer
    MarketplaceState.instance.updateOrderStatus(
      cleanId,
      newStatus == 'Packed & Ready' || newStatus == 'Ready for Pickup'
          ? OrderStatus.processing
          : OrderStatus.confirmed,
    );

    // Sync to Admin
    try {
      AdminMarketplaceService.instance.updateOrderStatus(
        '#$cleanId',
        newStatus == 'Packed & Ready' ? 'Processing' : newStatus,
      );
    } catch (_) {}
  }

  /// Driver updates delivery state ('In Transit', 'COMPLETED')
  void onDriverStatusUpdated(String orderId, String newStatus) {
    final cleanId = orderId.replaceAll('#', '').trim();

    // 1. Sync to Farmer
    final farmerIdx = _farmerOrders.indexWhere((o) => o.id.replaceAll('#', '').trim() == cleanId);
    if (farmerIdx >= 0) {
      final isDone = newStatus.toUpperCase() == 'COMPLETED' || newStatus == 'Delivered';
      final isInTransit = newStatus == 'In Transit' || newStatus == 'En Route';
      final updatedStatus = isDone
          ? 'Completed'
          : isInTransit
              ? 'In Transit'
              : newStatus;

      _farmerOrders[farmerIdx] = _farmerOrders[farmerIdx].copyWith(
        status: updatedStatus,
        isPending: false,
      );
      notifyListeners();
    }

    // 2. Sync to Buyer
    if (newStatus.toUpperCase() == 'COMPLETED' || newStatus == 'Delivered') {
      MarketplaceState.instance.updateOrderStatus(cleanId, OrderStatus.delivered);
    } else if (newStatus == 'In Transit' || newStatus == 'En Route') {
      MarketplaceState.instance.updateOrderStatus(cleanId, OrderStatus.inTransit);
    }

    // 3. Sync to Admin
    try {
      final adminStatus = (newStatus.toUpperCase() == 'COMPLETED' || newStatus == 'Delivered')
          ? 'Delivered'
          : newStatus;
      AdminMarketplaceService.instance.updateOrderStatus('#$cleanId', adminStatus);
    } catch (_) {}
  }
}

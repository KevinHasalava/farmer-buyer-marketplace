enum OrderStatus {
  pending,
  confirmed,
  processing,
  inTransit,
  delivered,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Harvesting & Packing';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class OrderItemSummary {
  final String name;
  final int quantity;
  final double unitPrice;
  final String unit;
  final String emoji;

  const OrderItemSummary({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.unit,
    required this.emoji,
  });

  double get totalPrice => unitPrice * quantity;
}

class OrderTrackingStep {
  final String title;
  final String description;
  final String time;
  final bool isCompleted;
  final bool isCurrent;

  const OrderTrackingStep({
    required this.title,
    required this.description,
    required this.time,
    required this.isCompleted,
    this.isCurrent = false,
  });
}

class FarmOrder {
  final String id;
  final DateTime orderDate;
  final OrderStatus status;
  final List<OrderItemSummary> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double totalAmount;
  final String deliveryAddress;
  final String contactNumber;
  final String deliveryMethod;
  final String preferredDateTime;
  final String paymentMethod;
  final List<OrderTrackingStep> trackingSteps;

  FarmOrder({
    required this.id,
    required this.orderDate,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.contactNumber,
    required this.deliveryMethod,
    required this.preferredDateTime,
    required this.paymentMethod,
    required this.trackingSteps,
  });
}

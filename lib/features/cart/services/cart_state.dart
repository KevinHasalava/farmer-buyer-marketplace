import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';

import '../../buyer/services/buyer_profile_manager.dart';
import '../../orders_chat/models/chat_model.dart';
import '../../orders_chat/models/order_model.dart';
import '../../../core/services/order_lifecycle_manager.dart';

/// Central state manager for Cart, Checkout, and Orders/Chat
class MarketplaceState extends ChangeNotifier {
  static final MarketplaceState instance = MarketplaceState._internal();
  factory MarketplaceState() => instance;

  MarketplaceState._internal() {
    _initDefaultState();
  }

  // ── Cart State ─────────────────────────────────────────────────────────────
  final List<CartItem> _cartItems = [];
  String _promoCode = 'FARM25';
  double _promoDiscount = 70.0;
  final double _deliveryFee = 0.0; // Free delivery with promo

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  String get promoCode => _promoCode;
  double get promoDiscount => _cartItems.isEmpty ? 0 : _promoDiscount;
  double get deliveryFee => _cartItems.isEmpty ? 0 : _deliveryFee;

  double get subtotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get totalAmount {
    if (_cartItems.isEmpty) return 0.0;
    final total = subtotal - promoDiscount + deliveryFee;
    return total > 0 ? total : 0;
  }

  int get totalItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  // ── Delivery & Checkout Info (matching Figma/Image 2 defaults) ─────────────
  String deliveryAddress = '123, Main Street, Hambantota';
  String contactNumber = '076 323 8225';
  String deliveryMethod = 'Home Delivery';
  String preferredDate = '18 Aug 2026';
  String preferredTime = '10:00 AM - 12:00 PM';
  String paymentMethod = 'Cash on Delivery';

  // ── Orders State ───────────────────────────────────────────────────────────
  final List<FarmOrder> _orders = [];
  List<FarmOrder> get orders => List.unmodifiable(_orders);

  // ── Chat State (matching Figma/Image 1) ────────────────────────────────────
  final List<ChatConversation> _chats = [];
  List<ChatConversation> get chats => List.unmodifiable(_chats);

  void _initDefaultState() {
    // 1. Initial cart items matching Rs. 950 checkout total (Image 2)
    _cartItems.addAll([
      CartItem(
        id: 'c1',
        name: 'Organic Tomatoes',
        price: 250.0,
        unit: '/kg',
        quantity: 2,
        emoji: '🍅',
        farmName: 'Sunil Perera Farm',
        imageUrl:
            'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=200&auto=format&fit=crop&q=80',
      ),
      CartItem(
        id: 'c2',
        name: 'Fresh Carrots',
        price: 300.0,
        unit: '/kg',
        quantity: 1,
        emoji: '🥕',
        farmName: 'Sunil Perera Farm',
        imageUrl:
            'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=200&auto=format&fit=crop&q=80',
      ),
      CartItem(
        id: 'c3',
        name: 'Highland Potatoes',
        price: 150.0,
        unit: '/kg',
        quantity: 1,
        emoji: '🥔',
        farmName: 'Nuwara Eliya Organic',
        imageUrl:
            'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=200&auto=format&fit=crop&q=80',
      ),
    ]);

    // 2. Initial Chats exactly matching Image 1
    _chats.addAll([
      ChatConversation(
        id: 'chat_1',
        name: 'Nadeesha Fernando',
        avatarUrl:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80',
        lastMessage: 'Are these tomatoes freshly...',
        time: '10:24 AM',
        unreadCount: 2,
        isOnline: true,
        role: 'Verified Buyer',
        productContext: 'Organic Tomatoes (Rs. 250/kg)',
        messages: [
          ChatMessage(
            id: 'm1',
            senderId: 'buyer',
            text: 'Hello Sunil, are these tomatoes harvested today morning?',
            time: DateTime.now().subtract(const Duration(minutes: 25)),
            isMe: false,
          ),
          ChatMessage(
            id: 'm2',
            senderId: 'me',
            text:
                'Ayubowan Nadeesha! Yes, picked fresh at 6:00 AM from our Hambantota farm.',
            time: DateTime.now().subtract(const Duration(minutes: 20)),
            isMe: true,
          ),
          ChatMessage(
            id: 'm3',
            senderId: 'buyer',
            text: 'Are these tomatoes freshly harvested without pesticides?',
            time: DateTime.now().subtract(const Duration(minutes: 6)),
            isMe: false,
          ),
          ChatMessage(
            id: 'm4',
            senderId: 'buyer',
            text: 'I would like to order 5kg if they are ready for delivery.',
            time: DateTime.now().subtract(const Duration(minutes: 2)),
            isMe: false,
          ),
        ],
      ),
      ChatConversation(
        id: 'chat_2',
        name: 'Kasun Perera',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
        lastMessage: 'I will collect the order today.',
        time: '09:15 AM',
        unreadCount: 1,
        isOnline: true,
        role: 'Market Vendor',
        productContext: 'Fresh Carrots & Highland Potatoes',
        messages: [
          ChatMessage(
            id: 'k1',
            senderId: 'me',
            text: 'Your order #FT-8291 has been packed and weighed!',
            time: DateTime.now().subtract(const Duration(hours: 2)),
            isMe: true,
          ),
          ChatMessage(
            id: 'k2',
            senderId: 'buyer',
            text: 'I will collect the order today.',
            time: DateTime.now().subtract(const Duration(hours: 1)),
            isMe: false,
          ),
        ],
      ),
      ChatConversation(
        id: 'chat_3',
        name: 'Tharushi Silva',
        avatarUrl:
            'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150&auto=format&fit=crop&q=80',
        lastMessage: 'Thank you!',
        time: 'Yesterday',
        unreadCount: 0,
        isOnline: false,
        role: 'Verified Buyer',
        productContext: 'Bell Peppers (Greenhouse)',
        messages: [
          ChatMessage(
            id: 't1',
            senderId: 'buyer',
            text: 'Received the bell peppers! Very sweet and crunchy.',
            time: DateTime.now().subtract(const Duration(days: 1)),
            isMe: false,
          ),
          ChatMessage(
            id: 't2',
            senderId: 'buyer',
            text: 'Thank you!',
            time: DateTime.now().subtract(const Duration(days: 1)),
            isMe: false,
          ),
        ],
      ),
      ChatConversation(
        id: 'chat_4',
        name: 'Saman Kumara',
        avatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
        lastMessage: 'Can I get 5kg of carrots?',
        time: 'Yesterday',
        unreadCount: 0,
        isOnline: false,
        role: 'Restaurant Owner',
        productContext: 'Fresh Carrots',
        messages: [
          ChatMessage(
            id: 's1',
            senderId: 'buyer',
            text: 'Can I get 5kg of carrots?',
            time: DateTime.now().subtract(const Duration(days: 1)),
            isMe: false,
          ),
        ],
      ),
      ChatConversation(
        id: 'chat_5',
        name: 'Dilshan',
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
        lastMessage: 'The product is very fresh!',
        time: 'Aug 20',
        unreadCount: 0,
        isOnline: false,
        role: 'Buyer',
        productContext: 'Highland Potatoes',
        messages: [
          ChatMessage(
            id: 'd1',
            senderId: 'buyer',
            text: 'The product is very fresh!',
            time: DateTime.now().subtract(const Duration(days: 4)),
            isMe: false,
          ),
        ],
      ),
    ]);

    // 3. Initial Orders
    _orders.addAll([
      FarmOrder(
        id: 'FT-8291',
        orderDate: DateTime(2026, 8, 18, 9, 30),
        status: OrderStatus.inTransit,
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
        subtotal: 950.0,
        deliveryFee: 0.0,
        discount: 0.0,
        totalAmount: 950.0,
        deliveryAddress: '123, Main Street, Hambantota',
        contactNumber: '076 323 8225',
        deliveryMethod: 'Home Delivery',
        preferredDateTime: '18 Aug 2026, 10:00 AM - 12:00 PM',
        paymentMethod: 'Cash on Delivery',
        trackingSteps: const [
          OrderTrackingStep(
            title: 'Order Placed',
            description: 'Order confirmed and sent to Sunil Perera Farm',
            time: '09:30 AM',
            isCompleted: true,
          ),
          OrderTrackingStep(
            title: 'Harvested & Packed',
            description: 'Fresh vegetables picked and quality inspected',
            time: '10:05 AM',
            isCompleted: true,
          ),
          OrderTrackingStep(
            title: 'In Transit with Rider',
            description: 'Rider Nuwan is on the way to Hambantota',
            time: '10:45 AM',
            isCompleted: true,
            isCurrent: true,
          ),
          OrderTrackingStep(
            title: 'Delivered',
            description: 'Package handed over to recipient',
            time: 'Est. 11:30 AM',
            isCompleted: false,
          ),
        ],
      ),
      FarmOrder(
        id: 'FT-8120',
        orderDate: DateTime(2026, 8, 14, 14, 15),
        status: OrderStatus.delivered,
        items: const [
          OrderItemSummary(
            name: 'Highland Potatoes',
            quantity: 3,
            unitPrice: 220.0,
            unit: 'kg',
            emoji: '🥔',
          ),
        ],
        subtotal: 660.0,
        deliveryFee: 0.0,
        discount: 0.0,
        totalAmount: 660.0,
        deliveryAddress: '123, Main Street, Hambantota',
        contactNumber: '076 323 8225',
        deliveryMethod: 'Home Delivery',
        preferredDateTime: '14 Aug 2026, 04:00 PM',
        paymentMethod: 'Cash on Delivery',
        trackingSteps: const [
          OrderTrackingStep(
            title: 'Order Placed',
            description: 'Confirmed by buyer',
            time: '02:15 PM',
            isCompleted: true,
          ),
          OrderTrackingStep(
            title: 'Delivered Successfully',
            description: 'Handed over at 123, Main Street',
            time: '04:10 PM',
            isCompleted: true,
          ),
        ],
      ),
    ]);
  }

  // ── Cart Actions ───────────────────────────────────────────────────────────
  void addToCart(CartItem item) {
    final index = _cartItems.indexWhere((i) => i.name == item.name);
    if (index >= 0) {
      _cartItems[index].quantity += item.quantity;
    } else {
      _cartItems.add(item);
    }
    notifyListeners();
  }

  void updateQuantity(String id, int delta) {
    final index = _cartItems.indexWhere((i) => i.id == id);
    if (index >= 0) {
      final newQty = _cartItems[index].quantity + delta;
      if (newQty <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = newQty;
      }
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _cartItems.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void applyPromoCode(String code) {
    if (code.trim().toUpperCase() == 'FARM25') {
      _promoCode = 'FARM25';
      _promoDiscount = 70.0;
    } else if (code.trim().isNotEmpty) {
      _promoCode = code.toUpperCase();
      _promoDiscount = 50.0;
    }
    notifyListeners();
  }

  // ── Checkout Actions ───────────────────────────────────────────────────────
  void updateDeliveryAddress(String address) {
    deliveryAddress = address;
    notifyListeners();
  }

  void updateContactNumber(String contact) {
    contactNumber = contact;
    notifyListeners();
  }

  void updateDeliveryMethod(String method) {
    deliveryMethod = method;
    notifyListeners();
  }

  void updatePreferredDateTime(String date, String time) {
    preferredDate = date;
    preferredTime = time;
    notifyListeners();
  }

  void updatePaymentMethod(String method) {
    paymentMethod = method;
    notifyListeners();
  }

  FarmOrder placeCurrentOrder() {
    final newOrder = FarmOrder(
      id: 'FT-${(1000 + _orders.length * 17 + DateTime.now().millisecond % 900)}',
      orderDate: DateTime.now(),
      status: OrderStatus.confirmed,
      items: _cartItems
          .map(
            (i) => OrderItemSummary(
              name: i.name,
              quantity: i.quantity,
              unitPrice: i.price,
              unit: i.unit.replaceAll('/', ''),
              emoji: i.emoji,
            ),
          )
          .toList(),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: promoDiscount,
      totalAmount: totalAmount > 0 ? totalAmount : 950.0,
      deliveryAddress: deliveryAddress,
      contactNumber: contactNumber,
      deliveryMethod: deliveryMethod,
      preferredDateTime: '$preferredDate, $preferredTime',
      paymentMethod: paymentMethod,
      trackingSteps: [
        OrderTrackingStep(
          title: 'Order Placed',
          description: 'Order confirmed with $paymentMethod',
          time: 'Just now',
          isCompleted: true,
          isCurrent: true,
        ),
        const OrderTrackingStep(
          title: 'Harvesting & Packing',
          description: 'Farmer is gathering your fresh farm produce',
          time: 'Pending',
          isCompleted: false,
        ),
        const OrderTrackingStep(
          title: 'Out for Delivery',
          description: 'Courier assigned for Hambantota route',
          time: 'Est. in 2 hours',
          isCompleted: false,
        ),
        const OrderTrackingStep(
          title: 'Delivered',
          description: 'Package arrives at your doorstep',
          time: 'Est. 12:00 PM',
          isCompleted: false,
        ),
      ],
    );

    final farmName = _cartItems.isNotEmpty ? _cartItems.first.farmName : 'Sunil Perera Farm';

    _orders.insert(0, newOrder);
    _cartItems.clear();

    // Central Multi-Party Synchronization (Driver, Farmer, Buyer, Admin)
    try {
      final buyerProfile = BuyerProfileManager.instance.profile;
      OrderLifecycleManager.instance.onBuyerOrderPlaced(
        order: newOrder,
        buyerName: buyerProfile.name.isNotEmpty ? buyerProfile.name : 'Valued Buyer',
        buyerPhone: newOrder.contactNumber.isNotEmpty
            ? newOrder.contactNumber
            : (buyerProfile.phone.isNotEmpty ? buyerProfile.phone : '+94771234567'),
        farmName: farmName,
        farmLocation: 'Perera Agro Holdings, Welimada',
      );
    } catch (e) {
      debugPrint('[MarketplaceState] Order lifecycle sync note: $e');
    }

    notifyListeners();
    return newOrder;
  }

  /// Updates an order's status and tracking steps in real time
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    final cleanId = orderId.replaceAll('#', '').trim();
    final idx = _orders.indexWhere((o) => o.id.replaceAll('#', '').trim() == cleanId);
    if (idx >= 0) {
      final o = _orders[idx];
      final isDone = newStatus == OrderStatus.delivered;
      final isInTransit = newStatus == OrderStatus.inTransit;
      final isProcessing = newStatus == OrderStatus.processing;

      final updatedSteps = [
        OrderTrackingStep(
          title: 'Order Placed',
          description: 'Order confirmed with ${o.paymentMethod}',
          time: 'Confirmed',
          isCompleted: true,
          isCurrent: newStatus == OrderStatus.confirmed,
        ),
        OrderTrackingStep(
          title: 'Harvesting & Packing',
          description: 'Farmer is gathering your fresh farm produce',
          time: isProcessing || isInTransit || isDone ? 'Completed' : 'Pending',
          isCompleted: isProcessing || isInTransit || isDone,
          isCurrent: isProcessing,
        ),
        OrderTrackingStep(
          title: 'Out for Delivery',
          description: 'Rider Ranjith on route with chilled compartment',
          time: isInTransit || isDone ? 'En route' : 'Est. in 2 hours',
          isCompleted: isInTransit || isDone,
          isCurrent: isInTransit,
        ),
        OrderTrackingStep(
          title: 'Delivered',
          description: 'Package handed over to recipient successfully',
          time: isDone ? 'Completed' : 'Est. 12:00 PM',
          isCompleted: isDone,
          isCurrent: isDone,
        ),
      ];

      _orders[idx] = FarmOrder(
        id: o.id,
        orderDate: o.orderDate,
        status: newStatus,
        items: o.items,
        subtotal: o.subtotal,
        deliveryFee: o.deliveryFee,
        discount: o.discount,
        totalAmount: o.totalAmount,
        deliveryAddress: o.deliveryAddress,
        contactNumber: o.contactNumber,
        deliveryMethod: o.deliveryMethod,
        preferredDateTime: o.preferredDateTime,
        paymentMethod: o.paymentMethod,
        trackingSteps: updatedSteps,
      );
      notifyListeners();
    }
  }

  // ── Chat Actions ───────────────────────────────────────────────────────────
  void sendMessage(String chatId, String text) {
    final chat = _chats.firstWhere((c) => c.id == chatId,
        orElse: () => _chats.first);
    chat.messages.add(
      ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'me',
        text: text,
        time: DateTime.now(),
        isMe: true,
      ),
    );
    notifyListeners();
  }

  void markChatAsRead(String chatId) {
    final index = _chats.indexWhere((c) => c.id == chatId);
    if (index >= 0) {
      final chat = _chats[index];
      _chats[index] = ChatConversation(
        id: chat.id,
        name: chat.name,
        avatarUrl: chat.avatarUrl,
        lastMessage: chat.lastMessage,
        time: chat.time,
        unreadCount: 0,
        isOnline: chat.isOnline,
        role: chat.role,
        productContext: chat.productContext,
        messages: chat.messages,
      );
      notifyListeners();
    }
  }
}

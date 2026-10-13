import 'package:flutter/material.dart';
import '../../../core/supabase/supabase_config.dart';

import '../models/cart_item_model.dart';

import '../../buyer/services/buyer_profile_manager.dart';
import '../../orders_chat/models/chat_model.dart';
import '../../orders_chat/models/order_model.dart';
import '../../../core/services/order_lifecycle_manager.dart';
import '../../../services/chat_service.dart';

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

  // ── Chat State (Delegate to unified ChatService) ───────────────────────────
  final List<ChatConversation> _chats = [];
  List<ChatConversation> get chats =>
      ChatService.instance.conversations.isNotEmpty
          ? ChatService.instance.conversations
          : List.unmodifiable(_chats);

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

    // 3. Sync real orders from Supabase
    loadOrdersFromDatabase();
    loadCartFromDatabase();
  }

  Future<void> loadOrdersFromDatabase() async {
    if (!SupabaseConfig.isInitialized) return;
    try {
      final uid = SupabaseConfig.auth.currentUser?.id;
      final query = SupabaseConfig.client.from('orders').select();
      final rows = uid != null
          ? await query.eq('buyer_id', uid).order('order_date', ascending: false)
          : await query.order('order_date', ascending: false);

      if ((rows as List).isNotEmpty) {
        _orders.clear();
        for (final r in rows) {
          final row = Map<String, dynamic>.from(r as Map);
          final id = row['id']?.toString() ?? '';
          final totalNum = (row['total_amount'] as num?)?.toDouble() ?? 0.0;
          final statusStr = (row['status'] as String? ?? 'Pending').toLowerCase();
          final orderStatus = statusStr.contains('transit')
              ? OrderStatus.inTransit
              : (statusStr.contains('deliver')
                  ? OrderStatus.delivered
                  : (statusStr.contains('pack') || statusStr.contains('process')
                      ? OrderStatus.processing
                      : OrderStatus.confirmed));

          _orders.add(
            FarmOrder(
              id: id,
              orderDate: row['order_date'] != null
                  ? DateTime.tryParse(row['order_date'].toString()) ?? DateTime.now()
                  : DateTime.now(),
              status: orderStatus,
              items: const [],
              subtotal: totalNum,
              deliveryFee: 0.0,
              discount: 0.0,
              totalAmount: totalNum,
              deliveryAddress: row['delivery_address'] as String? ?? '',
              contactNumber: row['customer_phone'] as String? ?? '',
              deliveryMethod: 'Home Delivery',
              preferredDateTime: 'Pending Dispatch',
              paymentMethod: 'Cash on Delivery',
              trackingSteps: [
                OrderTrackingStep(
                  title: 'Order Placed',
                  description: 'Order recorded in system',
                  time: 'Confirmed',
                  isCompleted: true,
                ),
                OrderTrackingStep(
                  title: 'In Transit',
                  description:
                      'Assigned to driver: ${row['assigned_driver_name'] ?? 'Transit'}',
                  time: 'En route',
                  isCompleted: orderStatus == OrderStatus.inTransit ||
                      orderStatus == OrderStatus.delivered,
                  isCurrent: orderStatus == OrderStatus.inTransit,
                ),
                OrderTrackingStep(
                  title: 'Delivered',
                  description: 'Delivered to address',
                  time: 'Delivery completed',
                  isCompleted: orderStatus == OrderStatus.delivered,
                ),
              ],
            ),
          );
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[MarketplaceState] loadOrdersFromDatabase: $e');
    }
  }

  // ── Cart Actions ───────────────────────────────────────────────────────────
  String get _cartBuyerId {
    try {
      final id = BuyerProfileManager.instance.profile.id;
      return id.isNotEmpty ? id : 'buyer_primary';
    } catch (_) {
      return 'buyer_primary';
    }
  }

  String _cartRowId(String itemId) => '${_cartBuyerId}_$itemId';

  Future<void> _syncCartItem(CartItem item) async {
    if (!SupabaseConfig.isInitialized) return;
    try {
      await SupabaseConfig.client.from('cart_items').upsert({
        'id': _cartRowId(item.id),
        'buyer_id': _cartBuyerId,
        'product_name': item.name,
        'unit_price': item.price,
        'unit': item.unit,
        'quantity': item.quantity,
        'emoji': item.emoji,
        'farm_name': item.farmName,
        'image_url': item.imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[MarketplaceState] cart upsert note: $e');
    }
  }

  Future<void> _deleteCartItemRemote(String itemId) async {
    if (!SupabaseConfig.isInitialized) return;
    try {
      await SupabaseConfig.client
          .from('cart_items')
          .delete()
          .eq('id', _cartRowId(itemId));
    } catch (e) {
      debugPrint('[MarketplaceState] cart delete note: $e');
    }
  }

  Future<void> _clearCartRemote() async {
    if (!SupabaseConfig.isInitialized) return;
    try {
      await SupabaseConfig.client
          .from('cart_items')
          .delete()
          .eq('buyer_id', _cartBuyerId);
    } catch (e) {
      debugPrint('[MarketplaceState] cart clear note: $e');
    }
  }

  /// Reloads this buyer's cart from Supabase `cart_items` (reflects admin edits).
  Future<void> loadCartFromDatabase() async {
    if (!SupabaseConfig.isInitialized) return;
    try {
      final rows = await SupabaseConfig.client
          .from('cart_items')
          .select()
          .eq('buyer_id', _cartBuyerId)
          .order('created_at');
      if ((rows as List).isEmpty) return;
      _cartItems.clear();
      final prefix = '${_cartBuyerId}_';
      for (final r in rows) {
        final row = Map<String, dynamic>.from(r as Map);
        final rowId = row['id']?.toString() ?? '';
        _cartItems.add(CartItem(
          id: rowId.startsWith(prefix) ? rowId.substring(prefix.length) : rowId,
          name: row['product_name']?.toString() ?? 'Item',
          price: (row['unit_price'] as num?)?.toDouble() ?? 0,
          unit: row['unit']?.toString() ?? '/kg',
          quantity: (row['quantity'] as num?)?.toInt() ?? 1,
          emoji: row['emoji']?.toString() ?? '🥬',
          farmName: row['farm_name']?.toString() ?? '',
          imageUrl: row['image_url']?.toString(),
        ));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[MarketplaceState] loadCartFromDatabase: $e');
    }
  }

  void addToCart(CartItem item) {
    final index = _cartItems.indexWhere((i) => i.name == item.name);
    if (index >= 0) {
      _cartItems[index].quantity += item.quantity;
      _syncCartItem(_cartItems[index]);
    } else {
      _cartItems.add(item);
      _syncCartItem(item);
    }
    notifyListeners();
  }

  void updateQuantity(String id, int delta) {
    final index = _cartItems.indexWhere((i) => i.id == id);
    if (index >= 0) {
      final newQty = _cartItems[index].quantity + delta;
      if (newQty <= 0) {
        _cartItems.removeAt(index);
        _deleteCartItemRemote(id);
      } else {
        _cartItems[index].quantity = newQty;
        _syncCartItem(_cartItems[index]);
      }
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _cartItems.removeWhere((i) => i.id == id);
    _deleteCartItemRemote(id);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _clearCartRemote();
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
    _clearCartRemote();

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

  // ── Chat Actions (Unified Persistent ChatService) ─────────────────────────
  void sendMessage(String chatId, String text) {
    ChatService.instance.sendMessage(conversationId: chatId, text: text);
    notifyListeners();
  }

  void markChatAsRead(String chatId) {
    ChatService.instance.markChatAsRead(chatId);
    notifyListeners();
  }
}

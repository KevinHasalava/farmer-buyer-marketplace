import 'package:flutter/material.dart';

import '../../buyer/presentation/buyer_cart_screen.dart';
import '../../buyer/presentation/buyer_categories_screen.dart';
import '../../buyer/presentation/buyer_home_screen.dart';
import '../../buyer/presentation/buyer_profile_screen.dart';
import '../../buyer/presentation/widgets/buyer_bottom_nav.dart';
import '../../cart/models/cart_item_model.dart';
import '../../cart/services/cart_state.dart';
import '../models/chat_model.dart';
import '../models/order_model.dart';
import 'chat_detail_screen.dart';
import 'chat_list_screen.dart';
import 'order_tracking_screen.dart';
import '../../../services/chat_service.dart';
import '../../../core/localization/app_settings.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../../pre_order/presentation/pre_order_list_screen.dart';
import '../../pre_order/presentation/create_pre_order_screen.dart';

/// Clean, beautifully organized "Orders & Chat" screen aligned with the Farm2Home design system
class OrdersChatScreen extends StatefulWidget {
  const OrdersChatScreen({
    super.key,
    this.initialTab = 0, // 0 = Orders, 1 = Chat
  });

  final int initialTab;

  @override
  State<OrdersChatScreen> createState() => _OrdersChatScreenState();
}

class _OrdersChatScreenState extends State<OrdersChatScreen> {
  final MarketplaceState _state = MarketplaceState.instance;

  static const Color _forestGreen = Color(0xFF1B5E38);
  static const Color _emerald = Color(0xFF16A34A);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _pillBg = Color(0xFFF1F5F9);

  late int _selectedTab; // 0: Orders, 1: Chat
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Order status filter: 'All', 'Active', 'Delivered', 'Cancelled'
  String _selectedOrderFilter = 'All';

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _state.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  int get _activeOrdersCount {
    return _state.orders.where((o) =>
        o.status == OrderStatus.inTransit ||
        o.status == OrderStatus.confirmed ||
        o.status == OrderStatus.processing ||
        o.status == OrderStatus.pending).length;
  }

  int get _deliveredOrdersCount {
    return _state.orders.where((o) => o.status == OrderStatus.delivered).length;
  }

  int get _cancelledOrdersCount {
    return _state.orders.where((o) => o.status == OrderStatus.cancelled).length;
  }

  int get _totalUnreadChats {
    return _state.chats.fold(0, (sum, c) => sum + c.unreadCount);
  }

  void _reorderItems(FarmOrder order) {
    for (final item in order.items) {
      _state.addToCart(
        CartItem(
          id: 'reorder_${DateTime.now().millisecondsSinceEpoch}_${item.name.hashCode}',
          name: item.name,
          price: item.unitPrice,
          unit: '/${item.unit}',
          quantity: item.quantity,
          emoji: item.emoji,
          farmName: 'Sunil Perera Farm',
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${order.items.length} items from #${order.id} added to cart!'),
        backgroundColor: _forestGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: context.tr.viewCart,
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BuyerCartScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showOrderDetailsSheet(FarmOrder order) {
    final isInTransit = order.status == OrderStatus.inTransit ||
        order.status == OrderStatus.confirmed ||
        order.status == OrderStatus.processing ||
        order.status == OrderStatus.pending;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${context.tr.orderId} #${order.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.preferredDateTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: _borderColor),
            const SizedBox(height: 14),

            // Delivery Details
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 18, color: _forestGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${context.tr.deliverTo}: ${order.deliveryAddress}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _textDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_rounded, size: 18, color: _forestGreen),
                const SizedBox(width: 8),
                Text(
                  '${context.tr.contact}: ${order.contactNumber}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  '${context.tr.paymentMethod}: ${order.paymentMethod}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: _borderColor),
            const SizedBox(height: 14),

            Text(
              context.tr.itemsOrdered,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 10),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item.name} (${item.quantity} ${item.unit})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _textDark,
                        ),
                      ),
                    ),
                    Text(
                      'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: _borderColor),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Paid',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                Text(
                  'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _forestGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                if (isInTransit) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _forestGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 18),
                      label: Text(
                        context.tr.trackOrder,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderTrackingScreen(order: order),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _forestGreen,
                        side: const BorderSide(color: _forestGreen, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
                      label: Text(
                        context.tr.chat,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        final conv = ChatService.instance.getOrCreateConversation(
                          peerId: 'conv_driver_ranjith',
                          peerName: 'Ranjith Subha (Driver)',
                          peerRole: 'Driver',
                          phone: '+94 77 123 4567',
                          subtitle: 'Chilled Transit Van NC-4982 • Order #${order.id}',
                          orderId: order.id,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(
                              conversation: conv,
                              currentRole: 'buyer',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _forestGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.replay_rounded, color: Colors.white, size: 18),
                      label: Text(
                        context.tr.reorder,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _reorderItems(order);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _forestGreen,
                        side: const BorderSide(color: _forestGreen, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
                      label: Text(
                        context.tr.chat,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        final conv = ChatService.instance.getOrCreateConversation(
                          peerId: 'conv_sunil',
                          peerName: 'Sunil Perera (Farmer)',
                          peerRole: 'Farmer',
                          phone: '+94 77 123 4567',
                          subtitle: 'Hakgala Organic Farm • Order #${order.id}',
                          orderId: order.id,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailScreen(
                              conversation: conv,
                              currentRole: 'buyer',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgSoft,
      // ── Clean, Unified App Bar ─────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: _textDark,
                ),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 15, color: _textDark),
                decoration: InputDecoration(
                  hintText: _selectedTab == 1 ? context.tr.searchChatsHint : context.tr.searchOrdersHint,
                  hintStyle: const TextStyle(color: _textMuted, fontSize: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              )
            : Text(
                'Orders & Pre-Orders',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                  letterSpacing: -0.3,
                ),
              ),
        centerTitle: true,
        actions: [
          const Center(child: AppLanguagePill()),
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: _textDark,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: _textDark,
                  size: 23,
                ),
                if (_state.totalItemCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: const BoxDecoration(
                        color: _forestGreen,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_state.totalItemCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BuyerCartScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: _borderColor,
            height: 1,
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          // ── Segmented Pill Switcher (Orders | Chat) ────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _pillBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _borderColor),
              ),
              child: Row(
                children: [
                  // Orders Tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 0),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? _forestGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _selectedTab == 0
                              ? [
                                  BoxShadow(
                                    color: _forestGreen.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.tr.orders,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w600,
                                  color: _selectedTab == 0 ? Colors.white : _textMuted,
                                ),
                              ),
                              if (_activeOrdersCount > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 0
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$_activeOrdersCount',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedTab == 0 ? Colors.white : const Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Chat Tab
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 1),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? _forestGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: _selectedTab == 1
                              ? [
                                  BoxShadow(
                                    color: _forestGreen.withValues(alpha: 0.25),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Pre-Orders',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w600,
                                  color: _selectedTab == 1 ? Colors.white : _textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Tab Content ───────────────────────────────────────────────────
          Expanded(
            child: _selectedTab == 0
                ? _buildOrdersTabView()
                : _buildPreOrderTabView(),
          ),
        ],
      ),

      // ── Floating Action Button for Pre-Orders ───────────────────────────
      floatingActionButton: _selectedTab == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // We need to import CreatePreOrderScreen if not already, or we can just use the path
                    builder: (_) => const CreatePreOrderScreen(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF047857),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(context.tr.newRequest, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,

      // ── Unified 5-Tab Buyer Bottom Nav ────────────────────────────────────
      bottomNavigationBar: BuyerBottomNav(
        selectedIndex: 2,
        onTabSelected: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const BuyerHomeScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const BuyerCategoriesScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 2:
              setState(() => _selectedTab = 0);
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const ChatListScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const BuyerProfileScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
          }
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ORDERS TAB VIEW (Clean, Well-Organized, High-End Card Layout)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildOrdersTabView() {
    final filterOptions = [
      {'key': 'All', 'label': context.tr.filterAll, 'count': _state.orders.length},
      {'key': 'Active', 'label': context.tr.filterActive, 'count': _activeOrdersCount},
      {'key': 'Delivered', 'label': context.tr.filterDelivered, 'count': _deliveredOrdersCount},
      {'key': 'Cancelled', 'label': context.tr.filterCancelled, 'count': _cancelledOrdersCount},
    ];

    final filteredOrders = _state.orders.where((o) {
      if (_searchQuery.isNotEmpty) {
        final matchesId = o.id.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesItem = o.items.any((i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase()));
        if (!matchesId && !matchesItem) return false;
      }

      if (_selectedOrderFilter == 'All') return true;
      if (_selectedOrderFilter == 'Active') {
        return o.status == OrderStatus.inTransit ||
            o.status == OrderStatus.confirmed ||
            o.status == OrderStatus.processing ||
            o.status == OrderStatus.pending;
      }
      if (_selectedOrderFilter == 'Delivered') {
        return o.status == OrderStatus.delivered;
      }
      if (_selectedOrderFilter == 'Cancelled') {
        return o.status == OrderStatus.cancelled;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Status Filter Chips
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filterOptions.length,
            itemBuilder: (context, i) {
              final opt = filterOptions[i];
              final key = opt['key'] as String;
              final label = opt['label'] as String;
              final count = opt['count'] as int;
              final isSel = key == _selectedOrderFilter;

              return GestureDetector(
                onTap: () => setState(() => _selectedOrderFilter = key),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSel ? _forestGreen : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSel ? _forestGreen : _borderColor,
                    ),
                    boxShadow: isSel
                        ? [
                            BoxShadow(
                              color: _forestGreen.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                          color: isSel ? Colors.white : _textMuted,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSel
                              ? Colors.white.withValues(alpha: 0.25)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isSel ? Colors.white : _textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Orders List
        Expanded(
          child: filteredOrders.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFC8E6C9)),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            size: 34,
                            color: _forestGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? context.tr.noOrdersMatching(_searchQuery)
                              : context.tr.noOrdersFound,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tr.ordersEmptySub,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _textMuted,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _forestGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          icon: const Icon(Icons.storefront_rounded, color: Colors.white, size: 18),
                          label: Text(
                            context.tr.browseMarketplace,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BuyerCategoriesScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, i) {
                    final order = filteredOrders[i];
                    return _buildOrderCard(order);
                  },
                ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ORDER CARD WIDGET
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildOrderCard(FarmOrder order) {
    final isInTransit = order.status == OrderStatus.inTransit ||
        order.status == OrderStatus.confirmed ||
        order.status == OrderStatus.processing ||
        order.status == OrderStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDF2EF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showOrderDetailsSheet(order),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Card Header (ID, Date, Status Badge) ─────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF5EF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: _forestGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${order.id}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.preferredDateTime,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: _textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Status Badge
                    _buildStatusBadge(order.status),
                  ],
                ),

                // ── Transit Highlight Pill (if active) ────────────────────────
                if (isInTransit) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEDF2F7)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          size: 15,
                          color: _forestGreen,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            context.tr.dispatchedOnRoute(order.deliveryAddress.split(',').first.trim()),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            context.tr.liveBadge,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // ── Produce Items List ────────────────────────────────────────
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFEDF2F7)),
                          ),
                          child: Center(
                            child: Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${item.name} (${item.quantity} ${item.unit})',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: _textDark,
                            ),
                          ),
                        ),
                        Text(
                          'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // ── Total Amount & Primary Action ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr.totalAmount,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: _textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        if (isInTransit)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _forestGreen,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            icon: const Icon(
                              Icons.local_shipping_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: Text(
                              context.tr.trackOrder,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderTrackingScreen(order: order),
                                ),
                              );
                            },
                          )
                        else
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _forestGreen,
                              side: const BorderSide(color: _forestGreen, width: 1.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 9,
                              ),
                            ),
                            icon: const Icon(
                              Icons.replay_rounded,
                              size: 15,
                              color: _forestGreen,
                            ),
                            label: Text(
                              context.tr.reorder,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _forestGreen,
                              ),
                            ),
                            onPressed: () => _reorderItems(order),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bg;
    Color border;
    Color text;
    String label = status.localizedLabel(context);

    switch (status) {
      case OrderStatus.inTransit:
        bg = const Color(0xFFFEF3C7);
        border = const Color(0xFFFDE68A);
        text = const Color(0xFFB45309);
        break;
      case OrderStatus.delivered:
        bg = const Color(0xFFDCFCE7);
        border = const Color(0xFFBBF7D0);
        text = const Color(0xFF15803D);
        break;
      case OrderStatus.confirmed:
      case OrderStatus.processing:
        bg = const Color(0xFFDBEAFE);
        border = const Color(0xFFBFDBFE);
        text = const Color(0xFF1D4ED8);
        break;
      case OrderStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        border = const Color(0xFFFECACA);
        text = const Color(0xFFB91C1C);
        break;
      case OrderStatus.pending:
        bg = const Color(0xFFF3F4F6);
        border = const Color(0xFFE5E7EB);
        text = const Color(0xFF4B5563);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // PRE-ORDER TAB VIEW
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildPreOrderTabView() {
    return const PreOrderListScreen(isFarmerMode: false, isEmbedded: true);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CHAT TAB VIEW
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildChatTabView() {
    final filteredChats = _state.chats.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Chat List
        Expanded(
          child: filteredChats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFC8E6C9)),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 32,
                          color: _forestGreen,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _searchQuery.isNotEmpty
                            ? context.tr.noChatsMatching(_searchQuery)
                            : context.tr.noChatsYet,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr.chatsEmptySub,
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: filteredChats.length,
                  separatorBuilder: (context, i) => const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 78,
                    endIndent: 16,
                    color: Color(0xFFF1F5F9),
                  ),
                  itemBuilder: (context, index) {
                    final chat = filteredChats[index];
                    return _buildChatItem(chat);
                  },
                ),
        ),

        // "View All Chats" Button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _forestGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatListScreen(currentRole: 'buyer'),
                  ),
                );
              },
              child: Text(
                context.tr.viewAllChats,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatItem(ChatConversation chat) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(conversation: chat),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Circular Avatar with fallback & online dot
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE2E8F0),
                    image: DecorationImage(
                      image: NetworkImage(chat.avatarUrl),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    ),
                  ),
                  child: chat.avatarUrl.isEmpty
                      ? Center(
                          child: Text(
                            chat.name.substring(0, 1),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _forestGreen,
                            ),
                          ),
                        )
                      : null,
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _emerald,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.2),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // Name and snippet
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          chat.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.role.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            chat.role,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _forestGreen,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    chat.lastMessage,
                    style: TextStyle(
                      fontSize: 13,
                      color: chat.unreadCount > 0 ? _textDark : _textMuted,
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Time and unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: _textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (chat.unreadCount > 0)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: _forestGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${chat.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

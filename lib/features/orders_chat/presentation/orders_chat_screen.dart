import 'package:flutter/material.dart';

import '../../cart/services/cart_state.dart';
import '../models/chat_model.dart';
import '../models/order_model.dart';
import 'chat_detail_screen.dart';
import 'order_tracking_screen.dart';

/// Pixel-perfect "Orders & Chat" screen matching Image 1
class OrdersChatScreen extends StatefulWidget {
  const OrdersChatScreen({
    super.key,
    this.initialTab = 1, // Default to Chat as in the reference image (0 = Orders, 1 = Chat)
  });

  final int initialTab;

  @override
  State<OrdersChatScreen> createState() => _OrdersChatScreenState();
}

class _OrdersChatScreenState extends State<OrdersChatScreen> {
  final MarketplaceState _state = MarketplaceState.instance;

  static const Color _forestGreen = Color(0xFF286A46);
  static const Color _bgSoft = Color(0xFFFAFCFA);
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _pillBg = Color(0xFFF1F5F3);
  static const Color _dividerColor = Color(0xFFEDF2F0);

  late int _selectedTab; // 0: Orders, 1: Chat
  int _selectedBottomNav = 1; // 0: Home, 1: Orders (has badge dot in image), 2: Chat, 3: Profile

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Order status filter
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgSoft,
      // ── App Bar matching Image 1 ──────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: _textDark,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 16, color: _textDark),
                decoration: InputDecoration(
                  hintText: _selectedTab == 1 ? 'Search chats...' : 'Search orders...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              )
            : const Text(
                'Orders & Chat',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                  letterSpacing: -0.3,
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: _textDark,
              size: 24,
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
          const SizedBox(width: 4),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 8),

          // ── Pill Segmented Switcher (Orders | Chat) ────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _pillBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  // Orders Pill
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
                        ),
                        child: Center(
                          child: Text(
                            'Orders',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: _selectedTab == 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _selectedTab == 0
                                  ? Colors.white
                                  : const Color(0xFF4A5568),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Chat Pill
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
                        ),
                        child: Center(
                          child: Text(
                            'Chat',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: _selectedTab == 1
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _selectedTab == 1
                                  ? Colors.white
                                  : const Color(0xFF4A5568),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Tab Content ───────────────────────────────────────────────────
          Expanded(
            child: _selectedTab == 1
                ? _buildChatTabView()
                : _buildOrdersTabView(),
          ),
        ],
      ),

      // ── Bottom Navigation Bar matching Image 1 ─────────────────────────────
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CHAT TAB VIEW (Exact match to Image 1)
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
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No chats matching "$_searchQuery"'
                            : 'No conversations yet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredChats.length,
                  separatorBuilder: (context, i) => const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 76,
                    endIndent: 16,
                    color: _dividerColor,
                  ),
                  itemBuilder: (context, index) {
                    final chat = filteredChats[index];
                    return _buildChatItem(chat);
                  },
                ),
        ),

        // "View All Chats" Button matching Image 1
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _forestGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Showing all active buyer & farmer conversations'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'View All Chats',
                style: TextStyle(
                  fontSize: 16,
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
            // Circular Avatar with fallback
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
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
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
                  Text(
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
                  const SizedBox(height: 3),
                  Text(
                    chat.lastMessage,
                    style: TextStyle(
                      fontSize: 13,
                      color: chat.unreadCount > 0
                          ? const Color(0xFF475569)
                          : const Color(0xFF94A3B8),
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.w500
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
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
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

  // ───────────────────────────────────────────────────────────────────────────
  // ORDERS TAB VIEW
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildOrdersTabView() {
    final filters = ['All', 'Active', 'Delivered', 'Cancelled'];

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
            o.status == OrderStatus.processing;
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
        // Status filter chips
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            itemBuilder: (context, i) {
              final f = filters[i];
              final isSel = f == _selectedOrderFilter;
              return GestureDetector(
                onTap: () => setState(() => _selectedOrderFilter = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? _forestGreen : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSel ? _forestGreen : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Orders list
        Expanded(
          child: filteredOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          size: 48, color: Color(0xFFCBD5E1)),
                      const SizedBox(height: 12),
                      Text(
                        'No $_selectedOrderFilter orders found',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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

  Widget _buildOrderCard(FarmOrder order) {
    final isInTransit = order.status == OrderStatus.inTransit ||
        order.status == OrderStatus.confirmed ||
        order.status == OrderStatus.processing;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDF2EF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5EF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: _forestGreen,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.id}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      Text(
                        order.preferredDateTime,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isInTransit
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isInTransit
                        ? const Color(0xFFB45309)
                        : const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Items summary
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
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
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Total and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isInTransit)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _forestGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderTrackingScreen(order: order),
                          ),
                        );
                      },
                      child: const Text(
                        'Track Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _forestGreen,
                        side: const BorderSide(color: _forestGreen, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Items from #${order.id} added to cart!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text(
                        'Reorder',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BOTTOM NAV (Exact replica of Image 1)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F5F3), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home
          _buildNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            isSelected: _selectedBottomNav == 0,
            hasBadgeDot: false,
            onTap: () {
              Navigator.popUntil(context, (r) => r.isFirst);
            },
          ),

          // Orders (has green indicator dot in Image 1!)
          _buildNavItem(
            icon: Icons.assignment_outlined,
            label: 'Orders',
            isSelected: _selectedBottomNav == 1 && _selectedTab == 0,
            hasBadgeDot: true, // Matching Image 1 green badge dot!
            onTap: () {
              setState(() {
                _selectedBottomNav = 1;
                _selectedTab = 0; // Switch to orders
              });
            },
          ),

          // Chat
          _buildNavItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            isSelected: _selectedBottomNav == 2 || (_selectedBottomNav == 1 && _selectedTab == 1),
            hasBadgeDot: false,
            onTap: () {
              setState(() {
                _selectedBottomNav = 2;
                _selectedTab = 1; // Switch to chat
              });
            },
          ),

          // Profile
          _buildNavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            isSelected: _selectedBottomNav == 3,
            hasBadgeDot: false,
            onTap: () {
              setState(() => _selectedBottomNav = 3);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required bool hasBadgeDot,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? _forestGreen : const Color(0xFF64748B),
                ),
                if (hasBadgeDot)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _forestGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _forestGreen : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

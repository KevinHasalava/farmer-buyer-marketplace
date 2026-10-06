import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_router.dart';
import '../../cart/models/cart_item_model.dart';
import '../../cart/services/cart_state.dart';
import '../models/buyer_notification_model.dart';
import '../services/buyer_notification_service.dart';
import '../services/buyer_profile_manager.dart';
import 'buyer_profile_screen.dart';

/// 25. Buyer Notifications Screen — matching Screenshot 25
class BuyerNotificationsScreen extends StatefulWidget {
  const BuyerNotificationsScreen({super.key});

  @override
  State<BuyerNotificationsScreen> createState() =>
      _BuyerNotificationsScreenState();
}

class _BuyerNotificationsScreenState extends State<BuyerNotificationsScreen> {
  final BuyerNotificationService _notifService =
      BuyerNotificationService.instance;
  final BuyerProfileManager _profileManager = BuyerProfileManager.instance;
  final MarketplaceState _cartState = MarketplaceState.instance;

  BuyerNotificationCategory _selectedCategory = BuyerNotificationCategory.all;

  static const Color _forestGreen = Color(0xFF1B5E38);
  static const Color _emerald = Color(0xFF16A34A);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _notifService.addListener(_onChanged);
  }

  @override
  void dispose() {
    _notifService.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  List<BuyerNotificationItem> get _filteredItems {
    switch (_selectedCategory) {
      case BuyerNotificationCategory.all:
        return _notifService.items;
      case BuyerNotificationCategory.orders:
        return _notifService.orderNotifications;
      case BuyerNotificationCategory.harvestAlerts:
        return _notifService.harvestAlertNotifications;
    }
  }

  void _showDriverCallDialog(BuyerNotificationItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.phone_in_talk_rounded, color: _forestGreen),
            SizedBox(width: 10),
            Text('Contact Driver', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Driver: ${item.driverName ?? "Ranjith"}'),
            const SizedBox(height: 4),
            Text('Vehicle: ${item.vanNumber ?? "#WP-NC-4882"}'),
            const SizedBox(height: 8),
            Text(
              'Calling ${item.driverPhone}...',
              style: const TextStyle(fontWeight: FontWeight.w700, color: _forestGreen),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling ${item.driverName ?? "Driver"}...'),
                  backgroundColor: _forestGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _forestGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _showTrackDriverModal(BuyerNotificationItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
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
                Row(
                  children: const [
                    Icon(Icons.near_me_rounded, color: _forestGreen),
                    SizedBox(width: 8),
                    Text(
                      'Live Transit Tracking',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '500m Away',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _forestGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(item.driverPhoto ??
                                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.driverName ?? 'Ranjith Premadasa',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _textDark),
                            ),
                            Text(
                              item.driverRating ?? '★ 4.9 (420+ safe drop-offs)',
                              style: const TextStyle(fontSize: 11, color: _textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Transit Route:', style: TextStyle(fontSize: 11.5, color: _textMuted)),
                      const Text('Havelock Rd ➔ Colombo Hub Route', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _textDark)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cash on Delivery:', style: TextStyle(fontSize: 11.5, color: _textMuted)),
                      Text(item.amountDue ?? 'Rs. 1,760', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _forestGreen)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.check_rounded, color: Colors.white),
                label: const Text('Acknowledge Gate Arrival', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _forestGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addStrawberriesToCart() {
    HapticFeedback.lightImpact();
    _cartState.addToCart(
      CartItem(
        id: 'strawberries-01',
        name: 'Fresh Mountain Strawberries',
        price: 950.0,
        unit: '/400g punnet',
        quantity: 1,
        emoji: '🍓',
        farmName: 'Hakgala Organic Farm',
        imageUrl:
            'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=800&auto=format&fit=crop&q=80',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added Fresh Mountain Strawberries (Rs. 950) to cart!'),
        backgroundColor: _forestGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addTomatoesToCart() {
    HapticFeedback.lightImpact();
    _cartState.addToCart(
      CartItem(
        id: 'tomatoes-peak',
        name: 'Grade-A Cooking Tomatoes',
        price: 260.0,
        unit: '/kg',
        quantity: 1,
        emoji: '🍅',
        farmName: 'Dambulla Cooperative',
        imageUrl:
            'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=200&auto=format&fit=crop&q=80',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added Grade-A Cooking Tomatoes (Rs. 260/kg) to cart!'),
        backgroundColor: _forestGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profileManager.profile;
    final totalAll = _notifService.items.length;
    final totalOrders = _notifService.orderNotifications.length;
    final totalHarvest = _notifService.harvestAlertNotifications.length;

    return Scaffold(
      backgroundColor: _bgSoft,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        context.go(AppRoutes.dashboard);
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: _borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: _textDark, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Brand name / logo
                  Expanded(
                    child: Row(
                      children: const [
                        Icon(Icons.eco_rounded, size: 18, color: _forestGreen),
                        SizedBox(width: 6),
                        Text(
                          'Farm2Home',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3 Dots popup menu
                  PopupMenuButton<String>(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: _borderColor),
                      ),
                      child: const Icon(Icons.more_vert_rounded, color: _textDark, size: 19),
                    ),
                    onSelected: (val) {
                      if (val == 'markAll') {
                        _notifService.markAllAsRead();
                      } else if (val == 'clear') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notifications are managed in real-time.'),
                            backgroundColor: _forestGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'markAll',
                        child: Text('Mark all as read'),
                      ),
                      const PopupMenuItem(
                        value: 'clear',
                        child: Text('Notification settings'),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),

                  // Profile Avatar
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BuyerProfileScreen()),
                    ),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE8F5E9),
                        border: Border.all(color: _emerald, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          profile.initials,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _forestGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Header Row: Title, Subtitle & Mark read button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Text(
                              '🌿 Notifications',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Real-time updates on harvests, deliveries, and deals.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: _textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _notifService.markAllAsRead();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All notifications marked as read!'),
                          backgroundColor: _forestGreen,
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check_rounded, size: 13, color: Color(0xFF2563EB)),
                          SizedBox(width: 4),
                          Text(
                            'Mark read',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Tabs Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTabPill('All ($totalAll)', BuyerNotificationCategory.all),
                  const SizedBox(width: 8),
                  _buildTabPill('Orders ($totalOrders)', BuyerNotificationCategory.orders),
                  const SizedBox(width: 8),
                  _buildTabPill('Harvest Alerts ($totalHarvest)', BuyerNotificationCategory.harvestAlerts),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Notifications List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  ..._filteredItems.map((item) => _buildNotificationCard(item)),

                  const SizedBox(height: 14),

                  // Notification Preferences Card at bottom matching Screenshot 25
                  _buildPreferencesCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill(String label, BuyerNotificationCategory cat) {
    final isSelected = _selectedCategory == cat;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = cat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _forestGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _forestGreen : _borderColor,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: _forestGreen.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : _textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuyerNotificationItem item) {
    switch (item.type) {
      case BuyerNotificationType.driverAlert:
        return _buildDriverAlertCard(item);
      case BuyerNotificationType.harvestAlert:
        return _buildHarvestAlertCard(item);
      case BuyerNotificationType.dispatched:
        return _buildDispatchedCard(item);
      case BuyerNotificationType.delivered:
        return _buildDeliveredCard(item);
      case BuyerNotificationType.priceDrop:
        return _buildPriceDropCard(item);
    }
  }

  // 1. Driver Approaching Card matching Screenshot 25
  Widget _buildDriverAlertCard(BuyerNotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: item.isRead ? _borderColor : const Color(0xFF86EFAC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.local_shipping_rounded, color: _forestGreen, size: 18),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.tag,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '• ${item.timeAgo}',
                style: const TextStyle(fontSize: 10.5, color: _textMuted),
              ),
              const Spacer(),
              if (!item.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _emerald,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            item.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark),
          ),
          const SizedBox(height: 4),

          // Message
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.35),
              children: [
                TextSpan(text: 'Driver Ranjith is 500m away on Havelock Rd in van #WP-NC-4882. Please prepare '),
                TextSpan(
                  text: item.amountDue ?? 'Rs. 1,760',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: _forestGreen),
                ),
                const TextSpan(text: ' for Cash on Delivery.'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Driver Mini Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(item.driverPhoto ??
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.driverName ?? 'Ranjith Premadasa',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: _textDark),
                      ),
                      Text(
                        item.driverRating ?? '★ 4.9 (420+ safe drop-offs)',
                        style: const TextStyle(fontSize: 10.5, color: _textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Text(
                    item.driverDistance ?? '500m away',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _notifService.markAsRead(item.id);
                    _showTrackDriverModal(item);
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: _forestGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.near_me_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Track Driver Live',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  _notifService.markAsRead(item.id);
                  _showDriverCallDialog(item);
                },
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.phone_outlined, color: _forestGreen, size: 15),
                      SizedBox(width: 4),
                      Text(
                        'Call',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _forestGreen),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Strawberries Harvest Alert Card matching Screenshot 25
  Widget _buildHarvestAlertCard(BuyerNotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: item.isRead ? _borderColor : const Color(0xFF86EFAC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco_rounded, color: _forestGreen, size: 18),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.tag,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '• ${item.timeAgo}',
                style: const TextStyle(fontSize: 10.5, color: _textMuted),
              ),
              const Spacer(),
              if (!item.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _emerald,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            item.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark),
          ),
          const SizedBox(height: 4),

          // Message
          Text(
            item.message,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.35),
          ),
          const SizedBox(height: 12),

          // Image Banner with Overlay
          Container(
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(item.imageUrl ??
                    'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=800&auto=format&fit=crop&q=80'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.harvestTimeText ?? 'Harvested at 6:00 AM today',
                        style: const TextStyle(fontSize: 10, color: Color(0xFFE2E8F0)),
                      ),
                      Text(
                        item.priceText ?? 'Rs. 950 /400g punnet',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      item.stockLeftText ?? 'Only 8 punnets left',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Full width action button
          GestureDetector(
            onTap: () {
              _notifService.markAsRead(item.id);
              _addStrawberriesToCart();
            },
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.shopping_bag_outlined, color: Color(0xFF2563EB), size: 15),
                  SizedBox(width: 6),
                  Text(
                    'View Harvest & Reserve',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Dispatched Card matching Screenshot 25
  Widget _buildDispatchedCard(BuyerNotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF0284C7), size: 18),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.tag,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0284C7)),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '• ${item.timeAgo}',
                style: const TextStyle(fontSize: 10.5, color: _textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            item.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark),
          ),
          const SizedBox(height: 4),

          // Message with Temperature Highlight
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.35),
              children: [
                TextSpan(text: 'Chilled van departed highland corridor at 10:15 AM with temperature logged at '),
                TextSpan(
                  text: '12°C',
                  style: TextStyle(fontWeight: FontWeight.w800, color: _forestGreen),
                ),
                TextSpan(text: ' for maximum crispness.'),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Badges Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.ac_unit_rounded, size: 12, color: _forestGreen),
                    SizedBox(width: 4),
                    Text(
                      'Cold-chain certified',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _forestGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _borderColor),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified_outlined, size: 12, color: _textMuted),
                    SizedBox(width: 4),
                    Text(
                      'Eco-crate sealed',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Delivered & Rating Card matching Screenshot 25
  Widget _buildDeliveredCard(BuyerNotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEDD5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFFEA580C), size: 18),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.tag,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFC2410C)),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '• ${item.timeAgo}',
                style: const TextStyle(fontSize: 10.5, color: _textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            item.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark),
          ),
          const SizedBox(height: 4),

          // Message
          Text(
            item.message,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.35),
          ),
          const SizedBox(height: 12),

          // Star Rating Row
          Row(
            children: [
              const Text(
                'Tap to rate:',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _textDark),
              ),
              const SizedBox(width: 8),
              ...List.generate(5, (index) {
                final isSelected = index < item.userRating;
                return GestureDetector(
                  onTap: () {
                    _notifService.rateOrder(item.id, index + 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Rated ${index + 1} stars! +50 Fresh Harvest coins added.'),
                        backgroundColor: _forestGreen,
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(
                      isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 20,
                      color: isSelected ? const Color(0xFFEAB308) : const Color(0xFFCBD5E1),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),

          // Leave Review Button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening review form (+50 coins earned upon submission)'),
                  backgroundColor: _forestGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.rate_review_outlined, color: _forestGreen, size: 15),
                  SizedBox(width: 6),
                  Text(
                    'Leave Review (+50 Coins)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _forestGreen),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Price Drop Alert Card matching Screenshot 25
  Widget _buildPriceDropCard(BuyerNotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEDD5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sell_outlined, color: Color(0xFFEA580C), size: 18),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.tag,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFC2410C)),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '• ${item.timeAgo}',
                style: const TextStyle(fontSize: 10.5, color: _textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            item.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark),
          ),
          const SizedBox(height: 4),

          // Message
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.35),
              children: [
                TextSpan(text: 'Abundant harvest at Dambulla cooperative. Grade-A cooking tomatoes now at '),
                TextSpan(
                  text: 'Rs. 260/kg',
                  style: TextStyle(fontWeight: FontWeight.w800, color: _forestGreen),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Mini Product Bar with Add button
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(item.imageUrl ??
                          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=200&auto=format&fit=crop&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.discountedPriceText ?? 'Rs. 260',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _forestGreen),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.originalPriceText ?? 'Rs. 320',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF94A3B8),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Direct farm gate pricing active',
                        style: TextStyle(fontSize: 10, color: _textMuted),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _addTomatoesToCart,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: _forestGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. Notification Preferences Card at bottom matching Screenshot 25
  Widget _buildPreferencesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.tune_rounded, color: _forestGreen, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Notification Preferences',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Customize notification channels: Push notifications, SMS alerts for driver arrival.',
                      style: TextStyle(fontSize: 10.5, color: _textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Switch 1: Push Notifications
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, size: 18, color: _textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Push Notifications',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark),
                    ),
                    Text(
                      'Instant harvest & status updates',
                      style: TextStyle(fontSize: 10, color: _textMuted),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _notifService.pushNotificationsEnabled,
                activeThumbColor: _forestGreen,
                onChanged: (val) => _notifService.togglePushNotifications(val),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Switch 2: SMS Driver Gate Alert
          Row(
            children: [
              const Icon(Icons.sms_outlined, size: 18, color: _textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'SMS Driver Gate Alert',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark),
                    ),
                    Text(
                      'Free SMS when driver is 500m away',
                      style: TextStyle(fontSize: 10, color: _textMuted),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _notifService.smsDriverAlertEnabled,
                activeThumbColor: _forestGreen,
                onChanged: (val) => _notifService.toggleSmsDriverAlert(val),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 100% Freshness Guarantee note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.shield_outlined, size: 16, color: _forestGreen),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '100% Freshness Guarantee: If fresh mountain produce arrives damaged, alert us within 4 hours for an instant replacement.',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF166534), height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

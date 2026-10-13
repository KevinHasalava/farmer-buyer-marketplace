import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_settings.dart';
import '../../../core/routes/app_router.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../../cart/models/cart_item_model.dart';
import '../../cart/services/cart_state.dart';
import '../models/buyer_notification_model.dart';
import '../services/buyer_notification_service.dart';
import '../services/buyer_profile_manager.dart';
import 'buyer_cart_screen.dart';
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
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: _forestGreen),
            const SizedBox(width: 10),
            Text(context.tr.contactDriver, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${context.tr.driverLabel}: ${item.driverName ?? "Ranjith"}'),
            const SizedBox(height: 4),
            Text('${context.tr.vehicleLabel}: ${item.vanNumber ?? "#WP-NC-4882"}'),
            const SizedBox(height: 8),
            Text(
              '${context.tr.callingDriver} ${item.driverPhone}...',
              style: const TextStyle(fontWeight: FontWeight.w700, color: _forestGreen),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${context.tr.callingDriver} ${item.driverName ?? context.tr.driverLabel}...'),
                  backgroundColor: _forestGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _forestGreen,
              foregroundColor: Colors.white,
            ),
            child: Text(context.tr.callNow),
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
                  children: [
                    const Icon(Icons.near_me_rounded, color: _forestGreen),
                    const SizedBox(width: 8),
                    Text(
                      context.tr.liveTransitTracking,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    context.tr.away500m,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _forestGreen),
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
                      Text('${context.tr.transitRoute}:', style: const TextStyle(fontSize: 11.5, color: _textMuted)),
                      const Text('Havelock Rd ➔ Colombo Hub Route', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _textDark)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${context.tr.cashOnDelivery}:', style: const TextStyle(fontSize: 11.5, color: _textMuted)),
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
                label: Text(context.tr.acknowledgeArrival, style: const TextStyle(fontWeight: FontWeight.w700)),
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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added Fresh Mountain Strawberries (Rs. 950) to cart!'),
        backgroundColor: _forestGreen,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: const Color(0xFFFDE68A),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BuyerCartScreen()),
            );
          },
        ),
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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Added Grade-A Cooking Tomatoes (Rs. 260/kg) to cart!'),
        backgroundColor: _forestGreen,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: const Color(0xFFFDE68A),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BuyerCartScreen()),
            );
          },
        ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOrEditNotificationDialog(),
        backgroundColor: _forestGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_alert_rounded, size: 20),
        label: const Text(
          'New Alert',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
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
                        Expanded(
                          child: Text(
                            'Farm2Home',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _textDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Language Switcher Pill
                  const AppLanguagePill(),
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

            // Header Row: Title, Subtitle & Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '🌿 ${context.tr.notifications}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          context.tr.notificationsSub,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: _textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // + Add Alert (CREATE)
                      GestureDetector(
                        onTap: () => _showCreateOrEditNotificationDialog(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded, size: 14, color: _forestGreen),
                              SizedBox(width: 3),
                              Text(
                                'Alert',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _forestGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Mark all read (UPDATE)
                      GestureDetector(
                        onTap: () {
                          _notifService.markAllAsRead();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.tr.allNotificationsMarkedRead),
                              backgroundColor: _forestGreen,
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFDBEAFE)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_rounded, size: 13, color: Color(0xFF2563EB)),
                              const SizedBox(width: 3),
                              Text(
                                context.tr.markAllRead,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Clear All (DELETE ALL)
                      GestureDetector(
                        onTap: _confirmClearAllNotifications,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: const Icon(Icons.delete_sweep_rounded, size: 15, color: Color(0xFFDC2626)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filter Tabs Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTabPill('${context.tr.filterAll} ($totalAll)', BuyerNotificationCategory.all),
                  const SizedBox(width: 8),
                  _buildTabPill('${context.tr.filterOrders} ($totalOrders)', BuyerNotificationCategory.orders),
                  const SizedBox(width: 8),
                  _buildTabPill('${context.tr.filterHarvestAlerts} ($totalHarvest)', BuyerNotificationCategory.harvestAlerts),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Notifications List / Empty State
            if (_filteredItems.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDCFCE7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_none_rounded, size: 40, color: _forestGreen),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Notifications Here',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'You\'re all caught up! Create a custom alert or wait for farm updates.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: _textMuted),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateOrEditNotificationDialog(),
                          icon: const Icon(Icons.add_alert_rounded, size: 18),
                          label: const Text('Create New Alert'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _forestGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  children: [
                    ..._filteredItems.map((item) => _buildNotificationCard(item)),
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
    Widget card;
    switch (item.type) {
      case BuyerNotificationType.driverAlert:
        card = _buildDriverAlertCard(item);
        break;
      case BuyerNotificationType.harvestAlert:
        card = _buildHarvestAlertCard(item);
        break;
      case BuyerNotificationType.dispatched:
        card = _buildDispatchedCard(item);
        break;
      case BuyerNotificationType.delivered:
        card = _buildDeliveredCard(item);
        break;
      case BuyerNotificationType.priceDrop:
        card = _buildPriceDropCard(item);
        break;
      case BuyerNotificationType.general:
        card = _buildGeneralCard(item);
        break;
    }
    return _wrapNotificationCard(item, card);
  }

  /// Wraps card with swipe-to-delete Dismissible and 3-dots popup options
  Widget _wrapNotificationCard(BuyerNotificationItem item, Widget card) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
            SizedBox(width: 6),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        _notifService.deleteNotification(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification removed'),
            backgroundColor: _forestGreen,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Stack(
        children: [
          card,
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, size: 18, color: _textMuted),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
              onSelected: (val) {
                if (val == 'toggle_read') {
                  if (item.isRead) {
                    _notifService.markAsUnread(item.id);
                  } else {
                    _notifService.markAsRead(item.id);
                  }
                } else if (val == 'edit') {
                  _showCreateOrEditNotificationDialog(existing: item);
                } else if (val == 'delete') {
                  _confirmDeleteNotification(item);
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'toggle_read',
                  child: Row(
                    children: [
                      Icon(
                        item.isRead
                            ? Icons.mark_email_unread_outlined
                            : Icons.mark_email_read_outlined,
                        size: 18,
                        color: _forestGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(item.isRead ? 'Mark unread' : 'Mark read',
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2563EB)),
                      SizedBox(width: 8),
                      Text('Edit notification', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 18, color: Color(0xFFDC2626)),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(fontSize: 13, color: Color(0xFFDC2626))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateOrEditNotificationDialog({BuyerNotificationItem? existing}) {
    final isNew = existing == null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final msgCtrl = TextEditingController(text: existing?.message ?? '');
    final tagCtrl = TextEditingController(text: existing?.tag ?? 'Alert');
    final produceCtrl = TextEditingController(text: existing?.produceName ?? '');
    BuyerNotificationCategory selectedCategory =
        existing?.category ?? BuyerNotificationCategory.orders;
    BuyerNotificationType selectedType =
        existing?.type ?? BuyerNotificationType.general;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_alert_rounded, color: _forestGreen, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                isNew ? 'Create New Alert' : 'Edit Notification',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark),
              ),
            ],
          ),
          content: SizedBox(
            width: 380,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<BuyerNotificationCategory>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        isDense: true,
                        prefixIcon: const Icon(Icons.category_outlined, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: BuyerNotificationCategory.orders,
                          child: Text('Orders & Delivery'),
                        ),
                        DropdownMenuItem(
                          value: BuyerNotificationCategory.harvestAlerts,
                          child: Text('Harvest & Price Alert'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setS(() => selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<BuyerNotificationType>(
                      initialValue: selectedType,
                      decoration: InputDecoration(
                        labelText: 'Alert Type',
                        isDense: true,
                        prefixIcon: const Icon(Icons.notifications_active_outlined, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: BuyerNotificationType.general,
                          child: Text('General Notification'),
                        ),
                        DropdownMenuItem(
                          value: BuyerNotificationType.harvestAlert,
                          child: Text('Harvest Alert 🍓'),
                        ),
                        DropdownMenuItem(
                          value: BuyerNotificationType.priceDrop,
                          child: Text('Price Drop 🍅'),
                        ),
                        DropdownMenuItem(
                          value: BuyerNotificationType.driverAlert,
                          child: Text('Driver Alert 🚚'),
                        ),
                        DropdownMenuItem(
                          value: BuyerNotificationType.dispatched,
                          child: Text('Order Dispatched 📦'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setS(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        isDense: true,
                        prefixIcon: const Icon(Icons.title_rounded, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: msgCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Message / Details',
                        isDense: true,
                        prefixIcon: const Icon(Icons.notes_rounded, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter details' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: produceCtrl,
                      decoration: InputDecoration(
                        labelText: 'Produce Name (optional)',
                        hintText: 'e.g. Red Carrots, Tomatoes',
                        isDense: true,
                        prefixIcon: const Icon(Icons.eco_rounded, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: _textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                if (isNew) {
                  await _notifService.createNotification(
                    title: titleCtrl.text.trim(),
                    message: msgCtrl.text.trim(),
                    type: selectedType,
                    category: selectedCategory,
                    tag: tagCtrl.text.trim().isEmpty ? 'Alert' : tagCtrl.text.trim(),
                    produceName: produceCtrl.text.trim().isEmpty ? null : produceCtrl.text.trim(),
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alert created successfully!'),
                        backgroundColor: _forestGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } else {
                  final updated = existing.copyWith(
                    title: titleCtrl.text.trim(),
                    message: msgCtrl.text.trim(),
                    type: selectedType,
                    category: selectedCategory,
                    produceName: produceCtrl.text.trim().isEmpty ? null : produceCtrl.text.trim(),
                  );
                  await _notifService.updateNotification(updated);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification updated!'),
                        backgroundColor: _forestGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: Text(isNew ? 'Create' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteNotification(BuyerNotificationItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Notification', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _notifService.deleteNotification(item.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification deleted'),
                  backgroundColor: Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAllNotifications() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to remove all notifications? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _notifService.deleteAllNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  backgroundColor: Color(0xFFDC2626),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  /// General / admin-broadcast notification card
  Widget _buildGeneralCard(BuyerNotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isRead ? _borderColor : const Color(0xFF86EFAC),
        ),
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _generalIcon(item.tag),
                  color: _emerald,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.tag,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _textMuted,
                          letterSpacing: 0.5),
                    ),
                    Text(
                      item.timeAgo,
                      style: const TextStyle(fontSize: 10, color: _textMuted),
                    ),
                  ],
                ),
              ),
              if (!item.isRead)
                GestureDetector(
                  onTap: () => _notifService.markAsRead(item.id),
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                        color: _emerald, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _textDark),
          ),
          const SizedBox(height: 4),
          Text(
            item.message,
            style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF475569),
                height: 1.35),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _notifService.markAsRead(item.id),
              style: TextButton.styleFrom(foregroundColor: _emerald),
              child: Text(
                item.isRead ? 'Read' : 'Mark as read',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _generalIcon(String tag) {
    final t = tag.toLowerCase();
    if (t.contains('offer')) return Icons.local_offer_rounded;
    if (t.contains('harvest') || t.contains('alert')) return Icons.eco_rounded;
    if (t.contains('deliver')) return Icons.local_shipping_rounded;
    if (t.contains('order')) return Icons.receipt_long_rounded;
    return Icons.notifications_rounded;
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
                      children: [
                        const Icon(Icons.near_me_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          context.tr.trackDriverLive,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
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
                    children: [
                      const Icon(Icons.phone_outlined, color: _forestGreen, size: 15),
                      const SizedBox(width: 4),
                      Text(
                        context.tr.call,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _forestGreen),
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
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: Color(0xFF2563EB), size: 15),
                  const SizedBox(width: 6),
                  Text(
                    context.tr.viewHarvestAndReserve,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF2563EB)),
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
                  children: [
                    const Icon(Icons.ac_unit_rounded, size: 12, color: _forestGreen),
                    const SizedBox(width: 4),
                    Text(
                      context.tr.coldChainCertified,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _forestGreen),
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
                  children: [
                    const Icon(Icons.verified_outlined, size: 12, color: _textMuted),
                    const SizedBox(width: 4),
                    Text(
                      context.tr.ecoCrateSealed,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textMuted),
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
              Text(
                context.tr.tapToRate,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _textDark),
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
                children: [
                  const Icon(Icons.rate_review_outlined, color: _forestGreen, size: 15),
                  const SizedBox(width: 6),
                  Text(
                    context.tr.leaveReviewCoins,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _forestGreen),
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
                      Text(
                        context.tr.farmGatePricingActive,
                        style: const TextStyle(fontSize: 10, color: _textMuted),
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
}

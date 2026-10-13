import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_config.dart';
import '../models/buyer_notification_model.dart';
import 'buyer_profile_manager.dart';

/// Buyer notification CRUD backed by the Supabase `notifications` table.
/// - Read:   loads notifications addressed to this buyer or broadcast to all
/// - Update: mark read / unread / mark all read
/// - Delete: remove a notification
/// - Live:   Supabase realtime keeps the list in sync with admin changes
class BuyerNotificationService extends ChangeNotifier {
  BuyerNotificationService._internal() {
    loadNotifications();
    _subscribeRealtime();
  }

  static final BuyerNotificationService instance =
      BuyerNotificationService._internal();
  factory BuyerNotificationService() => instance;

  static const String _kCacheKey = 'buyer_notifications_cache_v1';
  static const String _kPushKey = 'buyer_notif_push_enabled';
  static const String _kSmsKey = 'buyer_notif_sms_enabled';

  List<BuyerNotificationItem> _items = [];
  bool _isLoading = false;
  bool _pushNotificationsEnabled = true;
  bool _smsDriverAlertEnabled = true;
  bool _realtimeStarted = false;

  List<BuyerNotificationItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get smsDriverAlertEnabled => _smsDriverAlertEnabled;

  int get unreadCount => _items.where((i) => !i.isRead).length;

  List<BuyerNotificationItem> get orderNotifications => _items
      .where((i) => i.category == BuyerNotificationCategory.orders)
      .toList();

  List<BuyerNotificationItem> get harvestAlertNotifications => _items
      .where((i) => i.category == BuyerNotificationCategory.harvestAlerts)
      .toList();

  String get _buyerId {
    try {
      final id = BuyerProfileManager.instance.profile.id;
      return id.isNotEmpty ? id : 'buyer_primary';
    } catch (_) {
      return 'buyer_primary';
    }
  }

  void _subscribeRealtime() {
    if (_realtimeStarted || !SupabaseConfig.isInitialized) return;
    try {
      SupabaseConfig.client
          .channel('buyer-notifications-live')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'notifications',
            callback: (_) => loadNotifications(silent: true),
          )
          .subscribe();
      _realtimeStarted = true;
    } catch (e) {
      debugPrint('[BuyerNotificationService] realtime note: $e');
    }
  }

  /// READ: loads notifications from Supabase (falls back to local cache/defaults
  /// only when the table is not reachable yet).
  Future<void> loadNotifications({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      _pushNotificationsEnabled = prefs.getBool(_kPushKey) ?? true;
      _smsDriverAlertEnabled = prefs.getBool(_kSmsKey) ?? true;

      bool loadedFromDb = false;
      if (SupabaseConfig.isInitialized) {
        try {
          final id = _buyerId;
          final res = await SupabaseConfig.client
              .from('notifications')
              .select()
              .or('buyer_id.eq.$id,buyer_id.is.null')
              .order('created_at', ascending: false);

          _items = (res as List)
              .map((e) => BuyerNotificationItem.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList();
          loadedFromDb = true;
          await _saveToCache();
        } catch (e) {
          debugPrint('[BuyerNotificationService] DB load note: $e');
        }
      }

      if (!loadedFromDb && _items.isEmpty) {
        final cached = prefs.getString(_kCacheKey);
        if (cached != null) {
          try {
            final list = jsonDecode(cached) as List<dynamic>;
            _items = list
                .map((e) => BuyerNotificationItem.fromJson(
                    Map<String, dynamic>.from(e as Map)))
                .toList();
          } catch (_) {}
        }
        if (_items.isEmpty) {
          _items = _getDefaultNotifications();
          await _saveToCache();
        }
      }
    } catch (e) {
      if (_items.isEmpty) {
        _items = _getDefaultNotifications();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// UPDATE: mark one notification as read
  Future<void> markAsRead(String id) => _setRead(id, true);

  /// UPDATE: mark one notification as unread
  Future<void> markAsUnread(String id) => _setRead(id, false);

  Future<void> _setRead(String id, bool read) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx == -1 || _items[idx].isRead == read) return;
    _items[idx] = _items[idx].copyWith(isRead: read);
    notifyListeners();
    await _saveToCache();

    if (SupabaseConfig.isInitialized) {
      try {
        await SupabaseConfig.client
            .from('notifications')
            .update({'is_read': read}).eq('id', id);
      } catch (e) {
        debugPrint('[BuyerNotificationService] update note: $e');
      }
    }
  }

  /// UPDATE: mark all notifications as read
  Future<void> markAllAsRead() async {
    _items = _items.map((i) => i.copyWith(isRead: true)).toList();
    notifyListeners();
    await _saveToCache();

    if (SupabaseConfig.isInitialized) {
      try {
        final ids = _items.map((i) => i.id).toList();
        if (ids.isNotEmpty) {
          await SupabaseConfig.client
              .from('notifications')
              .update({'is_read': true}).inFilter('id', ids);
        }
      } catch (e) {
        debugPrint('[BuyerNotificationService] markAll note: $e');
      }
    }
  }

  /// DELETE: remove a notification
  Future<void> deleteNotification(String id) async {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
    await _saveToCache();

    if (SupabaseConfig.isInitialized) {
      try {
        await SupabaseConfig.client.from('notifications').delete().eq('id', id);
      } catch (e) {
        debugPrint('[BuyerNotificationService] delete note: $e');
      }
    }
  }

  /// Rate delivered order
  Future<void> rateOrder(String id, int rating) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(userRating: rating);
      notifyListeners();
      await _saveToCache();
    }
  }

  /// Toggle Push notifications
  Future<void> togglePushNotifications(bool val) async {
    _pushNotificationsEnabled = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPushKey, val);
  }

  /// Toggle SMS Driver Alert
  Future<void> toggleSmsDriverAlert(bool val) async {
    _smsDriverAlertEnabled = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSmsKey, val);
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString(_kCacheKey, jsonStr);
    } catch (_) {}
  }

  List<BuyerNotificationItem> _getDefaultNotifications() {
    final now = DateTime.now();
    return [
      BuyerNotificationItem(
        id: 'notif-1',
        type: BuyerNotificationType.driverAlert,
        tag: 'Order #FH-8821',
        timeAgo: '2m ago',
        createdAt: now.subtract(const Duration(minutes: 2)),
        isRead: false,
        title: 'Driver Approaching Your Gate! 🚚',
        message:
            'Driver Ranjith is 500m away on Havelock Rd in van #WP-NC-4882. Please prepare Rs. 1,760 for Cash on Delivery.',
        driverName: 'Ranjith Premadasa',
        driverPhoto:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80',
        driverRating: '★ 4.9 (420+ safe drop-offs)',
        driverDistance: '500m away',
        amountDue: 'Rs. 1,760',
        vanNumber: '#WP-NC-4882',
        driverPhone: '+94 77 982 1450',
      ),
      BuyerNotificationItem(
        id: 'notif-2',
        type: BuyerNotificationType.harvestAlert,
        category: BuyerNotificationCategory.harvestAlerts,
        tag: 'Farmer Bandara',
        timeAgo: '1h ago',
        createdAt: now.subtract(const Duration(hours: 1)),
        isRead: false,
        title: 'Fresh Nuwara Eliya Strawberries Just Listed! 🍓',
        message:
            'Hakgala Organic Farm just harvested 20kg of sweet mountain strawberries. Order early before stock runs out!',
        imageUrl:
            'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=800&auto=format&fit=crop&q=80',
        produceName: 'Fresh Mountain Strawberries',
        priceText: 'Rs. 950 /400g punnet',
        stockLeftText: 'Only 8 punnets left',
        harvestTimeText: 'Harvested at 6:00 AM today',
        productId: 'strawberries-01',
      ),
      BuyerNotificationItem(
        id: 'notif-3',
        type: BuyerNotificationType.dispatched,
        tag: 'Order #FH-8841',
        timeAgo: '3h ago',
        createdAt: now.subtract(const Duration(hours: 3)),
        isRead: true,
        title: 'Order #FH-8841 Dispatched from Hakgala Hub',
        message:
            'Chilled van departed highland corridor at 10:15 AM with temperature logged at 12°C for maximum crispness.',
        badges: const [
          'Cold-chain certified',
          'Eco-crate sealed',
        ],
      ),
      BuyerNotificationItem(
        id: 'notif-4',
        type: BuyerNotificationType.delivered,
        tag: 'Delivered',
        timeAgo: 'Yesterday',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
        title: 'Order #FH-8750 Delivered • How was your harvest?',
        message:
            'Your 3 kg Keppetipola Red Potatoes were delivered. Rate Farmer Sunil to earn fresh harvest reward coins.',
        userRating: 0,
        coinsReward: 50,
      ),
      BuyerNotificationItem(
        id: 'notif-5',
        type: BuyerNotificationType.priceDrop,
        category: BuyerNotificationCategory.harvestAlerts,
        tag: 'Price Drop Alert',
        timeAgo: '2 days ago',
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
        title: 'Dambulla Tomato Harvest Peak: 20% Off 🍅',
        message:
            'Abundant harvest at Dambulla cooperative. Grade-A cooking tomatoes now at Rs. 260/kg.',
        imageUrl:
            'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=200&auto=format&fit=crop&q=80',
        produceName: 'Grade-A Cooking Tomatoes',
        discountedPriceText: 'Rs. 260',
        originalPriceText: 'Rs. 320',
        productId: 'tomatoes-peak',
      ),
    ];
  }
}

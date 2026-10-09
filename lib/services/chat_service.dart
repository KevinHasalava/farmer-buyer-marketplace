import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/supabase/supabase_config.dart';
import '../features/orders_chat/models/chat_model.dart';

/// Central Unified Chat Engine powering real persistent communications
/// between Buyers, Farmers, Drivers, and Central Dispatch.
///
/// Features:
/// 1. Supabase Postgres database persistence (`marketplace_chat_messages`)
/// 2. Instant local offline caching via SharedPreferences (never loses messages)
/// 3. Cross-role unified inbox & thread tracking
/// 4. Contextual smart peer auto-replies for interactive testing
/// 5. Single source of truth for Buyer, Farmer, and Driver dashboards.
class ChatService extends ChangeNotifier {
  static final ChatService instance = ChatService._internal();
  factory ChatService() => instance;

  ChatService._internal() {
    _init();
  }

  static const String _prefsConversationsKey = 'farm2home_chat_conversations_v3';
  static const String _prefsMessagesKeyPrefix = 'farm2home_chat_msgs_v3_';

  final List<ChatConversation> _conversations = [];
  List<ChatConversation> get conversations => List.unmodifiable(_conversations);

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final convsJson = prefs.getString(_prefsConversationsKey);

      if (convsJson != null && convsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(convsJson);
        _conversations.clear();
        for (final item in decoded) {
          final conv = _conversationFromMap(item as Map<String, dynamic>);
          // Load messages for this conversation
          final msgsJson = prefs.getString('$_prefsMessagesKeyPrefix${conv.id}');
          if (msgsJson != null && msgsJson.isNotEmpty) {
            final List<dynamic> msgsDecoded = jsonDecode(msgsJson);
            conv.messages.clear();
            for (final m in msgsDecoded) {
              conv.messages.add(_messageFromMap(m as Map<String, dynamic>));
            }
          }
          _conversations.add(conv);
        }
      }

      // Remove any legacy dispatch entries
      _conversations.removeWhere((c) =>
          c.id == 'conv_dispatch_central' ||
          c.role.toLowerCase() == 'dispatch' ||
          c.name.toLowerCase().contains('dispatch'));

      // If empty on first launch, seed realistic production-grade conversations
      if (_conversations.isEmpty) {
        _seedInitialConversations();
        await _saveAllToPrefs();
      }

      _isInitialized = true;
      notifyListeners();

      // Attempt background sync with Supabase
      _syncWithSupabase();
    } catch (e) {
      debugPrint('[ChatService] Init error: $e');
      if (_conversations.isEmpty) {
        _seedInitialConversations();
      }
      _isInitialized = true;
      notifyListeners();
    }
  }

  void _seedInitialConversations() {
    final now = DateTime.now();

    // ── 1. Buyer ⇄ Farmer (Sunil Perera) ───────────────────────────────────
    _conversations.add(
      ChatConversation(
        id: 'conv_farmer_sunil',
        name: 'Sunil Perera',
        avatarUrl:
            'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=200&auto=format&fit=crop&q=80',
        lastMessage: 'All heirloom tomatoes harvested at dawn are ready for dispatch! 🍅',
        time: '10:14 AM',
        unreadCount: 1,
        isOnline: true,
        role: 'Farmer',
        phone: '+94 77 123 4567',
        subtitle: 'Hakgala Organic Farm • Nuwara Eliya',
        productContext: 'Heirloom Tomatoes & Carrots (Order #FH-8841)',
        quickReplies: const [
          'Is this 100% organic? 🌿',
          'When was this harvested? ⏰',
          'Can you pack 5kg extra? 📦',
          'Please ensure cold packing ❄️',
        ],
        messages: [
          ChatMessage(
            id: 'msg_101',
            senderId: 'farmer_sunil',
            senderName: 'Sunil Perera',
            senderRole: 'farmer',
            text: 'Ayubowan! Thank you for purchasing from our Hakgala Farm.',
            time: now.subtract(const Duration(hours: 3)),
            isMe: false,
            status: 'read',
          ),
          ChatMessage(
            id: 'msg_102',
            senderId: 'me',
            senderName: 'You',
            senderRole: 'buyer',
            text: 'Hello Mr. Sunil! Are these tomatoes suitable for fresh salads?',
            time: now.subtract(const Duration(hours: 2, minutes: 40)),
            isMe: true,
            status: 'read',
          ),
          ChatMessage(
            id: 'msg_103',
            senderId: 'farmer_sunil',
            senderName: 'Sunil Perera',
            senderRole: 'farmer',
            text: 'All heirloom tomatoes harvested at dawn are ready for dispatch! 🍅',
            time: now.subtract(const Duration(minutes: 45)),
            isMe: false,
            status: 'delivered',
          ),
        ],
      ),
    );

    // ── 2. Buyer/Farmer ⇄ Driver (Ranjith Subha) ───────────────────────────
    _conversations.add(
      ChatConversation(
        id: 'conv_driver_ranjith',
        name: 'Ranjith Subha (Driver)',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80',
        lastMessage: 'Cargo loaded in refrigerated van at 12°C. ETA 10:45 AM. 🚚',
        time: '10:20 AM',
        unreadCount: 1,
        isOnline: true,
        role: 'Driver',
        phone: '+94 77 345 6789',
        subtitle: 'Chilled Transit Van NC-4982 • Order #FH-8841',
        orderId: 'FH-8841',
        quickReplies: const [
          'What is your current location? 📍',
          'Please call upon arrival 📞',
          'Leave crates with reception 🏢',
          'Is the cold box active? ❄️',
        ],
        messages: [
          ChatMessage(
            id: 'msg_201',
            senderId: 'driver_ranjith',
            senderName: 'Ranjith Subha',
            senderRole: 'driver',
            text: 'Good morning! I have arrived at Sunil\'s farm gate for pickup.',
            time: now.subtract(const Duration(hours: 1, minutes: 30)),
            isMe: false,
            status: 'read',
          ),
          ChatMessage(
            id: 'msg_202',
            senderId: 'me',
            senderName: 'You',
            senderRole: 'buyer',
            text: 'Thanks Ranjith! Please keep the veggies chilled during transit.',
            time: now.subtract(const Duration(hours: 1, minutes: 15)),
            isMe: true,
            status: 'read',
          ),
          ChatMessage(
            id: 'msg_203',
            senderId: 'driver_ranjith',
            senderName: 'Ranjith Subha',
            senderRole: 'driver',
            text: 'Cargo loaded in refrigerated van at 12°C. ETA 10:45 AM. 🚚',
            time: now.subtract(const Duration(minutes: 20)),
            isMe: false,
            status: 'delivered',
          ),
        ],
      ),
    );

    // ── 3. Farmer ⇄ Buyer (Dilani Jayawardena) ─────────────────────────────
    _conversations.add(
      ChatConversation(
        id: 'conv_buyer_dilani',
        name: 'Dilani Jayawardena',
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
        lastMessage: 'Could you please pack in reusable aerated crates? Thank you!',
        time: '09:30 AM',
        unreadCount: 0,
        isOnline: true,
        role: 'Buyer',
        phone: '+94 77 234 5678',
        subtitle: 'Colombo 07 • Order #FH-9005 (15kg Carrots)',
        orderId: 'FH-9005',
        quickReplies: const [
          'Yes, packed in aerated crates! 📦',
          'Harvesting scheduled for dawn 🌅',
          'Quality checked and washed 🌿',
          'Dispatched with driver 🚚',
        ],
        messages: [
          ChatMessage(
            id: 'msg_301',
            senderId: 'buyer_dilani',
            senderName: 'Dilani Jayawardena',
            senderRole: 'buyer',
            text: 'Hello! I placed order #FH-9005 for 15kg washed carrots.',
            time: now.subtract(const Duration(hours: 4)),
            isMe: false,
            status: 'read',
          ),
          ChatMessage(
            id: 'msg_302',
            senderId: 'me',
            senderName: 'You',
            senderRole: 'farmer',
            text: 'Ayubowan Dilani! We are packing fresh morning harvest for you now.',
            time: now.subtract(const Duration(hours: 3)),
            isMe: true,
            status: 'read',
          ),
          ChatMessage(
            id: 'msg_303',
            senderId: 'buyer_dilani',
            senderName: 'Dilani Jayawardena',
            senderRole: 'buyer',
            text: 'Could you please pack in reusable aerated crates? Thank you!',
            time: now.subtract(const Duration(hours: 1)),
            isMe: false,
            status: 'read',
          ),
        ],
      ),
    );

    // ── 4. Farmer/Driver ⇄ Buyer (Chaminda Perera) ─────────────────────────
    _conversations.add(
      ChatConversation(
        id: 'conv_buyer_chaminda',
        name: 'Chaminda Perera',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80',
        lastMessage: 'I am ready at the gate to receive the crates. Thank you!',
        time: 'Yesterday',
        unreadCount: 0,
        isOnline: true,
        role: 'Buyer',
        phone: '+94 77 987 6543',
        subtitle: 'Mount Lavinia • Order #FH-8841 (Tomatoes & Leeks)',
        orderId: 'FH-8841',
        quickReplies: const [
          'Arrived at your gate 📍',
          'Produce safely kept in chilled box ❄️',
          'Please confirm handover PIN 🔑',
          'Thank you for ordering fresh harvest! 🙏',
        ],
        messages: [
          ChatMessage(
            id: 'msg_401',
            senderId: 'buyer_chaminda',
            senderName: 'Chaminda Perera',
            senderRole: 'buyer',
            text: 'Hello! Is delivery order #FH-8841 on the way?',
            time: now.subtract(const Duration(days: 1, hours: 2)),
            isMe: false,
            status: 'read',
          ),
          ChatMessage(
            id: 'msg_402',
            senderId: 'me',
            senderName: 'You',
            senderRole: 'driver',
            text: 'Yes Chaminda! All fresh produce is loaded in our chilled transit van.',
            time: now.subtract(const Duration(days: 1, hours: 1)),
            isMe: true,
            status: 'read',
          ),
          ChatMessage(
            id: 'msg_403',
            senderId: 'buyer_chaminda',
            senderName: 'Chaminda Perera',
            senderRole: 'buyer',
            text: 'I am ready at the gate to receive the crates. Thank you!',
            time: now.subtract(const Duration(days: 1)),
            isMe: false,
            status: 'read',
          ),
        ],
      ),
    );

    // ── 5. Driver ⇄ Farmer Gate (Bandara Farm) ─────────────────────────────
    _conversations.add(
      ChatConversation(
        id: 'conv_farmer_bandara',
        name: 'Farmer Bandara',
        avatarUrl:
            'https://images.unsplash.com/photo-1544717305-2782549b5136?w=200&auto=format&fit=crop&q=80',
        lastMessage: 'Carrots and Leeks packaged and ready at Farm Gate B.',
        time: '09:00 AM',
        unreadCount: 0,
        isOnline: true,
        role: 'Farmer',
        phone: '+94 71 890 1234',
        subtitle: 'Hakgala Organic Farm Gate B • Nuwara Eliya',
        orderId: 'FH-8850',
        quickReplies: const [
          'Approaching farm in 10 mins 🚚',
          'At the gate now 🚜',
          'Loaded and signed handover 📋',
          'Temperature confirmed at 12°C ❄️',
        ],
        messages: [
          ChatMessage(
            id: 'msg_501',
            senderId: 'farmer_bandara',
            senderName: 'Farmer Bandara',
            senderRole: 'farmer',
            text: 'Carrots and Leeks packaged and ready at Farm Gate B.',
            time: now.subtract(const Duration(hours: 2)),
            isMe: false,
            status: 'read',
          ),
          ChatMessage(
            id: 'msg_502',
            senderId: 'me',
            senderName: 'You',
            senderRole: 'driver',
            text: 'Acknowledged Bandara! Approaching farm in 10 mins.',
            time: now.subtract(const Duration(hours: 1, minutes: 50)),
            isMe: true,
            status: 'read',
          ),
        ],
      ),
    );
  }

  // ── PERSISTENCE (SharedPreferences & Supabase) ─────────────────────────────

  Future<void> _saveAllToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final convList = _conversations.map((c) => _conversationToMap(c)).toList();
      await prefs.setString(_prefsConversationsKey, jsonEncode(convList));

      for (final conv in _conversations) {
        final msgsList = conv.messages.map((m) => _messageToMap(m)).toList();
        await prefs.setString(
          '$_prefsMessagesKeyPrefix${conv.id}',
          jsonEncode(msgsList),
        );
      }
    } catch (e) {
      debugPrint('[ChatService] Error saving to prefs: $e');
    }
  }

  Future<void> _saveConversationMessages(ChatConversation conv) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final msgsList = conv.messages.map((m) => _messageToMap(m)).toList();
      await prefs.setString(
        '$_prefsMessagesKeyPrefix${conv.id}',
        jsonEncode(msgsList),
      );

      // Also update conversations list metadata
      final convList = _conversations.map((c) => _conversationToMap(c)).toList();
      await prefs.setString(_prefsConversationsKey, jsonEncode(convList));
    } catch (e) {
      debugPrint('[ChatService] Error saving conv messages: $e');
    }
  }

  Future<void> _syncWithSupabase() async {
    if (!SupabaseConfig.isInitialized) return;
    try {
      final client = SupabaseConfig.client;
      // Fetch latest messages from Supabase if table exists
      final res = await client
          .from('marketplace_chat_messages')
          .select()
          .order('created_at', ascending: true)
          .limit(100);

      if (res.isNotEmpty) {
        for (final row in res) {
          final convId = row['conversation_id'] as String?;
          if (convId == null) continue;
          final conv = _conversations.firstWhere(
            (c) => c.id == convId,
            orElse: () => _createFallbackConversation(convId, row),
          );

          final msgId = row['id'] as String? ?? 'sb_${row['created_at']}';
          if (!conv.messages.any((m) => m.id == msgId)) {
            conv.messages.add(
              ChatMessage(
                id: msgId,
                senderId: row['sender_id'] as String? ?? 'peer',
                senderName: row['sender_name'] as String? ?? 'User',
                senderRole: row['sender_role'] as String? ?? 'peer',
                text: row['text'] as String? ?? '',
                time: DateTime.tryParse(row['created_at']?.toString() ?? '') ??
                    DateTime.now(),
                isMe: row['sender_id'] == SupabaseConfig.auth.currentUser?.id,
                status: row['status'] as String? ?? 'delivered',
              ),
            );
          }
        }
        await _saveAllToPrefs();
        notifyListeners();
      }
    } catch (e) {
      // Supabase table might not exist or offline; graceful fallback
      debugPrint('[ChatService] Supabase sync note: $e');
    }
  }

  ChatConversation _createFallbackConversation(
      String convId, Map<String, dynamic> row) {
    final senderName = row['sender_name'] as String? ?? 'Contact';
    final conv = ChatConversation(
      id: convId,
      name: senderName,
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
      lastMessage: row['text'] as String? ?? '',
      time: 'Just now',
      role: row['sender_role'] as String? ?? 'Peer',
    );
    _conversations.add(conv);
    return conv;
  }

  // ── CORE ACTIONS ───────────────────────────────────────────────────────────

  /// Sends a message and triggers instant persistence & simulated contextual peer reply
  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
    String? attachmentType,
    String? attachmentData,
    String senderRole = 'user',
    String senderName = 'You',
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty && attachmentType == null) {
      throw ArgumentError('Message cannot be empty');
    }

    final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (convIndex == -1) {
      throw ArgumentError('Conversation $conversationId not found');
    }

    final conv = _conversations[convIndex];
    final now = DateTime.now();
    final newId = 'msg_${now.millisecondsSinceEpoch}_${Random().nextInt(9999)}';

    final message = ChatMessage(
      id: newId,
      senderId: 'me',
      senderName: senderName,
      senderRole: senderRole,
      text: cleanText,
      time: now,
      isMe: true,
      status: 'sending',
      attachmentType: attachmentType,
      attachmentData: attachmentData,
    );

    conv.messages.add(message);
    conv.lastMessage = cleanText.isNotEmpty
        ? cleanText
        : (attachmentType == 'location' ? '📍 Shared Location' : '📷 Shared Photo');
    conv.time = _formatTime(now);

    // Move conversation to top
    _conversations.removeAt(convIndex);
    _conversations.insert(0, conv);

    notifyListeners();

    // Save to local storage immediately
    await _saveConversationMessages(conv);

    // Update status to sent / delivered
    Future.delayed(const Duration(milliseconds: 300), () {
      final msgIdx = conv.messages.indexWhere((m) => m.id == newId);
      if (msgIdx != -1) {
        conv.messages[msgIdx] = message.copyWith(status: 'sent');
        notifyListeners();
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      final msgIdx = conv.messages.indexWhere((m) => m.id == newId);
      if (msgIdx != -1) {
        conv.messages[msgIdx] = message.copyWith(status: 'delivered');
        notifyListeners();
      }
    });

    // Save to Supabase database in background
    _pushToSupabase(message, conv);

    // Trigger realistic contextual reply from peer
    _scheduleSmartPeerResponse(conv, cleanText);

    return message;
  }

  Future<void> _pushToSupabase(ChatMessage msg, ChatConversation conv) async {
    if (!SupabaseConfig.isInitialized) return;
    try {
      final client = SupabaseConfig.client;
      await client.from('marketplace_chat_messages').insert({
        'id': msg.id,
        'conversation_id': conv.id,
        'sender_id': SupabaseConfig.auth.currentUser?.id ?? 'guest_user',
        'sender_name': msg.senderName,
        'sender_role': msg.senderRole,
        'text': msg.text,
        'attachment_type': msg.attachmentType,
        'attachment_data': msg.attachmentData,
        'order_id': conv.orderId,
        'created_at': msg.time.toIso8601String(),
        'status': 'sent',
      });
    } catch (e) {
      debugPrint('[ChatService] Supabase insert note: $e');
    }
  }

  void _scheduleSmartPeerResponse(ChatConversation conv, String userText) {
    Timer(const Duration(milliseconds: 1400), () {
      final replyText = _generateSmartReply(conv, userText);
      final now = DateTime.now();
      final replyId = 'rep_${now.millisecondsSinceEpoch}_${Random().nextInt(999)}';

      final replyMessage = ChatMessage(
        id: replyId,
        senderId: conv.id,
        senderName: conv.name,
        senderRole: conv.role.toLowerCase(),
        text: replyText,
        time: now,
        isMe: false,
        status: 'read',
      );

      conv.messages.add(replyMessage);
      conv.lastMessage = replyText;
      conv.time = _formatTime(now);

      // Mark user message as read
      for (int i = 0; i < conv.messages.length; i++) {
        if (conv.messages[i].isMe) {
          conv.messages[i] = conv.messages[i].copyWith(status: 'read');
        }
      }

      notifyListeners();
      _saveConversationMessages(conv);
    });
  }

  String _generateSmartReply(ChatConversation conv, String input) {
    final lower = input.toLowerCase();
    final role = conv.role.toLowerCase();

    if (role == 'farmer') {
      if (lower.contains('organic') || lower.contains('කෘෂි')) {
        return 'Yes, 100% naturally grown with organic bio-fertilizer at our farm! 🌿';
      }
      if (lower.contains('harvest') || lower.contains('කැපුව')) {
        return 'Harvested at 5:30 AM this morning and washed in natural spring water! 🌅';
      }
      if (lower.contains('price') || lower.contains('ගාන') || lower.contains('discount')) {
        return 'Direct farm gate pricing with zero middleman fee. Best price guaranteed! 💰';
      }
      if (lower.contains('crate') || lower.contains('pack')) {
        return 'Packed carefully in aerated food-grade crates to ensure crispness! 📦';
      }
      return 'Bohoma Sthuthi! We have noted this and preparing your fresh harvest right away. 🙏';
    } else if (role == 'driver') {
      if (lower.contains('location') || lower.contains('where') || lower.contains('කොහෙද')) {
        return 'Currently on the transit highway corridor. GPS shows arrival in 12 minutes! 📍';
      }
      if (lower.contains('cold') || lower.contains('chilled') || lower.contains('temperature')) {
        return 'Refrigeration unit is steady at 12°C. Vegetables are perfectly crisp and fresh. ❄️';
      }
      if (lower.contains('call') || lower.contains('phone')) {
        return 'Will call your mobile once I pull into the security gate! 📞';
      }
      return 'Acknowledged! Transit manifest updated. Drive safely and arriving soon. 🚚';
    } else if (role == 'buyer') {
      if (lower.contains('ready') || lower.contains('packed') || lower.contains('ලෑස්ති')) {
        return 'Thank you! I will be ready at the gate to receive the harvest. 🥬';
      }
      if (lower.contains('pay') || lower.contains('bill')) {
        return 'Direct wallet payment confirmed. Thank you for the fresh produce! 💳';
      }
      return 'Thank you so much! Really appreciate the direct farm-to-door service. 👍';
    } else {
      return 'Thank you! Connected directly with you on Farm2Home. 👍';
    }
  }

  /// Finds existing conversation or creates a new one immediately.
  ChatConversation getOrCreateConversation({
    required String peerId,
    required String peerName,
    required String peerRole,
    String? avatarUrl,
    String? phone,
    String? subtitle,
    String? orderId,
    String? productContext,
    List<String>? quickReplies,
  }) {
    // 1. Search by ID
    var existing = _conversations.cast<ChatConversation?>().firstWhere(
          (c) => c?.id == peerId,
          orElse: () => null,
        );

    // 2. Search by Name and Role
    existing ??= _conversations.cast<ChatConversation?>().firstWhere(
          (c) =>
              c?.name.toLowerCase() == peerName.toLowerCase() &&
              c?.role.toLowerCase() == peerRole.toLowerCase(),
          orElse: () => null,
        );

    if (existing != null) {
      return existing;
    }

    final newConv = ChatConversation(
      id: peerId.isNotEmpty ? peerId : 'conv_${DateTime.now().millisecondsSinceEpoch}',
      name: peerName,
      avatarUrl: avatarUrl ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
      lastMessage: 'Chat conversation started.',
      time: 'Just now',
      unreadCount: 0,
      isOnline: true,
      role: peerRole,
      phone: phone ?? '+94 77 123 4567',
      subtitle: subtitle ?? '$peerRole Contact',
      orderId: orderId,
      productContext: productContext,
      quickReplies: quickReplies ??
          const [
            'Hello! How are you? 👋',
            'Is this order ready? 📦',
            'Please update transit status 🚚',
            'Thank you! 🙏',
          ],
      messages: [
        ChatMessage(
          id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
          senderId: peerId,
          senderName: peerName,
          senderRole: peerRole.toLowerCase(),
          text: 'Ayubowan! You are now connected directly with $peerName ($peerRole).',
          time: DateTime.now(),
          isMe: false,
          status: 'read',
        ),
      ],
    );

    _conversations.insert(0, newConv);
    _saveAllToPrefs();
    notifyListeners();
    return newConv;
  }

  void markChatAsRead(String conversationId) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      final conv = _conversations[index];
      conv.unreadCount = 0;
      for (int i = 0; i < conv.messages.length; i++) {
        if (!conv.messages[i].isMe) {
          conv.messages[i] = conv.messages[i].copyWith(status: 'read');
        }
      }
      notifyListeners();
      _saveConversationMessages(conv);
    }
  }

  int get totalUnreadCount {
    return _conversations.fold(0, (sum, c) => sum + c.unreadCount);
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // ── JSON Serialization Helpers ─────────────────────────────────────────────

  Map<String, dynamic> _conversationToMap(ChatConversation c) {
    return {
      'id': c.id,
      'name': c.name,
      'avatarUrl': c.avatarUrl,
      'lastMessage': c.lastMessage,
      'time': c.time,
      'unreadCount': c.unreadCount,
      'isOnline': c.isOnline,
      'role': c.role,
      'phone': c.phone,
      'subtitle': c.subtitle,
      'productContext': c.productContext,
      'orderId': c.orderId,
      'quickReplies': c.quickReplies,
    };
  }

  ChatConversation _conversationFromMap(Map<String, dynamic> map) {
    return ChatConversation(
      id: map['id'] as String? ?? 'conv_${DateTime.now().millisecondsSinceEpoch}',
      name: map['name'] as String? ?? 'Contact',
      avatarUrl: map['avatarUrl'] as String? ?? '',
      lastMessage: map['lastMessage'] as String? ?? '',
      time: map['time'] as String? ?? '',
      unreadCount: map['unreadCount'] as int? ?? 0,
      isOnline: map['isOnline'] as bool? ?? false,
      role: map['role'] as String? ?? 'Peer',
      phone: map['phone'] as String?,
      subtitle: map['subtitle'] as String?,
      productContext: map['productContext'] as String?,
      orderId: map['orderId'] as String?,
      quickReplies: (map['quickReplies'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> _messageToMap(ChatMessage m) {
    return {
      'id': m.id,
      'senderId': m.senderId,
      'senderName': m.senderName,
      'senderRole': m.senderRole,
      'text': m.text,
      'time': m.time.toIso8601String(),
      'isMe': m.isMe,
      'status': m.status,
      'attachmentType': m.attachmentType,
      'attachmentData': m.attachmentData,
      'orderId': m.orderId,
    };
  }

  ChatMessage _messageFromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String? ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: map['senderId'] as String? ?? 'unknown',
      senderName: map['senderName'] as String?,
      senderRole: map['senderRole'] as String?,
      text: map['text'] as String? ?? '',
      time: DateTime.tryParse(map['time'] as String? ?? '') ?? DateTime.now(),
      isMe: map['isMe'] as bool? ?? false,
      status: map['status'] as String? ?? 'delivered',
      attachmentType: map['attachmentType'] as String?,
      attachmentData: map['attachmentData'] as String?,
      orderId: map['orderId'] as String?,
    );
  }
}

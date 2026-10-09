import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/chat_service.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../models/chat_model.dart';
import 'chat_detail_screen.dart';

/// Unified Chat Inbox Screen for Buyers, Farmers, and Drivers.
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({
    super.key,
    this.currentRole = 'user',
  });

  final String currentRole;

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService.instance;

  static const Color _forestGreen = Color(0xFF1B5E38);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilter = 'All'; // 'All', 'Farmers', 'Buyers', 'Drivers'

  @override
  void initState() {
    super.initState();
    _chatService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _chatService.removeListener(_onServiceUpdate);
    _searchController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  List<ChatConversation> get _filteredChats {
    return _chatService.conversations.where((c) {
      // 1. Role filter
      if (_activeFilter != 'All') {
        if (_activeFilter == 'Farmers' && c.role.toLowerCase() != 'farmer') {
          return false;
        }
        if (_activeFilter == 'Buyers' && c.role.toLowerCase() != 'buyer') {
          return false;
        }
        if (_activeFilter == 'Drivers' && c.role.toLowerCase() != 'driver') {
          return false;
        }
      }

      // 2. Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesName = c.name.toLowerCase().contains(q);
        final matchesMsg = c.lastMessage.toLowerCase().contains(q);
        final matchesRole = c.role.toLowerCase().contains(q);
        final matchesOrder = (c.orderId ?? '').toLowerCase().contains(q);
        return matchesName || matchesMsg || matchesRole || matchesOrder;
      }

      return true;
    }).toList();
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'farmer':
        return const Color(0xFF16A34A);
      case 'driver':
        return const Color(0xFFD97706);
      case 'buyer':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF7C3AED);
    }
  }

  void _openChat(ChatConversation conv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          conversation: conv,
          currentRole: widget.currentRole,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chats = _filteredChats;

    return Scaffold(
      backgroundColor: _bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 19,
                  color: _textDark,
                ),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search chats, contacts, orders...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: _textMuted, fontSize: 14),
                ),
                style: const TextStyle(color: _textDark, fontSize: 15),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
              )
            : const Row(
                children: [
                  AppBrandLogo(size: 30, hasGlow: false),
                  SizedBox(width: 8),
                  AppBrandWordmark(fontSize: 17),
                  SizedBox(width: 6),
                  Text(
                    '• Chat Hub',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
        actions: [
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
        ],
      ),
      body: Column(
        children: [
          // ── Role Category Filter Chips ──────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Farmers', emoji: '🌾'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Buyers', emoji: '🛒'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Drivers', emoji: '🚚'),
                ],
              ),
            ),
          ),

          // ── Conversation List ──────────────────────────────────────────────
          Expanded(
            child: chats.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: chats.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 74,
                      color: Color(0xFFF1F5F9),
                    ),
                    itemBuilder: (ctx, index) {
                      final chat = chats[index];
                      return _buildChatTile(chat);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterName, {String? emoji}) {
    final isSelected = _activeFilter == filterName;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeFilter = filterName);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? _forestGreen : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _forestGreen : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 5),
            ],
            Text(
              filterName,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(ChatConversation chat) {
    final roleColor = _getRoleColor(chat.role);

    return InkWell(
      onTap: () => _openChat(chat),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Contact Avatar with status dot
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFE2E8F0),
                  backgroundImage: NetworkImage(chat.avatarUrl),
                  onBackgroundImageError: (_, __) {},
                  child: Text(
                    chat.name.isNotEmpty ? chat.name.substring(0, 1) : '?',
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: chat.isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Middle Column: Name, Role Badge, Subtitle & Last Message
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
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: roleColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          chat.role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (chat.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      chat.subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: chat.unreadCount > 0
                          ? _textDark
                          : const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right Column: Time and Unread Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: chat.unreadCount > 0
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: chat.unreadCount > 0
                        ? _forestGreen
                        : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 6),
                if (chat.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2.5),
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 32,
                color: _forestGreen,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Conversations Found',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No active chats match your selected filter. Start a conversation from orders or produce cards.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: _textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/localization/app_settings.dart';
import '../../../services/chat_service.dart';
import '../models/chat_model.dart';

/// Ultra-Premium Unified Chat Detail Screen for real communications
/// between Buyers, Farmers, and Drivers.
class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    super.key,
    required this.conversation,
    this.currentRole = 'user',
  });

  final ChatConversation conversation;
  final String currentRole;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService.instance;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  static const Color _forestGreen = Color(0xFF1B5E38);
  static const Color _emerald = Color(0xFF10B981);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _bubbleOther = Colors.white;

  late ChatConversation _chat;
  bool _showContextBanner = true;

  @override
  void initState() {
    super.initState();
    _chat = widget.conversation;
    _chatService.addListener(_onChatUpdated);
    _chatService.markChatAsRead(_chat.id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animate: false);
    });
  }

  @override
  void dispose() {
    _chatService.removeListener(_onChatUpdated);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChatUpdated() {
    if (!mounted) return;
    // Find updated conversation instance
    final updated = _chatService.conversations.cast<ChatConversation?>().firstWhere(
          (c) => c?.id == _chat.id,
          orElse: () => null,
        );
    if (updated != null) {
      setState(() {
        _chat = updated;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom({bool animate = true}) {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scrollController.hasClients) {
        if (animate) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  Future<void> _sendMessage([String? quickText]) async {
    final text = quickText ?? _textController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    _textController.clear();

    try {
      await _chatService.sendMessage(
        conversationId: _chat.id,
        text: text,
        senderRole: widget.currentRole,
      );
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendAttachment(String type, String data, String previewText) async {
    HapticFeedback.mediumImpact();
    try {
      await _chatService.sendMessage(
        conversationId: _chat.id,
        text: previewText,
        attachmentType: type,
        attachmentData: data,
        senderRole: widget.currentRole,
      );
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attachment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
            const Text(
              'Share with Contact',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttachmentOption(
                  icon: Icons.location_on_rounded,
                  label: 'Share Pin 📍',
                  color: const Color(0xFF16A34A),
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendAttachment(
                      'location',
                      '6.9271,79.8612',
                      '📍 Shared Live GPS Location: Farm Gate Coordinates',
                    );
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Harvest Photo 📷',
                  color: const Color(0xFF2563EB),
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendAttachment(
                      'image',
                      'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80',
                      '📷 Shared Harvest Quality Photo: Verified Organic',
                    );
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.ac_unit_rounded,
                  label: 'Cold Box Log ❄️',
                  color: const Color(0xFF0284C7),
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendAttachment(
                      'text',
                      'temp_log',
                      '❄️ Cold-Chain Telematics: Compartment steady at 12°C',
                    );
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.verified_user_rounded,
                  label: 'Handover PIN 🔑',
                  color: const Color(0xFFD97706),
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendAttachment(
                      'text',
                      'pin_code',
                      '🔑 Handover Verified PIN: 4892 (Show to driver)',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  void _showCallModal() {
    final phone = _chat.phone ?? '+94 77 123 4567';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE2E8F0),
                  backgroundImage: NetworkImage(_chat.avatarUrl),
                  onBackgroundImageError: (_, __) {},
                  child: Text(_chat.name.substring(0, 1)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _chat.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                      Text(
                        'Direct Phone: $phone',
                        style: const TextStyle(fontSize: 13, color: _forestGreen, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calling ${_chat.name} ($phone)...'),
                          backgroundColor: _forestGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.call_rounded, color: Colors.white, size: 18),
                    label: const Text('Call Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _forestGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(_chat.role);
    final quickReplies = _chat.quickReplies ??
        [
          context.tr.quickReply1,
          context.tr.quickReply2,
          context.tr.quickReply3,
          context.tr.quickReply4,
        ];

    return Scaffold(
      backgroundColor: _bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: _textDark,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Row(
          children: [
            // Contact Avatar with online indicator
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: const Color(0xFFE2E8F0),
                  backgroundImage: NetworkImage(_chat.avatarUrl),
                  onBackgroundImageError: (_, __) {},
                  child: Text(
                    _chat.name.isNotEmpty ? _chat.name.substring(0, 1) : '?',
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _chat.isOnline ? _emerald : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),

            // Contact Name & Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _chat.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _chat.role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _chat.subtitle ?? 'Direct Farm2Home Contact',
                    style: const TextStyle(
                      fontSize: 11,
                      color: _textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: _forestGreen, size: 22),
            onPressed: _showCallModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Pinned Context Header (Order ID / Produce link) ───────────────
          if (_showContextBanner && (_chat.productContext != null || _chat.orderId != null))
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: _forestGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: _forestGreen, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _chat.productContext ?? 'Linked with Order #${_chat.orderId}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _forestGreen,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showContextBanner = false),
                    child: const Icon(Icons.close_rounded, size: 16, color: _forestGreen),
                  ),
                ],
              ),
            ),

          // ── Message Bubbles List ───────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              itemCount: _chat.messages.length,
              itemBuilder: (ctx, index) {
                final msg = _chat.messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // ── Quick Replies Bar ──────────────────────────────────────────────
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (ctx, i) {
                return ActionChip(
                  label: Text(
                    quickReplies[i],
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: _forestGreen,
                    ),
                  ),
                  backgroundColor: const Color(0xFFECFDF5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFA7F3D0)),
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => _sendMessage(quickReplies[i]),
                );
              },
            ),
          ),

          // ── Chat Input Bar ─────────────────────────────────────────────────
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Attachment button (+)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: _forestGreen, size: 24),
                    onPressed: _showAttachmentSheet,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),

                  // Text input field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              maxLines: 4,
                              minLines: 1,
                              textCapitalization: TextCapitalization.sentences,
                              style: const TextStyle(
                                fontSize: 14,
                                color: _textDark,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Type message in English or සිංහල...',
                                hintStyle: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send button
                  GestureDetector(
                    onTap: () => _sendMessage(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B5E38), Color(0xFF16A34A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x3316A34A),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isMe = msg.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: isMe ? _forestGreen : _bubbleOther,
          gradient: isMe
              ? const LinearGradient(
                  colors: [Color(0xFF1B5E38), Color(0xFF166534)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isMe ? 0.08 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Sender role tag for other user
            if (!isMe && msg.senderName != null) ...[
              Text(
                msg.senderName!,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF047857),
                ),
              ),
              const SizedBox(height: 2),
            ],

            // Message text
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 13.5,
                color: isMe ? Colors.white : _textDark,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),

            // Time & Read receipt ticks
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatMsgTime(msg.time),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : _textMuted,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.status == 'read'
                        ? Icons.done_all_rounded
                        : msg.status == 'delivered'
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                    size: 13,
                    color: msg.status == 'read'
                        ? const Color(0xFF86EFAC)
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMsgTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

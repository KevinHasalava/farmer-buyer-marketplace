class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime time;
  final bool isMe;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.time,
    required this.isMe,
  });
}

class ChatConversation {
  final String id;
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final String role;
  final String? productContext;
  final List<ChatMessage> messages;

  ChatConversation({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    this.role = 'Buyer',
    this.productContext,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];
}

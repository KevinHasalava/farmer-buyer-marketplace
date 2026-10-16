class ChatMessage {
  final String id;
  final String senderId;
  final String? senderName;
  final String? senderRole; // 'buyer', 'farmer', 'driver'
  final String text;
  final DateTime time;
  final bool isMe;
  final String status; // 'sending', 'sent', 'delivered', 'read'
  final String? attachmentType; // 'location', 'image', 'order_card'
  final String? attachmentData;
  final String? orderId;

  const ChatMessage({
    required this.id,
    required this.senderId,
    this.senderName,
    this.senderRole,
    required this.text,
    required this.time,
    required this.isMe,
    this.status = 'delivered',
    this.attachmentType,
    this.attachmentData,
    this.orderId,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? text,
    DateTime? time,
    bool? isMe,
    String? status,
    String? attachmentType,
    String? attachmentData,
    String? orderId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      text: text ?? this.text,
      time: time ?? this.time,
      isMe: isMe ?? this.isMe,
      status: status ?? this.status,
      attachmentType: attachmentType ?? this.attachmentType,
      attachmentData: attachmentData ?? this.attachmentData,
      orderId: orderId ?? this.orderId,
    );
  }
}

class ChatConversation {
  final String id;
  final String name;
  final String avatarUrl;
  String lastMessage;
  String time;
  int unreadCount;
  bool isOnline;
  final String role; // 'Farmer', 'Buyer', 'Driver'
  final String? phone;
  final String? subtitle;
  final String? orderId;
  final String? productContext;
  final List<String>? quickReplies;
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
    this.phone,
    this.subtitle,
    this.orderId,
    this.productContext,
    this.quickReplies,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];
}

import 'package:flutter/material.dart';
import '../../../services/chat_service.dart';
import '../../orders_chat/models/chat_model.dart';
import '../../orders_chat/presentation/chat_detail_screen.dart';
import '../../orders_chat/presentation/chat_list_screen.dart';

/// Driver Chat Screen for real communication with Farmers and Buyers.
/// Powered by the unified persistent [ChatService].
class DriverChatScreen extends StatelessWidget {
  final String? driverId;
  final String? driverName;
  final String? vehicleType;
  final String? plateNumber;
  final String? bankName;
  final String? accountNumber;
  final String? cargoCapacity;
  final String? licenseNumber;
  final String? initialThreadId;

  const DriverChatScreen({
    super.key,
    this.driverId,
    this.driverName,
    this.vehicleType,
    this.plateNumber,
    this.bankName,
    this.accountNumber,
    this.cargoCapacity,
    this.licenseNumber,
    this.initialThreadId,
  });

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService.instance;

    // If an initial thread was requested (e.g. 'chaminda', 'bandara', 'dispatch')
    if (initialThreadId != null && initialThreadId!.isNotEmpty) {
      final conv = _resolveConversation(chatService, initialThreadId!);
      return ChatDetailScreen(
        conversation: conv,
        currentRole: 'driver',
      );
    }

    // Default to the full Unified Chat Inbox for drivers
    return const ChatListScreen(currentRole: 'driver');
  }

  ChatConversation _resolveConversation(ChatService service, String threadId) {
    final lower = threadId.toLowerCase();

    if (lower.contains('dilani')) {
      return service.getOrCreateConversation(
        peerId: 'conv_buyer_dilani',
        peerName: 'Dilani Jayawardena',
        peerRole: 'Buyer',
        phone: '+94 77 234 5678',
        subtitle: 'Dehiwala Urban Center • Order #FH-9005',
        orderId: 'FH-9005',
      );
    } else if (lower.contains('sunil')) {
      return service.getOrCreateConversation(
        peerId: 'conv_sunil',
        peerName: 'Sunil Perera (Farmer)',
        peerRole: 'Farmer',
        phone: '+94 77 123 4567',
        subtitle: 'Hakgala Organic Farms • Order #FH-8841',
        orderId: 'FH-8841',
      );
    } else if (lower.contains('chaminda') || lower.contains('buyer')) {
      return service.getOrCreateConversation(
        peerId: 'conv_buyer_chaminda',
        peerName: 'Chaminda (Buyer)',
        peerRole: 'Buyer',
        phone: '+94 77 987 6543',
        subtitle: 'Mount Lavinia • Order #FH-8841 Delivery',
        orderId: 'FH-8841',
        quickReplies: const [
          'Approaching destination in 10 mins 🚚',
          'Arrived at your security gate 📍',
          'Produce safely kept in chilled box ❄️',
          'Please confirm handover PIN 🔑',
        ],
      );
    } else if (lower.contains('bandara') || lower.contains('farmer')) {
      return service.getOrCreateConversation(
        peerId: 'conv_farmer_bandara',
        peerName: 'Farmer Bandara',
        peerRole: 'Farmer',
        phone: '+94 71 890 1234',
        subtitle: 'Hakgala Organic Farm Gate B • Nuwara Eliya',
        orderId: 'FH-8850',
        quickReplies: const [
          'Arriving at Farm Gate in 10 mins 🚚',
          'At the gate for pickup 🚜',
          'Loaded and signed handover 📋',
          'Temperature confirmed at 12°C ❄️',
        ],
      );
    } else {
      return service.getOrCreateConversation(
        peerId: 'conv_farmer_bandara',
        peerName: 'Farmer Bandara',
        peerRole: 'Farmer',
        phone: '+94 71 890 1234',
        subtitle: 'Hakgala Organic Farm Gate B • Nuwara Eliya',
        orderId: 'FH-8850',
        quickReplies: const [
          'Arriving at Farm Gate in 10 mins 🚚',
          'At the gate for pickup 🚜',
          'Loaded and signed handover 📋',
          'Temperature confirmed at 12°C ❄️',
        ],
      );
    }
  }
}

import 'package:flutter/material.dart';
import '../../../core/localization/app_settings.dart';
import 'package:flutter/services.dart';


/// Driver Chat Screen for communication with Central Dispatch, Farmers, and Buyers.
class DriverChatScreen extends StatefulWidget {
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
  State<DriverChatScreen> createState() => _DriverChatScreenState();
}

class _ChatMessageItem {
  final String text;
  final bool isMe;
  final String time;
  final String? senderName;

  const _ChatMessageItem({
    required this.text,
    required this.isMe,
    required this.time,
    this.senderName,
  });
}

class _DriverChatScreenState extends State<DriverChatScreen> {
  static const Color _primary = Color(0xFF064E3B);
  static const Color _accent = Color(0xFF10B981);
  static const Color _bgSoft = Color(0xFFF8FAFC);

  late String _activeThreadId;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Map<String, List<_ChatMessageItem>> _threads = {
    'dispatch': [
      const _ChatMessageItem(
        text: 'Assigned deliveries in Nuwara Eliya - Welimada corridor.',
        isMe: false,
        time: '08:30 AM',
        senderName: 'Central Dispatch',
      ),
      const _ChatMessageItem(
        text: 'Moving to pickup point #1 at Hakgala Farm.',
        isMe: true,
        time: '08:35 AM',
      ),
    ],
    'bandara': [
      const _ChatMessageItem(
        text: 'Carrots and Leeks packaged and ready at Farm Gate B.',
        isMe: false,
        time: '09:00 AM',
        senderName: 'Farmer Bandara',
      ),
      const _ChatMessageItem(
        text: 'Approaching farm in 10 mins.',
        isMe: true,
        time: '09:05 AM',
      ),
    ],
    'chaminda': [
      const _ChatMessageItem(
        text: 'Please leave the crates with security if arrived before 11.',
        isMe: false,
        time: '10:00 AM',
        senderName: 'Chaminda (Buyer)',
      ),
      const _ChatMessageItem(
        text: 'Acknowledged, ETA is 10:45 AM.',
        isMe: true,
        time: '10:02 AM',
      ),
    ],
  };

  List<String> _getQuickReplies(BuildContext context) => [
    context.tr.arrivedAtLocation,
    context.tr.delayedByTraffic,
    context.tr.loadedAndSecured,
    context.tr.deliveredSafely,
  ];

  @override
  void initState() {
    super.initState();
    _activeThreadId = widget.initialThreadId ?? 'dispatch';
    if (!_threads.containsKey(_activeThreadId)) {
      _activeThreadId = 'dispatch';
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? quick]) {
    final t = quick ?? _msgController.text.trim();
    if (t.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _threads[_activeThreadId]?.add(
        _ChatMessageItem(
          text: t,
          isMe: true,
          time: 'Just now',
        ),
      );
    });
    _msgController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _title(String id) {
    switch (id) {
      case 'bandara':
        return 'Bandara (Farmer)';
      case 'chaminda':
        return 'Chaminda (Buyer)';
      default:
        return 'Central Dispatch';
    }
  }

  String _subtitle(String id) {
    switch (id) {
      case 'bandara':
        return 'Hakgala Organic Farm';
      case 'chaminda':
        return 'Order #FH-8841';
      default:
        return 'Support & Dispatch Hub';
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = _threads[_activeThreadId] ?? [];

    return Scaffold(
      backgroundColor: _bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title(_activeThreadId),
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: _accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _subtitle(_activeThreadId),
                  style: TextStyle(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                _tabChip('dispatch', context.tr.support, Icons.headset_mic_rounded),
                const SizedBox(width: 8),
                _tabChip('bandara', context.tr.farmer, Icons.agriculture_rounded),
                const SizedBox(width: 8),
                _tabChip('chaminda', context.tr.buyer, Icons.storefront_rounded),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final m = messages[i];
                return Align(
                  alignment: m.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    constraints: const BoxConstraints(maxWidth: 280),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: m.isMe ? _primary : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: m.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (!m.isMe && m.senderName != null) ...[
                          Text(
                            m.senderName!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F766E),
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                        Text(
                          m.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: m.isMe ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.time,
                          style: TextStyle(
                            fontSize: 10,
                            color: m.isMe ? Colors.white70 : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getQuickReplies(context).length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, idx) => ActionChip(
                label: Text(
                  _getQuickReplies(context)[idx],
                  style: TextStyle(fontSize: 12, color: const Color(0xFF0F766E)),
                ),
                backgroundColor: const Color(0xFFCCFBF1),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onPressed: () => _send(_getQuickReplies(context)[idx]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: context.tr.typeYourMessage,
                        hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 13),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _send(),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabChip(String id, String label, IconData icon) {
    final active = _activeThreadId == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeThreadId = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? _primary : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: active ? Colors.white : const Color(0xFF64748B)),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: active ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/admin_marketplace_service.dart';
import 'admin_crud_dialogs.dart' show showDeleteConfirmDialog;
import 'admin_extra_crud_tabs.dart' show AdminLogisticsService;

const Color _emerald = Color(0xFF059669);
const Color _textDark = Color(0xFF0F172A);
const Color _textMuted = Color(0xFF64748B);
const Color _borderLight = Color(0xFFE2E8F0);

BoxDecoration _cardDeco() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _borderLight),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );

InputDecoration _inputDeco(String label, {IconData? icon}) => InputDecoration(
      labelText: label,
      isDense: true,
      prefixIcon: icon == null ? null : Icon(icon, size: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );

void _toast(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: error ? const Color(0xFFDC2626) : _emerald,
    behavior: SnackBarBehavior.floating,
  ));
}

Widget _setupBanner(String what) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.warning_amber_rounded,
            color: Color(0xFFD97706), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$what is not ready in Supabase yet. Open Supabase → SQL Editor and '
            'run the file supabase/buyer_cart_notifications.sql once, then tap '
            'the sync button.',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF92400E)),
          ),
        ),
      ]),
    );

Widget _emptyBox(String title, String msg, String action, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.inbox_rounded, size: 46, color: Color(0xFF94A3B8)),
        const SizedBox(height: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: _textDark)),
        const SizedBox(height: 4),
        Text(msg,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: _textMuted)),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add_rounded, size: 16),
          label: Text(action),
          style: ElevatedButton.styleFrom(
            backgroundColor: _emerald,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    ),
  );
}

String _buyerName(String? id) {
  for (final b in AdminMarketplaceService.instance.buyers) {
    if (b.id == id) return b.name;
  }
  return id ?? 'Unknown buyer';
}

Widget _req(TextEditingController c, String label, IconData icon) =>
    TextFormField(
      controller: c,
      decoration: _inputDeco(label, icon: icon),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );

// =============================================================================
// 🛒 TAB 10: BUYER SHOPPING CARTS (Read / Update quantity / Delete / Create)
// =============================================================================
class AdminCartsTab extends StatelessWidget {
  final String searchQuery;
  const AdminCartsTab({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final svc = AdminLogisticsService.instance;
    var items = svc.cartItems;
    if (searchQuery.isNotEmpty) {
      items = items.where((c) {
        final hay = [
          c['product_name'],
          c['farm_name'],
          c['buyer_id'],
          _buyerName(c['buyer_id']?.toString()),
        ].map((e) => (e ?? '').toString().toLowerCase()).join(' ');
        return hay.contains(searchQuery);
      }).toList();
    }

    final groups = <String, List<Map<String, dynamic>>>{};
    for (final c in items) {
      groups.putIfAbsent(c['buyer_id']?.toString() ?? 'unknown', () => []).add(c);
    }

    return RefreshIndicator(
      color: _emerald,
      onRefresh: svc.loadAll,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16),
        children: [
          if (svc.cartTableMissing) _setupBanner('The cart_items table'),
          if (svc.isLoading && items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: _emerald)),
            )
          else if (groups.isEmpty)
            Center(
              child: _emptyBox(
                  'No Cart Items',
                  'Buyers\' live shopping carts will appear here.',
                  'Add Cart Item',
                  () => showAdminCartItemDialog(context)),
            )
          else
            ...groups.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buyerCartCard(context, e.key, e.value, svc),
                )),
        ],
      ),
    );
  }

  Widget _buyerCartCard(BuildContext context, String buyerId,
      List<Map<String, dynamic>> rows, AdminLogisticsService svc) {
    double total = 0;
    for (final r in rows) {
      total += ((r['unit_price'] as num?)?.toDouble() ?? 0) *
          ((r['quantity'] as num?)?.toInt() ?? 1);
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7), shape: BoxShape.circle),
              child: const Icon(Icons.shopping_cart_rounded,
                  color: Color(0xFF047857), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_buyerName(buyerId),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textDark)),
                  Text('$buyerId • ${rows.length} item(s)',
                      style:
                          const TextStyle(fontSize: 12, color: _textMuted)),
                ],
              ),
            ),
            Text('Rs. ${total.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF047857))),
          ]),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ...rows.map((r) => _itemRow(context, r, svc)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => showDeleteConfirmDialog(
                context,
                title: 'Clear Buyer Cart',
                message:
                    'Remove all ${rows.length} item(s) from ${_buyerName(buyerId)}\'s cart?',
                onConfirmed: () async {
                  final ok = await svc.clearBuyerCart(buyerId);
                  if (context.mounted) {
                    _toast(context,
                        ok ? 'Cart cleared' : (svc.lastError ?? 'Failed'),
                        error: !ok);
                  }
                },
              ),
              icon: const Icon(Icons.remove_shopping_cart_outlined,
                  size: 16, color: Color(0xFFDC2626)),
              label: const Text('Clear Cart',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(
      BuildContext context, Map<String, dynamic> r, AdminLogisticsService svc) {
    final qty = (r['quantity'] as num?)?.toInt() ?? 1;
    final price = (r['unit_price'] as num?)?.toDouble() ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Text((r['emoji'] ?? '🥬').toString(),
            style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text((r['product_name'] ?? '').toString(),
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: _textDark),
                  overflow: TextOverflow.ellipsis),
              Text(
                  'Rs. ${price.toStringAsFixed(0)}${r['unit'] ?? ''} • ${r['farm_name'] ?? ''}',
                  style: const TextStyle(fontSize: 11, color: _textMuted),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        _qtyBtn(Icons.remove_rounded, () async {
          HapticFeedback.lightImpact();
          await svc.changeCartQuantity(r, -1);
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('$qty',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        ),
        _qtyBtn(Icons.add_rounded, () async {
          HapticFeedback.lightImpact();
          await svc.changeCartQuantity(r, 1);
        }),
        IconButton(
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(6),
          onPressed: () => showAdminCartItemDialog(context, existing: r),
          icon: const Icon(Icons.edit_note_rounded,
              color: Color(0xFF047857), size: 20),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(6),
          onPressed: () => showDeleteConfirmDialog(
            context,
            title: 'Remove Cart Item',
            message: 'Remove ${r['product_name']} from this cart?',
            onConfirmed: () async {
              final ok = await svc.deleteCartItem(r['id'].toString());
              if (context.mounted) {
                _toast(context, ok ? 'Item removed' : (svc.lastError ?? 'Failed'),
                    error: !ok);
              }
            },
          ),
          icon: const Icon(Icons.delete_outline_rounded,
              color: Color(0xFFDC2626), size: 19),
        ),
      ]),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: _borderLight),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16),
        ),
      );
}

void showAdminCartItemDialog(BuildContext context,
    {Map<String, dynamic>? existing}) {
  final svc = AdminLogisticsService.instance;
  final buyers = AdminMarketplaceService.instance.buyers;
  final isNew = existing == null;
  String? buyerId = existing?['buyer_id']?.toString() ??
      (buyers.isNotEmpty ? buyers.first.id : null);
  final name = TextEditingController(text: existing?['product_name']?.toString() ?? '');
  final price = TextEditingController(
      text: existing?['unit_price']?.toString() ?? '');
  final unit = TextEditingController(text: existing?['unit']?.toString() ?? '/kg');
  final qty = TextEditingController(text: existing?['quantity']?.toString() ?? '1');
  final farm = TextEditingController(text: existing?['farm_name']?.toString() ?? '');
  final emoji = TextEditingController(text: existing?['emoji']?.toString() ?? '🥬');
  final formKey = GlobalKey<FormState>();

  final buyerItems = <DropdownMenuItem<String>>[
    for (final b in buyers)
      DropdownMenuItem(value: b.id, child: Text('${b.name} (${b.id})')),
    if (buyerId != null && !buyers.any((b) => b.id == buyerId))
      DropdownMenuItem(value: buyerId, child: Text(buyerId)),
  ];

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isNew ? 'Add Cart Item' : 'Edit Cart Item',
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                DropdownButtonFormField<String>(
                  initialValue: buyerId,
                  isExpanded: true,
                  decoration: _inputDeco('Buyer', icon: Icons.person_outline),
                  items: buyerItems,
                  onChanged: isNew ? (v) => setS(() => buyerId = v) : null,
                  validator: (v) => v == null ? 'Select a buyer' : null,
                ),
                const SizedBox(height: 10),
                _req(name, 'Product name', Icons.inventory_2_outlined),
                const SizedBox(height: 10),
                TextFormField(
                  controller: price,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      _inputDeco('Unit price (Rs.)', icon: Icons.payments_outlined),
                  validator: (v) =>
                      double.tryParse(v ?? '') == null ? 'Enter a number' : null,
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: qty,
                      keyboardType: TextInputType.number,
                      decoration: _inputDeco('Quantity'),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return (n == null || n < 1) ? 'Min 1' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                        controller: unit, decoration: _inputDeco('Unit')),
                  ),
                ]),
                const SizedBox(height: 10),
                TextFormField(
                    controller: farm,
                    decoration: _inputDeco('Farm name', icon: Icons.agriculture)),
                const SizedBox(height: 10),
                TextFormField(
                    controller: emoji, decoration: _inputDeco('Emoji')),
              ]),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _emerald, foregroundColor: Colors.white),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              final id = existing?['id']?.toString() ??
                  '${buyerId}_adm${DateTime.now().millisecondsSinceEpoch % 100000}';
              final row = <String, dynamic>{
                'id': id,
                'buyer_id': buyerId,
                'product_name': name.text.trim(),
                'unit_price': double.parse(price.text.trim()),
                'unit': unit.text.trim(),
                'quantity': int.parse(qty.text.trim()),
                'farm_name': farm.text.trim(),
                'emoji': emoji.text.trim().isEmpty ? '🥬' : emoji.text.trim(),
              };
              final ok = await svc.saveCartItem(row, isNew: isNew);
              if (context.mounted) {
                _toast(
                    context,
                    ok
                        ? (isNew ? 'Cart item added' : 'Cart item updated')
                        : (svc.lastError ?? 'Failed'),
                    error: !ok);
              }
            },
            child: Text(isNew ? 'Add' : 'Save'),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// 🔔 TAB 11: BUYER NOTIFICATIONS (Create / Read / mark read-unread / Delete)
// =============================================================================
class AdminNotificationsTab extends StatelessWidget {
  final String searchQuery;
  const AdminNotificationsTab({super.key, required this.searchQuery});

  static const types = ['Order Updates', 'Offers', 'Harvest Alerts', 'Delivery'];

  @override
  Widget build(BuildContext context) {
    final svc = AdminLogisticsService.instance;
    var list = svc.notifications;
    if (searchQuery.isNotEmpty) {
      list = list.where((n) {
        final hay = [n['title'], n['message'], n['type'], n['buyer_id']]
            .map((e) => (e ?? '').toString().toLowerCase())
            .join(' ');
        return hay.contains(searchQuery);
      }).toList();
    }
    final unread = svc.notifications.where((n) => n['is_read'] != true).length;

    return RefreshIndicator(
      color: _emerald,
      onRefresh: svc.loadAll,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16),
        children: [
          if (svc.notificationsSchemaMissing) _setupBanner('Notifications'),
          Row(children: [
            Expanded(
              child: Text('$unread unread • ${svc.notifications.length} total',
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _textMuted)),
            ),
            TextButton.icon(
              onPressed: unread == 0
                  ? null
                  : () async {
                      final ok = await svc.markAllNotificationsRead();
                      if (context.mounted) {
                        _toast(context,
                            ok ? 'All marked as read' : (svc.lastError ?? 'Failed'),
                            error: !ok);
                      }
                    },
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label: const Text('Mark all as read',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 4),
          if (svc.isLoading && list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(color: _emerald)),
            )
          else if (list.isEmpty)
            Center(
              child: _emptyBox(
                  'No Notifications',
                  'Send a notification to a buyer to see it here.',
                  'Send Notification',
                  () => showAdminNotificationDialog(context)),
            )
          else
            ...list.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _card(context, n, svc),
                )),
        ],
      ),
    );
  }

  IconData _icon(String t) {
    final v = t.toLowerCase();
    if (v.contains('offer')) return Icons.local_offer_rounded;
    if (v.contains('harvest')) return Icons.eco_rounded;
    if (v.contains('deliver')) return Icons.local_shipping_rounded;
    return Icons.receipt_long_rounded;
  }

  Widget _card(BuildContext context, Map<String, dynamic> n,
      AdminLogisticsService svc) {
    final read = n['is_read'] == true;
    final type = (n['type'] ?? 'Order Updates').toString();
    final id = n['id'].toString();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDeco().copyWith(
        color: read ? Colors.white : const Color(0xFFF0FDF4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon(type), color: const Color(0xFF047857), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((n['title'] ?? 'Notification').toString(),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: read ? FontWeight.w600 : FontWeight.w800,
                          color: _textDark)),
                  const SizedBox(height: 3),
                  Text((n['message'] ?? '').toString(),
                      style: const TextStyle(fontSize: 12, color: _textMuted)),
                  const SizedBox(height: 6),
                  Text(
                      '$type • To: ${n['buyer_id'] == null ? 'All buyers' : _buyerName(n['buyer_id'].toString())}',
                      style: const TextStyle(
                          fontSize: 10.5, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            if (!read)
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                    color: _emerald, shape: BoxShape.circle),
              ),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton.icon(
              onPressed: () async {
                final ok = await svc.setNotificationRead(id, !read);
                if (!ok && context.mounted) {
                  _toast(context, svc.lastError ?? 'Failed', error: true);
                }
              },
              icon: Icon(
                  read
                      ? Icons.mark_email_unread_outlined
                      : Icons.mark_email_read_outlined,
                  size: 16),
              label: Text(read ? 'Mark unread' : 'Mark read',
                  style: const TextStyle(fontSize: 11.5)),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
              onPressed: () => showAdminNotificationDialog(context, existing: n),
              icon: const Icon(Icons.edit_note_rounded,
                  color: Color(0xFF047857), size: 20),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
              onPressed: () => showDeleteConfirmDialog(
                context,
                title: 'Delete Notification',
                message: 'Delete "${n['title'] ?? 'this notification'}"?',
                onConfirmed: () async {
                  final ok = await svc.deleteNotification(id);
                  if (context.mounted) {
                    _toast(context,
                        ok ? 'Notification deleted' : (svc.lastError ?? 'Failed'),
                        error: !ok);
                  }
                },
              ),
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626), size: 19),
            ),
          ]),
        ],
      ),
    );
  }
}

void showAdminNotificationDialog(BuildContext context,
    {Map<String, dynamic>? existing}) {
  final svc = AdminLogisticsService.instance;
  final buyers = AdminMarketplaceService.instance.buyers;
  final isNew = existing == null;
  final title = TextEditingController(text: existing?['title']?.toString() ?? '');
  final message =
      TextEditingController(text: existing?['message']?.toString() ?? '');
  String type = AdminNotificationsTab.types.contains(existing?['type']?.toString())
      ? existing!['type'].toString()
      : AdminNotificationsTab.types.first;
  String? buyerId = existing?['buyer_id']?.toString();
  final formKey = GlobalKey<FormState>();

  final targets = <DropdownMenuItem<String?>>[
    const DropdownMenuItem(value: null, child: Text('All buyers')),
    for (final b in buyers)
      DropdownMenuItem(value: b.id, child: Text('${b.name} (${b.id})')),
    if (buyerId != null && !buyers.any((b) => b.id == buyerId))
      DropdownMenuItem(value: buyerId, child: Text(buyerId)),
  ];

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isNew ? 'Send Notification' : 'Edit Notification',
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                DropdownButtonFormField<String?>(
                  initialValue: buyerId,
                  isExpanded: true,
                  decoration: _inputDeco('Send to', icon: Icons.person_outline),
                  items: targets,
                  onChanged: (v) => setS(() => buyerId = v),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: _inputDeco('Type', icon: Icons.category_outlined),
                  items: AdminNotificationsTab.types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setS(() => type = v ?? type),
                ),
                const SizedBox(height: 10),
                _req(title, 'Title', Icons.title_rounded),
                const SizedBox(height: 10),
                TextFormField(
                  controller: message,
                  maxLines: 3,
                  decoration: _inputDeco('Message', icon: Icons.notes_rounded),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ]),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _emerald, foregroundColor: Colors.white),
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              final row = <String, dynamic>{
                'buyer_id': buyerId,
                'title': title.text.trim(),
                'message': message.text.trim(),
                'type': type,
                if (isNew) 'is_read': false,
              };
              final ok = await svc.saveNotification(row,
                  id: existing?['id']?.toString());
              if (context.mounted) {
                _toast(
                    context,
                    ok
                        ? (isNew ? 'Notification sent' : 'Notification updated')
                        : (svc.lastError ?? 'Failed'),
                    error: !ok);
              }
            },
            child: Text(isNew ? 'Send' : 'Save'),
          ),
        ],
      ),
    ),
  );
}

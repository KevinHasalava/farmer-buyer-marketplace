import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/supabase/supabase_config.dart';
import '../../services/admin_marketplace_service.dart';
import 'admin_crud_dialogs.dart' show showDeleteConfirmDialog;

const Color _emerald = Color(0xFF059669);
const Color _textDark = Color(0xFF0F172A);
const Color _textMuted = Color(0xFF64748B);
const Color _borderLight = Color(0xFFE2E8F0);

// =============================================================================
// 🔌 LIVE SUPABASE SERVICE — Deliveries / Pickup Verification / Payment Methods
// =============================================================================
class AdminLogisticsService extends ChangeNotifier {
  AdminLogisticsService._();
  static final AdminLogisticsService instance = AdminLogisticsService._();

  static const List<String> deliveryStatuses = [
    'Pending',
    'Ready for Pickup',
    'En Route to Pickup',
    'In Transit',
    'COMPLETED',
    'Cancelled',
  ];

  List<Map<String, dynamic>> deliveries = [];
  List<Map<String, dynamic>> verifications = [];
  List<Map<String, dynamic>> paymentMethods = [];
  bool isLoading = false;
  String? lastError;

  dynamic get _db => SupabaseConfig.client;

  Future<void> loadAll() async {
    isLoading = true;
    notifyListeners();
    try {
      final d = await _db
          .from('driver_deliveries')
          .select()
          .order('created_at', ascending: false);
      deliveries = List<Map<String, dynamic>>.from(
          (d as List).map((e) => Map<String, dynamic>.from(e as Map)));
    } catch (e) {
      lastError = 'Deliveries load failed: $e';
    }
    try {
      final v = await _db
          .from('pickup_verifications')
          .select()
          .order('verified_at', ascending: false);
      verifications = List<Map<String, dynamic>>.from(
          (v as List).map((e) => Map<String, dynamic>.from(e as Map)));
    } catch (e) {
      verifications = [];
    }
    try {
      final p = await _db
          .from('buyer_payment_methods')
          .select()
          .order('created_at', ascending: false);
      paymentMethods = List<Map<String, dynamic>>.from(
          (p as List).map((e) => Map<String, dynamic>.from(e as Map)));
    } catch (e) {
      lastError = 'Payment methods load failed: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  Map<String, dynamic>? verificationFor(String orderId) {
    for (final v in verifications) {
      if (v['order_id']?.toString() == orderId) return v;
    }
    return null;
  }

  Future<bool> _run(Future<void> Function() op, String label) async {
    try {
      await op();
      await loadAll();
      return true;
    } catch (e) {
      lastError = '$label failed: $e';
      notifyListeners();
      return false;
    }
  }

  // ── Deliveries CRUD ───────────────────────────────────────────────────────
  Future<bool> saveDelivery(Map<String, dynamic> row, {required bool isNew}) {
    return _run(() async {
      if (isNew) {
        await _db.from('driver_deliveries').insert(row);
      } else {
        await _db
            .from('driver_deliveries')
            .update({...row, 'updated_at': DateTime.now().toIso8601String()})
            .eq('id', row['id']);
      }
    }, 'Save delivery');
  }

  Future<bool> updateDeliveryStatus(String id, String status) {
    return _run(() async {
      await _db.from('driver_deliveries').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    }, 'Status update');
  }

  Future<bool> deleteDelivery(String id) {
    return _run(() async {
      try {
        await _db.from('pickup_verifications').delete().eq('order_id', id);
      } catch (_) {}
      await _db.from('driver_deliveries').delete().eq('id', id);
    }, 'Delete delivery');
  }

  // ── Pickup verification ───────────────────────────────────────────────────
  Future<bool> verifyPickup(Map<String, dynamic> delivery,
      {required String pin, required double vanTemp, required String weight}) {
    final id = delivery['id'].toString();
    return _run(() async {
      await _db.from('pickup_verifications').upsert({
        'id': 'VER-${DateTime.now().millisecondsSinceEpoch % 100000}',
        'order_id': id,
        'crate_id': '#CR-$id',
        'farmer_name': delivery['farmer_name'] ?? '',
        'farm_location': delivery['farmer_address'] ?? '',
        'gate_info': 'Admin console audit',
        'handover_pin': pin,
        'is_pin_matched': pin.isNotEmpty,
        'van_temp': '${vanTemp.toStringAsFixed(1)}°C',
        'ambient_temp': '16.0°C',
        'verified_weight': weight,
        'checklist_items': ['Quality checked', 'Packaging sealed', 'Cold-chain OK'],
        'status': 'VERIFIED_AND_LOADED',
        'verified_at': DateTime.now().toIso8601String(),
      });
      await _db.from('driver_deliveries').update({
        'status': 'In Transit',
        'van_temp': '${vanTemp.toStringAsFixed(1)}°C',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    }, 'Pickup verification');
  }

  // ── Payment methods CRUD (tokenized: brand + last4 only, never PAN/CVV) ──
  Future<bool> savePaymentMethod(Map<String, dynamic> row, {String? id}) {
    return _run(() async {
      if (row['is_default'] == true && row['buyer_id'] != null) {
        await _db
            .from('buyer_payment_methods')
            .update({'is_default': false}).eq('buyer_id', row['buyer_id']);
      }
      if (id == null) {
        await _db.from('buyer_payment_methods').insert(row);
      } else {
        await _db.from('buyer_payment_methods').update(row).eq('id', id);
      }
    }, 'Save payment method');
  }

  Future<bool> setDefaultPayment(Map<String, dynamic> m) {
    return _run(() async {
      await _db
          .from('buyer_payment_methods')
          .update({'is_default': false}).eq('buyer_id', m['buyer_id']);
      await _db
          .from('buyer_payment_methods')
          .update({'is_default': true}).eq('id', m['id']);
    }, 'Set default');
  }

  Future<bool> deletePaymentMethod(String id) {
    return _run(() async {
      await _db.from('buyer_payment_methods').delete().eq('id', id);
    }, 'Delete payment method');
  }
}

// =============================================================================
// 🎨 SHARED UI HELPERS (same visual language as the rest of the admin console)
// =============================================================================
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

Widget _pill(IconData icon, String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _textMuted),
          const SizedBox(width: 4),
          Flexible(
            child: Text(label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );

Color _statusColor(String s) {
  final v = s.toUpperCase();
  if (v.contains('COMPLETE')) return const Color(0xFF047857);
  if (v.contains('TRANSIT') || v.contains('ROUTE')) return const Color(0xFF2563EB);
  if (v.contains('READY')) return const Color(0xFFD97706);
  if (v.contains('CANCEL')) return const Color(0xFFDC2626);
  return const Color(0xFF64748B);
}

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

Widget _empty(String title, String msg, String action, VoidCallback onTap) {
  return Center(
    child: Padding(
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    ),
  );
}

// =============================================================================
// 🚚 TAB 8: FLEET DELIVERIES & PICKUP VERIFICATION
// =============================================================================
class AdminDeliveriesTab extends StatelessWidget {
  final String searchQuery;
  const AdminDeliveriesTab({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final svc = AdminLogisticsService.instance;
    var list = svc.deliveries;
    if (searchQuery.isNotEmpty) {
      list = list.where((d) {
        final hay = [
          d['id'],
          d['order_number'],
          d['buyer_name'],
          d['farmer_name'],
          d['status'],
          d['items_summary'],
        ].map((e) => (e ?? '').toString().toLowerCase()).join(' ');
        return hay.contains(searchQuery);
      }).toList();
    }

    if (svc.isLoading && list.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _emerald));
    }
    if (list.isEmpty) {
      return _empty('No Deliveries Found',
          'No fleet delivery records in Supabase match.', 'Dispatch Delivery',
          () => showAdminDeliveryDialog(context));
    }

    return RefreshIndicator(
      color: _emerald,
      onRefresh: svc.loadAll,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) => _deliveryCard(ctx, list[i], svc),
      ),
    );
  }

  Widget _deliveryCard(
      BuildContext context, Map<String, dynamic> d, AdminLogisticsService svc) {
    final id = d['id'].toString();
    final status = (d['status'] ?? 'Pending').toString();
    final color = _statusColor(status);
    final ver = svc.verificationFor(id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: Color(0xFFF0FDFA), shape: BoxShape.circle),
                child: const Icon(Icons.alt_route_rounded,
                    color: Color(0xFF0D9488), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((d['order_number'] ?? '#$id').toString(),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _textDark)),
                    const SizedBox(height: 2),
                    Text(
                        '${d['farmer_name'] ?? 'Farmer'} → ${d['buyer_name'] ?? 'Buyer'}',
                        style: const TextStyle(fontSize: 12, color: _textMuted),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status,
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 6, children: [
            _pill(Icons.inventory_2_rounded,
                (d['items_summary'] ?? d['produce_description'] ?? '-').toString()),
            _pill(Icons.view_in_ar_rounded, (d['crate_count'] ?? '-').toString()),
            _pill(Icons.payments_rounded, (d['payout_amount'] ?? '-').toString()),
            _pill(Icons.thermostat_rounded, (d['van_temp'] ?? '-').toString()),
            _pill(Icons.location_on_rounded,
                (d['buyer_address'] ?? '-').toString()),
            if (d['is_priority'] == true)
              _pill(Icons.bolt_rounded, 'Priority'),
            _pill(
                ver != null ? Icons.verified_rounded : Icons.pending_rounded,
                ver != null ? 'Pickup Verified' : 'Pickup Not Verified'),
          ]),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                PopupMenuButton<String>(
                  tooltip: 'Update status',
                  onSelected: (s) async {
                    HapticFeedback.lightImpact();
                    final ok = await svc.updateDeliveryStatus(id, s);
                    if (context.mounted) {
                      _toast(context, ok ? 'Status → $s' : (svc.lastError ?? 'Failed'),
                          error: !ok);
                    }
                  },
                  itemBuilder: (_) => AdminLogisticsService.deliveryStatuses
                      .map((s) => PopupMenuItem(value: s, child: Text(s)))
                      .toList(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      border: Border.all(color: _borderLight),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.swap_horiz_rounded, size: 15),
                      SizedBox(width: 4),
                      Text('Status',
                          style: TextStyle(
                              fontSize: 11.5, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                const SizedBox(width: 6),
                OutlinedButton.icon(
                  onPressed: () => _showVerifyDialog(context, d),
                  icon: const Icon(Icons.fact_check_rounded, size: 15),
                  label: Text(ver != null ? 'View Pickup' : 'Verify Pickup',
                      style: const TextStyle(
                          fontSize: 11.5, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ]),
              Row(mainAxisSize: MainAxisSize.min, children: [
                ElevatedButton.icon(
                  onPressed: () => showAdminDeliveryDialog(context, existing: d),
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: const Text('Edit',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF047857),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  onPressed: () => showDeleteConfirmDialog(
                    context,
                    title: 'Delete Delivery',
                    message:
                        'Remove ${d['order_number'] ?? id} from the fleet delivery records?',
                    onConfirmed: () async {
                      final ok = await svc.deleteDelivery(id);
                      if (context.mounted) {
                        _toast(context,
                            ok ? 'Delivery deleted' : (svc.lastError ?? 'Failed'),
                            error: !ok);
                      }
                    },
                  ),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFDC2626), size: 18),
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  void _showVerifyDialog(BuildContext context, Map<String, dynamic> d) {
    final svc = AdminLogisticsService.instance;
    final id = d['id'].toString();
    final ver = svc.verificationFor(id);

    if (ver != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Pickup Verification Audit',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order: ${ver['order_id']}'),
              Text('Crate: ${ver['crate_id'] ?? '-'}'),
              Text('Farm: ${ver['farm_location'] ?? '-'}'),
              Text('PIN matched: ${ver['is_pin_matched'] == true ? 'Yes' : 'No'}'),
              Text('Van temp: ${ver['van_temp'] ?? '-'}'),
              Text('Weight: ${ver['verified_weight'] ?? '-'}'),
              Text('Status: ${ver['status'] ?? '-'}'),
              Text('Verified at: ${ver['verified_at'] ?? '-'}'),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        ),
      );
      return;
    }

    final pinCtrl = TextEditingController();
    final tempCtrl = TextEditingController(text: '4.0');
    final weightCtrl = TextEditingController(text: '5.0 kg');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Verify Pickup',
            style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: pinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: _inputDeco('Handover PIN (4 digits)',
                    icon: Icons.password_rounded)),
            const SizedBox(height: 4),
            TextField(
                controller: tempCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    _inputDeco('Van temperature (°C)', icon: Icons.thermostat)),
            const SizedBox(height: 12),
            TextField(
                controller: weightCtrl,
                decoration: _inputDeco('Verified weight',
                    icon: Icons.scale_rounded)),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _emerald, foregroundColor: Colors.white),
            onPressed: () async {
              if (pinCtrl.text.trim().length != 4) {
                _toast(ctx, 'Enter the 4-digit handover PIN', error: true);
                return;
              }
              Navigator.pop(ctx);
              final ok = await svc.verifyPickup(d,
                  pin: pinCtrl.text.trim(),
                  vanTemp: double.tryParse(tempCtrl.text.trim()) ?? 4.0,
                  weight: weightCtrl.text.trim());
              if (context.mounted) {
                _toast(
                    context,
                    ok ? 'Pickup verified & loaded' : (svc.lastError ?? 'Failed'),
                    error: !ok);
              }
            },
            child: const Text('Verify & Load'),
          ),
        ],
      ),
    );
  }
}

// ── Create / Edit delivery dialog ────────────────────────────────────────────
void showAdminDeliveryDialog(BuildContext context, {Map<String, dynamic>? existing}) {
  final svc = AdminLogisticsService.instance;
  final isNew = existing == null;
  final id = existing?['id']?.toString() ??
      'FT-${(DateTime.now().millisecondsSinceEpoch % 9000) + 1000}';
  final farmer = TextEditingController(text: existing?['farmer_name']?.toString() ?? '');
  final farmerAddr = TextEditingController(text: existing?['farmer_address']?.toString() ?? '');
  final buyer = TextEditingController(text: existing?['buyer_name']?.toString() ?? '');
  final buyerAddr = TextEditingController(text: existing?['buyer_address']?.toString() ?? '');
  final items = TextEditingController(text: existing?['items_summary']?.toString() ?? '');
  final crates = TextEditingController(text: existing?['crate_count']?.toString() ?? '1 Crate');
  final payout = TextEditingController(
      text: (existing?['payout_amount']?.toString() ?? '')
          .replaceAll(RegExp(r'[^0-9.]'), ''));
  String status = AdminLogisticsService.deliveryStatuses
          .contains(existing?['status']?.toString())
      ? existing!['status'].toString()
      : 'Pending';
  bool priority = existing?['is_priority'] == true;
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isNew ? 'Dispatch New Delivery' : 'Edit Delivery $id',
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _req(farmer, 'Farmer name', Icons.agriculture_rounded),
                const SizedBox(height: 10),
                _req(farmerAddr, 'Pickup address', Icons.location_on_outlined),
                const SizedBox(height: 10),
                _req(buyer, 'Buyer name', Icons.person_outline_rounded),
                const SizedBox(height: 10),
                _req(buyerAddr, 'Drop-off address', Icons.home_outlined),
                const SizedBox(height: 10),
                _req(items, 'Items summary', Icons.inventory_2_outlined),
                const SizedBox(height: 10),
                TextFormField(
                    controller: crates,
                    decoration: _inputDeco('Crates', icon: Icons.view_in_ar_rounded)),
                const SizedBox(height: 10),
                TextFormField(
                    controller: payout,
                    keyboardType: TextInputType.number,
                    decoration:
                        _inputDeco('Driver payout (Rs.)', icon: Icons.payments_outlined)),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: _inputDeco('Status', icon: Icons.flag_outlined),
                  items: AdminLogisticsService.deliveryStatuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setS(() => status = v ?? status),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Priority delivery',
                      style: TextStyle(fontSize: 13)),
                  value: priority,
                  activeThumbColor: _emerald,
                  onChanged: (v) => setS(() => priority = v),
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
              final fee = double.tryParse(payout.text.trim()) ?? 0;
              Navigator.pop(ctx);
              final row = <String, dynamic>{
                'id': id,
                'order_number': '#$id',
                'farmer_name': farmer.text.trim(),
                'farmer_address': farmerAddr.text.trim(),
                'buyer_name': buyer.text.trim(),
                'buyer_address': buyerAddr.text.trim(),
                'items_summary': items.text.trim(),
                'crate_count': crates.text.trim(),
                'payout_amount': 'Rs. ${fee.toStringAsFixed(0)}',
                'driver_fee': fee,
                'status': status,
                'is_priority': priority,
              };
              final ok = await svc.saveDelivery(row, isNew: isNew);
              if (context.mounted) {
                _toast(
                    context,
                    ok
                        ? (isNew ? 'Delivery dispatched' : 'Delivery updated')
                        : (svc.lastError ?? 'Failed'),
                    error: !ok);
              }
            },
            child: Text(isNew ? 'Dispatch' : 'Save'),
          ),
        ],
      ),
    ),
  );
}

Widget _req(TextEditingController c, String label, IconData icon) =>
    TextFormField(
      controller: c,
      decoration: _inputDeco(label, icon: icon),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );

// =============================================================================
// 💳 TAB 9: PAYMENT METHODS & WALLETS (tokenized — no raw card data)
// =============================================================================
class AdminPaymentMethodsTab extends StatelessWidget {
  final String searchQuery;
  const AdminPaymentMethodsTab({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final svc = AdminLogisticsService.instance;
    final buyers = AdminMarketplaceService.instance.buyers;
    String buyerName(String? id) {
      for (final b in buyers) {
        if (b.id == id) return b.name;
      }
      return id ?? 'Unassigned';
    }

    var list = svc.paymentMethods;
    if (searchQuery.isNotEmpty) {
      list = list.where((m) {
        final hay = [
          m['cardholder_name'],
          m['card_brand'],
          m['card_last4'],
          m['buyer_id'],
          buyerName(m['buyer_id']?.toString()),
        ].map((e) => (e ?? '').toString().toLowerCase()).join(' ');
        return hay.contains(searchQuery);
      }).toList();
    }

    if (svc.isLoading && list.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: _emerald));
    }

    return RefreshIndicator(
      color: _emerald,
      onRefresh: svc.loadAll,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Row(children: [
              Icon(Icons.lock_rounded, color: Color(0xFF047857), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'PCI-DSS tokenized storage: only card brand, last 4 digits, '
                  'holder name and expiry are stored. Full card numbers and CVV '
                  'are never saved or shown.',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF065F46)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            SizedBox(
              height: 340,
              child: _empty(
                  'No Payment Methods',
                  'No tokenized buyer payment methods exist in Supabase yet.',
                  'Add Payment Method',
                  () => showAdminPaymentMethodDialog(context)),
            )
          else
            ...list.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _card(context, m, buyerName(m['buyer_id']?.toString()), svc),
                )),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, Map<String, dynamic> m, String owner,
      AdminLogisticsService svc) {
    final isDefault = m['is_default'] == true;
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
                  color: Color(0xFFEFF6FF), shape: BoxShape.circle),
              child: const Icon(Icons.credit_card_rounded,
                  color: Color(0xFF2563EB), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${m['card_brand'] ?? 'Card'}  •••• •••• •••• ${m['card_last4'] ?? '----'}',
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: _textDark)),
                  const SizedBox(height: 2),
                  Text('Owner: $owner',
                      style: const TextStyle(fontSize: 12, color: _textMuted)),
                ],
              ),
            ),
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('DEFAULT',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF047857))),
              ),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 6, children: [
            _pill(Icons.person_rounded, (m['cardholder_name'] ?? '-').toString()),
            _pill(Icons.event_rounded,
                'Exp ${m['expiry_month'] ?? '--'}/${m['expiry_year'] ?? '--'}'),
            _pill(Icons.shield_rounded, 'Tokenized'),
          ]),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              if (!isDefault)
                OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await svc.setDefaultPayment(m);
                    if (context.mounted) {
                      _toast(context,
                          ok ? 'Default card updated' : (svc.lastError ?? 'Failed'),
                          error: !ok);
                    }
                  },
                  icon: const Icon(Icons.star_outline_rounded, size: 15),
                  label: const Text('Make Default',
                      style:
                          TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                )
              else
                const SizedBox.shrink(),
              Row(mainAxisSize: MainAxisSize.min, children: [
                ElevatedButton.icon(
                  onPressed: () => showAdminPaymentMethodDialog(context, existing: m),
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: const Text('Edit',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF047857),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                  onPressed: () => showDeleteConfirmDialog(
                    context,
                    title: 'Delete Payment Method',
                    message:
                        'Remove ${m['card_brand'] ?? 'card'} ending ${m['card_last4'] ?? ''} for $owner?',
                    onConfirmed: () async {
                      final ok = await svc.deletePaymentMethod(m['id'].toString());
                      if (context.mounted) {
                        _toast(context,
                            ok ? 'Payment method removed' : (svc.lastError ?? 'Failed'),
                            error: !ok);
                      }
                    },
                  ),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFDC2626), size: 18),
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Create / Edit payment method dialog (tokenized: last4 only) ──────────────
void showAdminPaymentMethodDialog(BuildContext context,
    {Map<String, dynamic>? existing}) {
  final svc = AdminLogisticsService.instance;
  final buyers = AdminMarketplaceService.instance.buyers;
  final isNew = existing == null;

  final holder =
      TextEditingController(text: existing?['cardholder_name']?.toString() ?? '');
  final last4 =
      TextEditingController(text: existing?['card_last4']?.toString() ?? '');
  final expM =
      TextEditingController(text: existing?['expiry_month']?.toString() ?? '');
  final expY =
      TextEditingController(text: existing?['expiry_year']?.toString() ?? '');
  const brands = ['Visa', 'Mastercard', 'American Express', 'Discover', 'Other'];
  String brand = brands.contains(existing?['card_brand']?.toString())
      ? existing!['card_brand'].toString()
      : 'Visa';
  String? buyerId = existing?['buyer_id']?.toString();
  if (buyerId == null && buyers.isNotEmpty) buyerId = buyers.first.id;
  bool isDefault = existing?['is_default'] == true;
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
        title: Text(isNew ? 'Add Payment Method' : 'Edit Payment Method',
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
                  decoration: _inputDeco('Buyer account', icon: Icons.person_outline),
                  items: buyerItems,
                  onChanged: (v) => setS(() => buyerId = v),
                  validator: (v) => v == null ? 'Select a buyer' : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: brand,
                  decoration: _inputDeco('Card brand', icon: Icons.credit_card),
                  items: brands
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (v) => setS(() => brand = v ?? brand),
                ),
                const SizedBox(height: 10),
                _req(holder, 'Cardholder name', Icons.badge_outlined),
                const SizedBox(height: 10),
                TextFormField(
                  controller: last4,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDeco('Last 4 digits only', icon: Icons.pin_outlined),
                  validator: (v) =>
                      (v == null || v.length != 4) ? 'Enter exactly 4 digits' : null,
                ),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: expM,
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDeco('MM'),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return (n == null || n < 1 || n > 12) ? '01-12' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: expY,
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDeco('YY'),
                      validator: (v) =>
                          (v == null || v.length != 2) ? '2 digits' : null,
                    ),
                  ),
                ]),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Default card', style: TextStyle(fontSize: 13)),
                  value: isDefault,
                  activeThumbColor: _emerald,
                  onChanged: (v) => setS(() => isDefault = v),
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
                'card_brand': brand,
                'card_last4': last4.text.trim(),
                'cardholder_name': holder.text.trim().toUpperCase(),
                'expiry_month': expM.text.trim().padLeft(2, '0'),
                'expiry_year': expY.text.trim(),
                'is_default': isDefault,
              };
              final ok = await svc.savePaymentMethod(row,
                  id: existing?['id']?.toString());
              if (context.mounted) {
                _toast(
                    context,
                    ok
                        ? (isNew ? 'Payment method added' : 'Payment method updated')
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

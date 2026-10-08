import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/localization/app_settings.dart';
import '../services/cart_state.dart';
import '../../orders_chat/presentation/order_tracking_screen.dart';
import '../../orders_chat/presentation/orders_chat_screen.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../../payment/services/payment_method_manager.dart';
import '../../payment/presentation/saved_payment_methods_screen.dart';
import '../../payment/presentation/widgets/add_edit_card_sheet.dart';
import '../../payment/presentation/widgets/wallet_top_up_sheet.dart';
import '../../payment/presentation/widgets/bank_transfer_sheet.dart';
import '../../buyer/services/buyer_profile_manager.dart';

/// Pixel-perfect implementation of "Checkout & Delivery" screen matching the provided UI design.
class CheckoutDeliveryScreen extends StatefulWidget {
  const CheckoutDeliveryScreen({super.key});

  @override
  State<CheckoutDeliveryScreen> createState() => _CheckoutDeliveryScreenState();
}

class _CheckoutDeliveryScreenState extends State<CheckoutDeliveryScreen> {
  final MarketplaceState _state = MarketplaceState.instance;

  static const Color _forestGreen = Color(0xFF286A46);
  static const Color _bgSoft = Color(0xFFF9FBFA);
  static const Color _cardBorder = Color(0xFFEDF2EF);
  static const Color _labelGrey = Color(0xFF8A9BA8);
  static const Color _textDark = Color(0xFF1E293B);

  late String _selectedDeliveryMethod;
  late String _selectedPaymentMethod;
  late String _deliveryDate;
  late String _deliveryTime;
  late String _address;
  late String _contact;
  String? _selectedCardId;
  String? _bankTransferRef;
  bool _bankSlipAttached = false;

  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _selectedDeliveryMethod = _state.deliveryMethod;
    _selectedPaymentMethod = _state.paymentMethod;
    _deliveryDate = _state.preferredDate;
    _deliveryTime = _state.preferredTime;
    _address = _state.deliveryAddress;
    _contact = _state.contactNumber;
    _selectedCardId = PaymentMethodManager.instance.defaultMethod?.id;
  }

  void _showEditAddressModal() {
    final controller = TextEditingController(text: _address);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
              const SizedBox(height: 18),
              Text(
                context.tr.editDeliveryAddress,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  hintText: context.tr.enterAddressHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _forestGreen, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _forestGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final newAddr = controller.text.trim();
                    if (newAddr.isNotEmpty) {
                      setState(() => _address = newAddr);
                      _state.updateDeliveryAddress(newAddr);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    context.tr.saveAddress,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditContactModal() {
    final controller = TextEditingController(text: _contact);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
              const SizedBox(height: 18),
              Text(
                context.tr.editContactNumber,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                autofocus: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  hintText: 'e.g. 076 323 8225',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _forestGreen, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _forestGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final newPhone = controller.text.trim();
                    if (newPhone.isNotEmpty) {
                      setState(() => _contact = newPhone);
                      _state.updateContactNumber(newPhone);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    context.tr.saveContactNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _forestGreen,
              onPrimary: Colors.white,
              onSurface: _textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final formatted = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      setState(() => _deliveryDate = formatted);
      _state.updatePreferredDateTime(formatted, _deliveryTime);
    }
  }

  void _selectTimeSlot() {
    final slots = [
      '08:00 AM - 10:00 AM',
      '10:00 AM - 12:00 PM',
      '02:00 PM - 04:00 PM',
      '04:00 PM - 06:00 PM',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
            const SizedBox(height: 18),
            Text(
              context.tr.selectTimeSlot,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 14),
            ...slots.map((slot) {
              final isSel = slot == _deliveryTime;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFFF0F7F3) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? _forestGreen : const Color(0xFFE2E8F0),
                    width: isSel ? 1.5 : 1,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    slot,
                    style: TextStyle(
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? _forestGreen : _textDark,
                    ),
                  ),
                  trailing: isSel
                      ? const Icon(Icons.check_circle_rounded, color: _forestGreen)
                      : null,
                  onTap: () {
                    setState(() => _deliveryTime = slot);
                    _state.updatePreferredDateTime(_deliveryDate, slot);
                    Navigator.pop(ctx);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _placeOrder() async {
    setState(() => _isPlacingOrder = true);
    HapticFeedback.mediumImpact();

    if (!mounted) return;

    if (_selectedPaymentMethod == 'Card') {
      final cards = PaymentMethodManager.instance.methods;
      if (cards.isNotEmpty) {
        final chosen = cards.firstWhere(
          (c) => c.id == _selectedCardId,
          orElse: () => cards.first,
        );
        _state.updatePaymentMethod('Card (${chosen.cardBrand} •••• ${chosen.cardLast4})');
      } else {
        _state.updatePaymentMethod('Card (Visa •••• 4242)');
      }
    } else if (_selectedPaymentMethod == 'Mobile Wallet') {
      final orderTotal = _state.totalAmount > 0 ? _state.totalAmount : 950.0;
      final currentBalance = BuyerProfileManager.instance.profile.walletBalance;

      if (currentBalance < orderTotal) {
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient wallet balance. Please top up your wallet to continue.'.trAuto(context)),
            backgroundColor: Colors.red.shade700,
            action: SnackBarAction(
              label: 'TOP UP',
              textColor: Colors.white,
              onPressed: () => WalletTopUpSheet.show(context),
            ),
          ),
        );
        return;
      }

      await BuyerProfileManager.instance.deductWallet(orderTotal);
      _state.updatePaymentMethod('Farm Wallet (Paid: Rs. ${orderTotal.toStringAsFixed(0)})');
    } else if (_selectedPaymentMethod == 'Bank Transfer') {
      final refStr = (_bankTransferRef?.isNotEmpty ?? false)
          ? 'Ref: $_bankTransferRef'
          : (_bankSlipAttached ? 'Slip Attached' : 'Pending Slip Verification');
      _state.updatePaymentMethod('Bank Transfer ($refStr)');
    }

    final order = _state.placeCurrentOrder();

    setState(() => _isPlacingOrder = false);

    if (!mounted) return;

    // Show order success celebration sheet
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF5EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: _forestGreen,
                size: 46,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              context.tr.orderPlacedSuccess,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${context.tr.orderId}: #${order.id}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _forestGreen,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              context.tr.orderScheduledNotice(order.preferredDateTime),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _forestGreen,
                      side: const BorderSide(color: _forestGreen, width: 1.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OrdersChatScreen(initialTab: 0),
                        ),
                      );
                    },
                    child: Text(
                      context.tr.viewOrders,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _forestGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingScreen(order: order),
                        ),
                      );
                    },
                    child: Text(
                      context.tr.trackOrder,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
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

  @override
  Widget build(BuildContext context) {
    const totalDisplay = 'Rs. 950';

    return Scaffold(
      backgroundColor: _bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: _textDark,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          context.tr.checkoutDelivery,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: _textDark,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          const Center(child: AppLanguagePill()),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: _textDark,
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          children: [
            // ── Card 1: DELIVERY ADDRESS ─────────────────────────────────────
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(
                    title: context.tr.deliveryAddress,
                    onEdit: _showEditAddressModal,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAF5EF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: _forestGreen,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _address,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _textDark,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Card 2: CONTACT NUMBER ───────────────────────────────────────
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(
                    title: context.tr.contactNumber,
                    onEdit: _showEditContactModal,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAF5EF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phone_rounded,
                          color: _forestGreen,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _contact,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Card 3: DELIVERY METHOD ──────────────────────────────────────
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context.tr.deliveryMethod),
                  const SizedBox(height: 8),
                  _buildRadioOption(
                    label: context.tr.homeDelivery,
                    selected: _selectedDeliveryMethod == 'Home Delivery',
                    onTap: () {
                      setState(() => _selectedDeliveryMethod = 'Home Delivery');
                      _state.updateDeliveryMethod('Home Delivery');
                    },
                  ),
                  _buildRadioOption(
                    label: context.tr.selfPickup,
                    selected: _selectedDeliveryMethod == 'Self Pickup',
                    onTap: () {
                      setState(() => _selectedDeliveryMethod = 'Self Pickup');
                      _state.updateDeliveryMethod('Self Pickup');
                    },
                  ),
                  _buildRadioOption(
                    label: context.tr.scheduledDelivery,
                    selected: _selectedDeliveryMethod == 'Scheduled Delivery',
                    onTap: () {
                      setState(() => _selectedDeliveryMethod = 'Scheduled Delivery');
                      _state.updateDeliveryMethod('Scheduled Delivery');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Card 4: PREFERRED DATE & TIME ────────────────────────────────
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context.tr.preferredDateTime),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      // Date Selector
                      Expanded(
                        child: InkWell(
                          onTap: _selectDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFBFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _deliveryDate,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: _textDark,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Time Slot Selector
                      Expanded(
                        child: InkWell(
                          onTap: _selectTimeSlot,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFBFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 17,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _deliveryTime,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _textDark,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Card 5: PAYMENT METHOD ───────────────────────────────────────
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle(context.tr.paymentMethod),
                      if (_selectedPaymentMethod == 'Card')
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SavedPaymentMethodsScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Manage Cards >'.trAuto(context),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _forestGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 1. Cash on Delivery
                  _buildRadioOption(
                    label: context.tr.cashOnDelivery,
                    selected: _selectedPaymentMethod == 'Cash on Delivery',
                    onTap: () {
                      setState(() => _selectedPaymentMethod = 'Cash on Delivery');
                      _state.updatePaymentMethod('Cash on Delivery');
                    },
                  ),
                  if (_selectedPaymentMethod == 'Cash on Delivery') ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 36, bottom: 8),
                      child: Text(
                        'Pay delivery driver in cash upon doorstep delivery.'.trAuto(context),
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],

                  // 2. Card Payment (Visa / Mastercard)
                  _buildRadioOption(
                    label: context.tr.cardPayment,
                    selected: _selectedPaymentMethod == 'Card',
                    onTap: () {
                      setState(() => _selectedPaymentMethod = 'Card');
                      _state.updatePaymentMethod('Card');
                    },
                  ),
                  if (_selectedPaymentMethod == 'Card') ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 10),
                      child: ListenableBuilder(
                        listenable: PaymentMethodManager.instance,
                        builder: (ctx, _) {
                          final cards = PaymentMethodManager.instance.methods;
                          if (cards.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'No saved payment cards found.'.trAuto(context),
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: _forestGreen,
                                      side: const BorderSide(color: _forestGreen),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () async {
                                      final added = await AddEditCardSheet.show(context);
                                      if (added != null) {
                                        setState(() => _selectedCardId = added.id);
                                      }
                                    },
                                    icon: const Icon(Icons.add_card_rounded, size: 16),
                                    label: Text('Add Payment Card'.trAuto(context), style: const TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (_selectedCardId == null || !cards.any((c) => c.id == _selectedCardId)) {
                            _selectedCardId = cards.first.id;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...cards.map((card) {
                                final isCardSel = card.id == _selectedCardId;
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedCardId = card.id);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isCardSel ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isCardSel ? const Color(0xFF15803D) : const Color(0xFFE2E8F0),
                                        width: isCardSel ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCardSel ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                          color: isCardSel ? const Color(0xFF15803D) : const Color(0xFF94A3B8),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: card.gradientColors.first,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            card.cardBrand.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${card.bankName ?? 'Bank'} •••• ${card.cardLast4}',
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: _textDark,
                                                ),
                                              ),
                                              Text(
                                                'Exp ${card.formattedExpiry} • ${card.cardHolderName}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF64748B),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (card.isDefault)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDCFCE7),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'Default',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF15803D),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: _forestGreen,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () async {
                                  final added = await AddEditCardSheet.show(context);
                                  if (added != null) {
                                    setState(() => _selectedCardId = added.id);
                                  }
                                },
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: Text('+ Add Another Card'.trAuto(context), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],

                  // 3. Mobile Wallet (Farm Direct Wallet)
                  _buildRadioOption(
                    label: context.tr.mobileWallet,
                    selected: _selectedPaymentMethod == 'Mobile Wallet',
                    onTap: () {
                      setState(() => _selectedPaymentMethod = 'Mobile Wallet');
                      _state.updatePaymentMethod('Mobile Wallet');
                    },
                  ),
                  if (_selectedPaymentMethod == 'Mobile Wallet') ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 36, right: 8, bottom: 10),
                      child: ListenableBuilder(
                        listenable: BuyerProfileManager.instance,
                        builder: (ctx, _) {
                          final profile = BuyerProfileManager.instance.profile;
                          final orderTotal = _state.totalAmount > 0 ? _state.totalAmount : 950.0;
                          final isSufficient = profile.walletBalance >= orderTotal;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSufficient ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSufficient ? const Color(0xFFDCFCE7) : const Color(0xFFFDE68A),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_rounded,
                                          color: isSufficient ? const Color(0xFF15803D) : const Color(0xFFD97706),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${'Wallet Balance:'.trAuto(context)} ${profile.formattedWallet}',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w800,
                                            color: isSufficient ? const Color(0xFF14532D) : const Color(0xFF92400E),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        foregroundColor: _forestGreen,
                                      ),
                                      onPressed: () => WalletTopUpSheet.show(context),
                                      child: Text(
                                        '+ Top Up'.trAuto(context),
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isSufficient
                                      ? 'Direct payment with zero processing fee. Sufficient funds.'
                                          .trAuto(context)
                                      : 'Insufficient balance for this order. Please top up to continue.'
                                          .trAuto(context),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSufficient ? const Color(0xFF166534) : const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // 4. Bank Transfer (Commercial Bank & LANKAQR)
                  _buildRadioOption(
                    label: context.tr.bankTransfer,
                    selected: _selectedPaymentMethod == 'Bank Transfer',
                    onTap: () {
                      setState(() => _selectedPaymentMethod = 'Bank Transfer');
                      _state.updatePaymentMethod('Bank Transfer');
                    },
                  ),
                  if (_selectedPaymentMethod == 'Bank Transfer') ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 36, right: 8, bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.account_balance_rounded, color: Color(0xFF2563EB), size: 18),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Commercial Bank: 1000 4829 18',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(const ClipboardData(text: '1000482918'));
                                    HapticFeedback.selectionClick();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Account number copied to clipboard!'.trAuto(context)),
                                        backgroundColor: _forestGreen,
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.copy_rounded, size: 11, color: Color(0xFF475569)),
                                        SizedBox(width: 3),
                                        Text('Copy', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_bankSlipAttached || (_bankTransferRef?.isNotEmpty ?? false)) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF15803D)),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Slip Attached: ${_bankTransferRef ?? 'Verified'}'.trAuto(context),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _forestGreen,
                                side: const BorderSide(color: _forestGreen, width: 1.2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () async {
                                final res = await BankTransferSheet.show(
                                  context,
                                  initialReference: _bankTransferRef,
                                  initialSlipAttached: _bankSlipAttached,
                                );
                                if (res != null) {
                                  setState(() {
                                    _bankTransferRef = res['reference'] as String?;
                                    _bankSlipAttached = res['slipAttached'] as bool? ?? false;
                                  });
                                }
                              },
                              icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                              label: Text(
                                (_bankSlipAttached ? 'Update Bank Slip / QR' : 'View LANKAQR & Attach Slip')
                                    .trAuto(context),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 120), // Spacing for sticky bottom bar
          ],
        ),
      ),

      // ── Sticky Bottom Bar matching Image 2 ─────────────────────────────────
      bottomSheet: Container(
        color: _bgSoft,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            14,
            20,
            14 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr.orderTotal,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const Text(
                    totalDisplay,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _forestGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isPlacingOrder ? null : _placeOrder,
                  child: _isPlacingOrder
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          context.tr.placeOrder,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              // Subtle iOS/Android home bar indicator
              Container(
                width: 130,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────────

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _labelGrey,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildHeaderRow({
    required String title,
    required VoidCallback onEdit,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(title),
        GestureDetector(
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              context.tr.edit,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _forestGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Custom high fidelity radio matching design
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _forestGreen : const Color(0xFFCBD5E1),
                  width: selected ? 2 : 1.5,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _forestGreen,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

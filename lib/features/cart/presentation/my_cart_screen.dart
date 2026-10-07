import '../../buyer/models/buyer_models.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_settings.dart';

import '../models/cart_item_model.dart';
import '../services/cart_state.dart';
import 'checkout_delivery_screen.dart';
import '../../../widgets/premium/premium_widgets.dart';

/// Premium "My Cart" screen matching the exact design aesthetic of the Checkout & Delivery UI.
class MyCartScreen extends StatefulWidget {
  const MyCartScreen({super.key});

  @override
  State<MyCartScreen> createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  final MarketplaceState _state = MarketplaceState.instance;

  static const Color _forestGreen = Color(0xFF286A46);
  static const Color _bgSoft = Color(0xFFF9FBFA);
  static const Color _cardBorder = Color(0xFFEDF2EF);
  static const Color _textDark = Color(0xFF1E293B);
  static const Color _labelGrey = Color(0xFF8A9BA8);

  final TextEditingController _promoController = TextEditingController();
  bool _isPromoApplied = true;

  @override
  void initState() {
    super.initState();
    _promoController.text = _state.promoCode;
    _state.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChange);
    _promoController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _applyPromo() {
    final code = _promoController.text.trim();
    if (code.isNotEmpty) {
      _state.applyPromoCode(code);
      setState(() => _isPromoApplied = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo code "$code" applied successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _forestGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _state.cartItems;
    final totalCount = _state.totalItemCount;

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr.myCart,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: _textDark,
                letterSpacing: -0.3,
              ),
            ),
            if (totalCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5EF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.tr.itemsCountLabel(totalCount),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _forestGreen,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          const Center(child: AppLanguagePill()),
          const SizedBox(width: 4),
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFEF4444),
                size: 22,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(context.tr.clearShoppingCartTitle),
                    content: Text(
                      context.tr.clearShoppingCartBody,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(context.tr.cancel),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                        onPressed: () {
                          _state.clearCart();
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          context.tr.clearAll,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: items.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Produce items list
                  ...items.map((item) => _buildCartItemCard(item)),

                  const SizedBox(height: 14),

                  // Promo Code Voucher Card
                  _buildPromoCard(),

                  const SizedBox(height: 14),

                  // Order Summary Card
                  _buildOrderSummaryCard(),
                ],
              ),
            ),

      // ── Sticky Bottom Bar matching Checkout UI ─────────────────────────────
      bottomSheet: items.isEmpty
          ? null
          : Container(
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr.orderTotal,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          'Rs. ${_state.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutDeliveryScreen(),
                            ),
                          );
                        },
                        child: Text(
                          context.tr.proceedToCheckout,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
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

  // ───────────────────────────────────────────────────────────────────────────
  // Cart Item Card
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildCartItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Emoji/Image thumbnail
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                item.emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.localizedName(context.currentLanguage),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.farmName,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _forestGreen,
                      ),
                    ),

                    // Stepper: [-]  qty  [+]
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          _buildStepperBtn(
                            icon: Icons.remove_rounded,
                            onTap: () => _state.updateQuantity(item.id, -1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                              ),
                            ),
                          ),
                          _buildStepperBtn(
                            icon: Icons.add_rounded,
                            onTap: () => _state.updateQuantity(item.id, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: _textDark),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Promo Card
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildPromoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr.promoCodeVouchers,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _labelGrey,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFBFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined,
                          color: _forestGreen, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                          decoration: InputDecoration(
                            hintText: context.tr.enterPromoCode,
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF94A3B8),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _forestGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  onPressed: _applyPromo,
                  child: Text(
                    context.tr.apply,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isPromoApplied && _state.promoDiscount > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: _forestGreen, size: 15),
                const SizedBox(width: 6),
                Text(
                  'Code ${_state.promoCode} applied! Saved Rs. ${_state.promoDiscount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _forestGreen,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Order Summary Card
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr.orderSummary,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _labelGrey,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          _buildSummaryRow(
            label: context.tr.itemsSubtotal,
            value: 'Rs. ${_state.subtotal.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            label: context.tr.discountWithCode(_state.promoCode),
            value: '-Rs. ${_state.promoDiscount.toStringAsFixed(0)}',
            valueColor: const Color(0xFF16A34A),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            label: context.tr.deliveryFee,
            value: _state.deliveryFee == 0
                ? context.tr.freeDelivery
                : 'Rs. ${_state.deliveryFee.toStringAsFixed(0)}',
            valueColor: _state.deliveryFee == 0 ? const Color(0xFF16A34A) : _textDark,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _buildSummaryRow(
            label: context.tr.totalPayment,
            value: 'Rs. ${_state.totalAmount.toStringAsFixed(0)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? _textDark : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? (isBold ? _textDark : _textDark),
          ),
        ),
      ],
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
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF5EF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_basket_outlined,
                size: 46,
                color: _forestGreen,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr.yourCartIsEmpty,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr.cartEmptyDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _forestGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: () => Navigator.maybePop(context),
              child: Text(
                context.tr.exploreProduce,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

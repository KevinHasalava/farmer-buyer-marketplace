import 'package:flutter/material.dart';

import '../../../core/localization/app_settings.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../../cart/models/cart_item_model.dart';
import '../../cart/presentation/checkout_delivery_screen.dart';
import '../../cart/services/cart_state.dart';

/// 16. Cart Screen — matching Screenshot 16
class BuyerCartScreen extends StatefulWidget {
  const BuyerCartScreen({super.key});

  @override
  State<BuyerCartScreen> createState() => _BuyerCartScreenState();
}

class _BuyerCartScreenState extends State<BuyerCartScreen> {
  final MarketplaceState _cartState = MarketplaceState.instance;

  static const Color _forestGreen = Color(0xFF1B5E38);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _cartState.addListener(_onCartChanged);
    _ensureDefaultCartItems();
  }

  void _ensureDefaultCartItems() {
    // If cart is empty, prepopulate with the 3 items matching Screenshot 16
    if (_cartState.cartItems.isEmpty) {
      _cartState.addToCart(
        CartItem(
          id: 'cart_1',
          name: 'Nuwara Eliya Mountain Carrots',
          price: 380.0,
          unit: '/kg',
          quantity: 2,
          emoji: '🥕',
          farmName: 'Partner Bandara',
          imageUrl: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=300&auto=format&fit=crop&q=80',
        ),
      );
      _cartState.addToCart(
        CartItem(
          id: 'cart_2',
          name: 'Dambulla Red Tomatoes',
          price: 260.0,
          unit: '/kg',
          quantity: 1,
          emoji: '🍅',
          farmName: 'Sunil Perera',
          imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=300&auto=format&fit=crop&q=80',
        ),
      );
      _cartState.addToCart(
        CartItem(
          id: 'cart_3',
          name: 'Organic Gotukola Bundle',
          price: 80.0,
          unit: '/bundle',
          quantity: 3,
          emoji: '🌿',
          farmName: 'Kandy Greens',
          imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=300&auto=format&fit=crop&q=80',
        ),
      );
    }
  }

  @override
  void dispose() {
    _cartState.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartState.cartItems;
    final totalCount = _cartState.totalItemCount;
    final subtotal = _cartState.subtotal;
    const deliveryFee = 250.0;
    final total = subtotal > 0 ? (subtotal + deliveryFee) : 0.0;

    return Scaffold(
      backgroundColor: _bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${context.tr.myCart} ($totalCount)',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          const AppLanguagePill(),
          const SizedBox(width: 4),
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Cart?'),
                    content: const Text('Are you sure you want to remove all items from your cart?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          _cartState.clearCart();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear', style: TextStyle(color: Color(0xFFEF4444))),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'Clear Cart',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 64, color: _textMuted),
                  const SizedBox(height: 12),
                  const Text('Your cart is empty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _forestGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Shop Fresh Produce', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Direct Route Banner matching Screenshot 16
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFDCFCE7)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: _forestGreen, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '100% Direct Route',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _forestGreen),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Direct from Hakgala, Ohiya & Dambulla. Consolidated into 1 eco-friendly delivery.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF166534)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cart Items List matching Screenshot 16
                      ...items.map((item) => _buildCartItemCard(item)),

                      const SizedBox(height: 12),

                      // ZERO WAREHOUSING tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.flash_on_rounded, size: 14, color: _forestGreen),
                            SizedBox(width: 6),
                            Text(
                              'ZERO WAREHOUSING: Direct transit directly to you',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _forestGreen),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Order Summary Card matching Screenshot 16
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Order Summary',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Guaranteed Fresh',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryRow('Items Subtotal (${items.length} Items)', 'Rs. ${subtotal.toStringAsFixed(0)}'),
                            const SizedBox(height: 8),
                            _buildSummaryRow('Farm Direct Delivery Fee', 'Rs. ${deliveryFee.toStringAsFixed(0)}'),
                            const SizedBox(height: 8),
                            _buildSummaryRow('Fresh Produce Packaging', 'Free', isGreen: true),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(color: Color(0xFFE2E8F0)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Total Amount',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _textDark),
                                    ),
                                    Text(
                                      'incl. all agricultural levies',
                                      style: TextStyle(fontSize: 9, color: _textMuted),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Rs. ${total.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _forestGreen),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Impact Pill matching Screenshot 16
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Row(
                              children: [
                                Icon(Icons.eco_rounded, size: 14, color: _forestGreen),
                                SizedBox(width: 6),
                                Text(
                                  '3.2 kg CO₂ saved vs traditional wholesale',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textDark),
                                ),
                              ],
                            ),
                            Text(
                              'Impacted',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _forestGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Checkout Bar matching Screenshot 16
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.bolt_rounded, size: 12, color: Color(0xFFEA580C)),
                                  SizedBox(width: 2),
                                  Text(
                                    'Tomorrow 7-9 AM',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Total: Rs. ${total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _forestGreen,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _forestGreen,
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CheckoutDeliveryScreen(),
                                ),
                              );
                            },
                            child: Row(
                              children: const [
                                Text(
                                  'Proceed to Checkout',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Produce Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl ??
                  'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=200&auto=format&fit=crop&q=80',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          // Details & Stepper
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  '👨‍🌾 ${item.farmName}',
                  style: const TextStyle(fontSize: 10, color: _textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rs. ${item.price.toStringAsFixed(0)} ${item.unit}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textMuted),
                ),
              ],
            ),
          ),

          // Stepper [-] Qty [+] and Line Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _cartState.updateQuantity(item.id, -1),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Icon(Icons.remove, size: 14, color: _textDark),
                      ),
                    ),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                    GestureDetector(
                      onTap: () => _cartState.updateQuantity(item.id, 1),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Icon(Icons.add, size: 14, color: _textDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _forestGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: _textMuted),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isGreen ? _forestGreen : _textDark,
          ),
        ),
      ],
    );
  }
}

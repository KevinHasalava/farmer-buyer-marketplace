import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../cart/models/cart_item_model.dart';
import '../../cart/services/cart_state.dart';
import '../../orders_chat/presentation/orders_chat_screen.dart';
import '../data/buyer_mock_data.dart';
import '../models/buyer_models.dart';
import 'buyer_cart_screen.dart';
import 'buyer_farmer_profile_screen.dart';

/// 14. Product Details Screen — matching Screenshot 14
class BuyerProductDetailScreen extends StatefulWidget {
  const BuyerProductDetailScreen({
    super.key,
    required this.product,
  });

  final BuyerProduct product;

  @override
  State<BuyerProductDetailScreen> createState() => _BuyerProductDetailScreenState();
}

class _BuyerProductDetailScreenState extends State<BuyerProductDetailScreen> {
  final MarketplaceState _cartState = MarketplaceState.instance;
  int _quantity = 2;
  bool _isFavorite = false;

  static const Color _forestGreen = Color(0xFF1B5E38);
  static const Color _bgSoft = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _cartState.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartState.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _addToCart() {
    HapticFeedback.lightImpact();
    _cartState.addToCart(
      CartItem(
        id: widget.product.id,
        name: widget.product.name,
        price: widget.product.price,
        unit: '/${widget.product.unit}',
        quantity: _quantity,
        emoji: '🥕',
        farmName: widget.product.farmerName,
        imageUrl: widget.product.imageUrl,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_quantity ${widget.product.unit} of ${widget.product.name} to cart!'),
        backgroundColor: _forestGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prod = widget.product;
    final subtotal = prod.price * _quantity;
    final cartCount = _cartState.totalItemCount;

    return Scaffold(
      backgroundColor: _bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFavorite ? const Color(0xFFEF4444) : _textDark,
              size: 20,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20, color: _textDark),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BuyerCartScreen()),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: _forestGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, size: 18, color: Colors.white),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEA580C),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$cartCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
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
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 170),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Image with Overlaid Badges
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(prod.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Badges top left
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B5E38),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Direct Farm Harvest',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16A34A),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '100% Organic',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA580C),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Harvested Yesterday',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bottom gradient overlay with text
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                            gradient: LinearGradient(
                              colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: const Text(
                            'Tested pesticide-free • LKR/Farm Direct',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Title & Price Section
                Text(
                  prod.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      '${prod.rating} • ${prod.reviewsCount} verified buyer reviews',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${prod.formattedPrice} / ${prod.unit}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _forestGreen,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${prod.availableStock} available in stock',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _forestGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // HARVEST TRANSPARENCY Card matching Screenshot 14
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.shield_outlined, size: 16, color: _forestGreen),
                              SizedBox(width: 6),
                              Text(
                                'HARVEST TRANSPARENCY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: _forestGreen,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Verified Origin',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Farmer profile row (clickable)
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BuyerFarmerProfileScreen(
                              farmer: BuyerMockData.primaryFarmer,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(prod.farmerAvatarUrl),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prod.farmerName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: _textDark,
                                    ),
                                  ),
                                  Text(
                                    prod.farmName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: _forestGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '12 hours ago (${prod.farmLocation} Central Province)',
                                    style: const TextStyle(fontSize: 10, color: _textMuted),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _textMuted),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2 info boxes side-by-side
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.schedule_rounded, size: 12, color: _textMuted),
                                      SizedBox(width: 4),
                                      Text('HARVESTED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _textMuted)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    prod.harvestTime,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _textDark),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.local_shipping_outlined, size: 12, color: _textMuted),
                                      SizedBox(width: 4),
                                      Text('DISPATCH VIA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _textMuted)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    prod.dispatchVia,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _textDark),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Batch log inspect link
                      Row(
                        children: const [
                          Text(
                            'Inspect Farm Soil Certifications & Batch Log',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _forestGreen,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded, size: 16, color: _forestGreen),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Harvest Notes
                const Text(
                  'Harvest Notes',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
                ),
                const SizedBox(height: 6),
                Text(
                  prod.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),

                // Feature Highlights Icons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeatureChip(icon: Icons.water_drop_outlined, label: 'Spring Washed'),
                    _buildFeatureChip(icon: Icons.eco_outlined, label: 'Zero Chemical'),
                    _buildFeatureChip(icon: Icons.all_inbox_rounded, label: 'Aerated Box'),
                  ],
                ),
              ],
            ),
          ),

          // Sticky Bottom Actions matching Screenshot 14
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Weight selector & Subtotal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Weight:',
                              style: TextStyle(fontSize: 10, color: _textMuted),
                            ),
                            Text(
                              'Subtotal: Rs. ${subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                              ),
                            ),
                          ],
                        ),
                        // Stepper [-] Qty [+]
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 16),
                                onPressed: () {
                                  if (_quantity > 1) {
                                    setState(() => _quantity--);
                                  }
                                },
                              ),
                              Text(
                                '$_quantity kg',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 16),
                                onPressed: () {
                                  setState(() => _quantity++);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Two Buttons Row
                    Row(
                      children: [
                        // Chat with Farmer
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: _forestGreen),
                            label: const Text(
                              'Chat with Farmer',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _forestGreen),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _forestGreen, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const OrdersChatScreen(initialTab: 1),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Add to Cart
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.white),
                            label: Text(
                              'Add to Cart • Rs. ${subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _forestGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _addToCart,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Express guaranteed morning delivery to Greater Colombo.',
                      style: TextStyle(fontSize: 10, color: _textMuted),
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

  Widget _buildFeatureChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: _forestGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textDark),
          ),
        ],
      ),
    );
  }
}

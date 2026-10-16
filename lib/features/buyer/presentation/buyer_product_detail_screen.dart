import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/localization/app_settings.dart';
import '../../cart/models/cart_item_model.dart';
import '../../cart/services/cart_state.dart';
import '../../orders_chat/presentation/chat_detail_screen.dart';
import '../../../services/chat_service.dart';
import '../models/buyer_models.dart';
import '../services/buyer_review_service.dart';
import 'buyer_cart_screen.dart';
import 'buyer_farmer_profile_screen.dart';
import 'buyer_reviews_screen.dart';

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

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr.addedQtyProduceNotice(
            _quantity,
            widget.product.localizedUnit(context.currentLanguage),
            widget.product.localizedName(context.currentLanguage),
          ),
        ),
        backgroundColor: _forestGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: context.tr.viewCartBtn,
          textColor: const Color(0xFFFDE68A),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BuyerCartScreen()),
            );
          },
        ),
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
        title: Text(
          context.tr.productDetails,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark),
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
                              child: Text(
                                context.tr.directFarmHarvest,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: prod.isOrganic ? const Color(0xFF16A34A) : const Color(0xFF0284C7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                prod.isOrganic ? context.tr.organicPercent : context.tr.farmDirectProduce,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA580C),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                context.tr.localizedHarvestTime(prod.harvestTime),
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
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
                          child: Text(
                            context.tr.testedPesticideFree,
                            style: const TextStyle(
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
                  prod.localizedName(context.currentLanguage),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                ListenableBuilder(
                  listenable: BuyerReviewService.instance,
                  builder: (ctx, _) {
                    final dynRating = BuyerReviewService.instance
                        .getAverageRatingForProduct(prod.id, prod.rating);
                    final dynCount = BuyerReviewService.instance
                        .getReviewCountForProduct(prod.id, prod.reviewsCount);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BuyerReviewsScreen(
                              initialProductId: prod.id,
                              initialProductName: prod.name,
                              initialFarmerName: prod.farmerName,
                              initialProductImage: prod.imageUrl,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 4),
                          Text(
                            '$dynRating • $dynCount Verified Reviews',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: _textMuted),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${prod.formattedPrice} / ${prod.localizedUnit(context.currentLanguage)}',
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
                        context.tr.inStockCount(prod.availableStock),
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
                            children: [
                              const Icon(Icons.shield_outlined, size: 16, color: _forestGreen),
                              const SizedBox(width: 6),
                              Text(
                                context.tr.harvestTransparency,
                                style: const TextStyle(
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
                            child: Text(
                              context.tr.verifiedOrigin,
                              style: const TextStyle(
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
                            builder: (_) => BuyerFarmerProfileScreen(
                              farmer: BuyerFarmer(
                                name: prod.farmerName,
                                farmName: prod.farmName,
                                location: prod.farmLocation,
                                altitude: '1,200m alt',
                                rating: prod.rating,
                                reviewsCount: prod.reviewsCount,
                                yearsExperience: '16 yrs',
                                bio: prod.farmerBio,
                                ordersFulfilled: '850+',
                                onTimeRate: '98.5%',
                                directTrace: '100%',
                                avatarUrl: prod.farmerAvatarUrl,
                                landscapeUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1000&auto=format&fit=crop&q=80',
                                phone: '076 323 8225',
                                isCertifiedOrganic: prod.isOrganic,
                              ),
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
                            IconButton(
                              tooltip: 'Chat with Farmer',
                              icon: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDCFCE7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 15,
                                  color: _forestGreen,
                                ),
                              ),
                              onPressed: () {
                                final conv = ChatService.instance.getOrCreateConversation(
                                  peerId: 'conv_farmer_${prod.farmerName.toLowerCase().replaceAll(' ', '_')}',
                                  peerName: prod.farmerName,
                                  peerRole: 'Farmer',
                                  avatarUrl: prod.farmerAvatarUrl,
                                  subtitle: '${prod.farmName} • ${prod.farmLocation}',
                                  productContext: '${prod.name} (${prod.formattedPrice}/${prod.unit})',
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatDetailScreen(
                                      conversation: conv,
                                      currentRole: 'buyer',
                                    ),
                                  ),
                                );
                              },
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
                                    children: [
                                      const Icon(Icons.schedule_rounded, size: 12, color: _textMuted),
                                      const SizedBox(width: 4),
                                      Text(context.tr.harvestedLabel, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _textMuted)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.tr.localizedHarvestTime(prod.harvestTime),
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
                                    children: [
                                      const Icon(Icons.local_shipping_outlined, size: 12, color: _textMuted),
                                      const SizedBox(width: 4),
                                      Text(context.tr.dispatchViaLabel, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _textMuted)),
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
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Harvest Notes
                Text(
                  context.tr.harvestNotes,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _textDark),
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
                    _buildFeatureChip(icon: Icons.water_drop_outlined, label: context.tr.springWashed),
                    _buildFeatureChip(icon: Icons.eco_outlined, label: context.tr.zeroChemical),
                    _buildFeatureChip(icon: Icons.all_inbox_rounded, label: context.tr.aeratedBox),
                  ],
                ),
                const SizedBox(height: 22),

                // 🌟 Customer Reviews & Farmer Ratings Section (CRUD Integrated)
                _buildProductReviewsSection(prod),
                const SizedBox(height: 100),
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
                            Text(
                              context.tr.selectedWeight,
                              style: const TextStyle(fontSize: 10, color: _textMuted),
                            ),
                            Text(
                              '${context.tr.subtotal}: ${context.tr.priceRs} ${subtotal.toStringAsFixed(0)}',
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
                                '$_quantity ${prod.localizedUnit(context.currentLanguage)}',
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
                            label: Text(
                              context.tr.chatWithFarmer,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _forestGreen),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _forestGreen, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              final conv = ChatService.instance.getOrCreateConversation(
                                peerId: 'conv_farmer_${prod.farmerName.toLowerCase().replaceAll(' ', '_')}',
                                peerName: prod.farmerName,
                                peerRole: 'Farmer',
                                avatarUrl: prod.farmerAvatarUrl,
                                subtitle: '${prod.farmName} • ${prod.farmLocation}',
                                productContext: '${prod.name} (${prod.formattedPrice}/${prod.unit})',
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(
                                    conversation: conv,
                                    currentRole: 'buyer',
                                  ),
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
                              '${context.tr.addToCart} • ${context.tr.priceRs} ${subtotal.toStringAsFixed(0)}',
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
                    Text(
                      context.tr.expressMorningDelivery,
                      style: const TextStyle(fontSize: 10, color: _textMuted),
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

  // ═══════════════════════════════════════════════════════════════════════════
  // ⭐ CUSTOMER REVIEWS & FARMER RATINGS SECTION (MEMBER 1 CRUD INTEGRATED)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildProductReviewsSection(BuyerProduct prod) {
    return ListenableBuilder(
      listenable: BuyerReviewService.instance,
      builder: (ctx, _) {
        final service = BuyerReviewService.instance;
        final reviews = service.reviewsForProduct(prod.id);
        final dynRating = service.getAverageRatingForProduct(prod.id, prod.rating);
        final dynCount = service.getReviewCountForProduct(prod.id, prod.reviewsCount);

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row: Title + "Write Review" Button ─────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Reviews',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _textDark,
                            ),
                          ),
                          Text(
                            'Verified buyers & harvest ratings',
                            style: TextStyle(fontSize: 11, color: _textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BuyerReviewsScreen(
                            initialProductId: prod.id,
                            initialProductName: prod.name,
                            initialFarmerName: prod.farmerName,
                            initialProductImage: prod.imageUrl,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.rate_review_rounded, size: 14),
                    label: const Text('Add Review', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _forestGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Rating Score Banner ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          dynRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: _textDark,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (_) {
                            return const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14);
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    const SizedBox(height: 40, child: VerticalDivider(color: Color(0xFFCBD5E1), thickness: 1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$dynCount Verified Reviews',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _textDark),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '96% of buyers recommend this crop from ${''}',
                            style: TextStyle(fontSize: 10.5, color: _textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Reviews List ──────────────────────────────────────────────
              if (reviews.isEmpty) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        const Text(
                          'No reviews for this product yet.',
                          style: TextStyle(fontSize: 12, color: _textMuted),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BuyerReviewsScreen(
                                  initialProductId: prod.id,
                                  initialProductName: prod.name,
                                  initialFarmerName: prod.farmerName,
                                  initialProductImage: prod.imageUrl,
                                ),
                              ),
                            );
                          },
                          child: const Text('Be the first to review!', style: TextStyle(color: _forestGreen, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Show up to 3 most recent reviews
                ...reviews.take(3).map((r) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
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
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(5, (idx) {
                                    final filled = idx < r.rating.floor();
                                    return Icon(
                                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                                      color: filled ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                                      size: 14,
                                    );
                                  }),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    r.qualityTag,
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                                  ),
                                ),
                              ],
                            ),
                            Text(r.timeAgo, style: const TextStyle(fontSize: 10, color: _textMuted)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          r.title,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: _textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          r.comment,
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.35),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 12, color: _textMuted),
                            const SizedBox(width: 4),
                            Text(r.buyerName, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: _textMuted)),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified_rounded, size: 11, color: Color(0xFF059669)),
                          ],
                        ),
                        if (r.hasFarmerReply) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.reply_rounded, size: 12, color: Color(0xFF059669)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Farmer response: "${r.farmerReply}"',
                                    style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: Color(0xFF065F46)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BuyerReviewsScreen(
                            initialProductId: prod.id,
                            initialProductName: prod.name,
                            initialFarmerName: prod.farmerName,
                            initialProductImage: prod.imageUrl,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'View All Reviews ($dynCount) >',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _forestGreen),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/localization/app_settings.dart';
import 'package:flutter/services.dart';

import '../../cart/models/cart_item_model.dart';
import '../../cart/services/cart_state.dart';
import '../../orders_chat/presentation/orders_chat_screen.dart';
import '../data/buyer_mock_data.dart';
import '../models/buyer_models.dart';
import '../../farmer/services/farmer_profile_manager.dart';
import 'buyer_cart_screen.dart';
import 'buyer_product_detail_screen.dart';

/// 15. Farmer Profile Screen — matching Screenshot 15
class BuyerFarmerProfileScreen extends StatefulWidget {
  const BuyerFarmerProfileScreen({
    super.key,
    required this.farmer,
  });

  final BuyerFarmer farmer;

  @override
  State<BuyerFarmerProfileScreen> createState() => _BuyerFarmerProfileScreenState();
}

class _BuyerFarmerProfileScreenState extends State<BuyerFarmerProfileScreen> {
  final MarketplaceState _cartState = MarketplaceState.instance;

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

  void _addToCart(BuyerProduct prod) {
    HapticFeedback.lightImpact();
    final lang = context.currentLanguage;
    final localizedTitle = prod.localizedName(lang);
    final unit = prod.localizedUnit(lang);
    _cartState.addToCart(
      CartItem(
        id: prod.id,
        name: localizedTitle,
        price: prod.price,
        unit: '/$unit',
        quantity: 1,
        emoji: '👨‍🌾',
        farmName: prod.farmerName,
        imageUrl: prod.imageUrl,
      ),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr.addedToCartNotice(localizedTitle, prod.formattedPrice)),
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
    final realFarmer = FarmerProfileManager.instance.profile.toBuyerFarmer();
    final farmer = (FarmerProfileManager.instance.profile.name.isNotEmpty &&
            (widget.farmer.name == BuyerFarmer.defaultFarmer.name ||
                widget.farmer.name == BuyerMockData.primaryFarmer.name ||
                widget.farmer.name == realFarmer.name))
        ? realFarmer
        : widget.farmer;
    final products = BuyerMockData.getFarmerProducts(farmer.name);
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
          context.tr.farmerProfile,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textDark),
        ),
        centerTitle: true,
        actions: [
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Status Tag matching Screenshot 15
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fiber_manual_record, size: 8, color: Color(0xFF16A34A)),
                  const SizedBox(width: 6),
                  Text(
                    context.tr.directFieldLink,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _forestGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Farmer Profile Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(farmer.avatarUrl),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                context.tr.certifiedOrganicOnly,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF166534),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              farmer.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                              ),
                            ),
                            Text(
                              farmer.farmName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _forestGreen,
                              ),
                            ),
                            Text(
                              '${farmer.location} (${farmer.altitude})',
                              style: const TextStyle(fontSize: 10, color: _textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2 Stats Columns
                  Row(
                    children: [
                      _buildFarmerStatItem(
                        icon: Icons.star_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        value: '${farmer.rating} (${farmer.reviewsCount}+)',
                        label: context.tr.topRatedProducer,
                      ),
                      const SizedBox(width: 16),
                      _buildFarmerStatItem(
                        icon: Icons.history_edu_rounded,
                        iconColor: _forestGreen,
                        value: farmer.yearsExperience,
                        label: context.tr.heritageFarming,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Farmer Bio quote
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '"${farmer.bio}"',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF475569),
                        fontStyle: FontStyle.italic,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Actions Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Colors.white),
                          label: Text(
                            context.tr.chatWithFarmer,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _forestGreen,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.call_outlined, size: 16, color: _forestGreen),
                          label: Text(
                            context.tr.callFarmDirectly,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _forestGreen),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _forestGreen, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Calling ${farmer.name}: ${farmer.phone}'),
                                backgroundColor: _forestGreen,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Performance Metrics Row (3 cards) matching Screenshot 15
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(farmer.ordersFulfilled, context.tr.ordersFulfilledLabel),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(farmer.onTimeRate, context.tr.onTimeOutLabel),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(farmer.directTrace, context.tr.directTraceLabel),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Farm Landscape Terroir Banner
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(farmer.landscapeUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                alignment: Alignment.bottomLeft,
                child: Text(
                  context.tr.hakgalaTerroir,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Active Harvest Listings Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr.activeHarvestListings,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    Text(
                      context.tr.harvestedFreshUponOrder,
                      style: const TextStyle(fontSize: 11, color: _textMuted),
                    ),
                  ],
                ),
                Text(
                  context.tr.itemsAvailableCount(products.length),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _forestGreen),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2x2 Grid of Active Harvest Listings matching Screenshot 15
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BuyerProductDetailScreen(product: p),
                    ),
                  ),
                  child: Container(
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
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.network(
                            p.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.localizedName(context.currentLanguage),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${context.tr.per} ${p.localizedUnit(context.currentLanguage)}',
                                style: const TextStyle(fontSize: 10, color: _textMuted),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    p.formattedPrice,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: _forestGreen,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _addToCart(p),
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: const BoxDecoration(
                                        color: _forestGreen,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _textDark)),
            Text(label, style: const TextStyle(fontSize: 9, color: _textMuted)),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String val, String lbl) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _forestGreen),
          ),
          const SizedBox(height: 2),
          Text(
            lbl,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: _textMuted, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

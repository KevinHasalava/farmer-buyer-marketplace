import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/auction_model.dart';
import '../../services/auction_manager.dart';
import '../../../buyer/services/buyer_profile_manager.dart';
import '../../../../core/localization/app_settings.dart';
import '../../../../core/theme/app_theme.dart';

class BuyerAuctionDetailScreen extends StatefulWidget {
  final String auctionId;

  const BuyerAuctionDetailScreen({super.key, required this.auctionId});

  @override
  State<BuyerAuctionDetailScreen> createState() => _BuyerAuctionDetailScreenState();
}

class _BuyerAuctionDetailScreenState extends State<BuyerAuctionDetailScreen> {
  Timer? _countdownTimer;
  late TextEditingController _customBidCtrl;
  double? _selectedBidAmount;
  bool _isSubmittingBid = false;

  static const Color _primaryGreen = Color(0xFF1E5E3A);
  static const Color _emerald = Color(0xFF10B981);
  static const Color _gold = Color(0xFFEAB308);
  static const Color _orangeAccent = Color(0xFFEA580C);

  @override
  void initState() {
    super.initState();
    _customBidCtrl = TextEditingController();

    // Periodic timer to keep countdown ticking down
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    final auction = AuctionManager.instance.getAuctionById(widget.auctionId);
    if (auction != null) {
      _selectedBidAmount = auction.minNextBid;
      _customBidCtrl.text = _selectedBidAmount!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _customBidCtrl.dispose();
    super.dispose();
  }

  void _incrementBidBy(double add) {
    final auction = AuctionManager.instance.getAuctionById(widget.auctionId);
    if (auction == null) return;

    HapticFeedback.lightImpact();
    final currentBase = _selectedBidAmount ?? auction.minNextBid;
    final newBid = currentBase + add;
    setState(() {
      _selectedBidAmount = newBid;
      _customBidCtrl.text = newBid.toStringAsFixed(0);
    });
  }

  Future<void> _submitBid(AuctionModel auction) async {
    final buyer = BuyerProfileManager.instance.profile;
    final buyerId = buyer.id.isNotEmpty ? buyer.id : 'buyer_curr';
    final buyerName = buyer.name.trim().isNotEmpty ? buyer.name.trim() : 'Verified Buyer';

    final enteredAmount = double.tryParse(_customBidCtrl.text.trim()) ?? (_selectedBidAmount ?? 0.0);

    if (enteredAmount < auction.minNextBid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimum bid required is Rs. ${auction.minNextBid.toStringAsFixed(2)}'),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmittingBid = true);
    HapticFeedback.heavyImpact();

    final result = await AuctionManager.instance.placeBid(
      auctionId: auction.id,
      buyerId: buyerId,
      buyerName: buyerName,
      amount: enteredAmount,
    );

    setState(() => _isSubmittingBid = false);

    if (!mounted) return;

    if (result.success) {
      _showBidSuccessDialog(enteredAmount, auction);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showBidSuccessDialog(double amount, AuctionModel auction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.emoji_events_rounded, color: _gold, size: 40),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Bid Placed Successfully!'.trAuto(context),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 8),
            Text(
              'You are now the HIGHEST BIDDER with Rs. ${amount.toStringAsFixed(2)} per ${auction.unit} for ${auction.cropName}.'.trAuto(context),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Lot Estimate:'.trAuto(context), style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  Text(
                    'Rs. ${(amount * auction.quantity).toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _primaryGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text('Awesome!'.trAuto(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBuyNow(AuctionModel auction) async {
    final buyer = BuyerProfileManager.instance.profile;
    final buyerId = buyer.id.isNotEmpty ? buyer.id : 'buyer_curr';
    final buyerName = buyer.name.trim().isNotEmpty ? buyer.name.trim() : 'Verified Buyer';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.flash_on_rounded, color: Color(0xFFEA580C), size: 24),
            const SizedBox(width: 8),
            Text('Instant Buyout (Buy-Now)?'.trAuto(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Purchase this entire lot of ${auction.quantity.toStringAsFixed(0)} ${auction.unit} for the set Buy-Now price of Rs. ${auction.buyNowPrice!.toStringAsFixed(2)} / ${auction.unit} (Total: Rs. ${(auction.buyNowPrice! * auction.quantity).toStringAsFixed(0)})?\n\nThis will immediately finalize the auction and grant you the winning lot.'.trAuto(context),
          style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'.trAuto(context), style: const TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Confirm Purchase'.trAuto(context)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final res = await AuctionManager.instance.buyNow(
        auctionId: auction.id,
        buyerId: buyerId,
        buyerName: buyerName,
      );

      if (res.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.message),
            backgroundColor: _primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuctionManager.instance,
      builder: (context, _) {
        final auction = AuctionManager.instance.getAuctionById(widget.auctionId);
        if (auction == null) {
          return Scaffold(
            appBar: AppBar(title: Text(context.tr.auctionsLabel)),
            body: Center(child: Text(context.tr.auctionNotFound)),
          );
        }

        final buyer = BuyerProfileManager.instance.profile;
        final isHighestBidder = auction.highestBidderId == buyer.id ||
            (buyer.name.trim().isNotEmpty && auction.highestBidderName == buyer.name.trim());
        final isActive = auction.isActive;
        final hasBuyNow = auction.buyNowPrice != null && auction.buyNowPrice! > 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // App Bar with Photo & Badges
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    backgroundColor: _primaryGreen,
                    leading: IconButton(
                      icon: const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 16,
                        child: Icon(Icons.arrow_back_rounded, color: Color(0xFF111827), size: 18),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            auction.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: _primaryGreen),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.65),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.85),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isActive ? _emerald : const Color(0xFF6B7280),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isActive ? Icons.bolt_rounded : Icons.timer_off_rounded,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            (isActive ? 'LIVE AUCTION' : 'CLOSED').trAuto(context),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF7ED),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFFFEDD5)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.timer_outlined, size: 13, color: _orangeAccent),
                                          const SizedBox(width: 4),
                                          Text(
                                            auction.remainingTimeString.trAuto(context),
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                              color: _orangeAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  auction.cropName.trAuto(context),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF86EFAC)),
                                    const SizedBox(width: 3),
                                    Text(
                                      auction.location.trAuto(context),
                                      style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                    const Text(' • ', style: TextStyle(color: Colors.white38)),
                                    Text(
                                      '${auction.quantity.toStringAsFixed(0)} ${auction.unit} Lot'.trAuto(context),
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Main Bidding Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🏆 Top Bid Highlight Card
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0F3822), Color(0xFF1E5E3A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryGreen.withValues(alpha: 0.3),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (auction.totalBids > 0 ? 'CURRENT HIGHEST BID' : 'STARTING BID').trAuto(context),
                                          style: const TextStyle(
                                            color: Color(0xFF86EFAC),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Rs. ${auction.effectivePrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Text(
                                          'per ${auction.unit} (Total: Rs. ${auction.totalLotValue.toStringAsFixed(0)})'.trAuto(context),
                                          style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(Icons.emoji_events_rounded, color: _gold, size: 34),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(color: Color(0x33FFFFFF), height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isHighestBidder ? Icons.check_circle_rounded : Icons.person_pin_rounded,
                                          size: 15,
                                          color: isHighestBidder ? _emerald : Colors.white70,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isHighestBidder
                                              ? 'You are the leading bidder! 🎉'.trAuto(context)
                                              : '${'Leader'.trAuto(context)}: ${auction.highestBidderName ?? "Be the first bidder!".trAuto(context)}',
                                          style: TextStyle(
                                            color: isHighestBidder ? const Color(0xFF86EFAC) : Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${auction.totalBids} ${'bids placed'.trAuto(context)}',
                                      style: const TextStyle(color: Color(0xFFFEF08A), fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Farmer Card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: Image.network(
                                    auction.farmerAvatar.isNotEmpty
                                        ? auction.farmerAvatar
                                        : 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=200&auto=format&fit=crop&q=80',
                                    width: 46,
                                    height: 46,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 46,
                                      height: 46,
                                      color: const Color(0xFFDCFCE7),
                                      child: const Icon(Icons.person, color: _primaryGreen),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            auction.farmerName,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified_rounded, size: 14, color: _primaryGreen),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Verified Producer • ${auction.farmerLocation}',
                                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Crop Specifications Card
                          Text(
                            'Harvest & Batch Specifications'.trAuto(context),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE5E7EB)),
                            ),
                            child: Column(
                              children: [
                                _buildSpecItem('Category', auction.category),
                                const Divider(height: 16),
                                _buildSpecItem('Lot Quantity', '${auction.quantity.toStringAsFixed(0)} ${auction.unit}'),
                                const Divider(height: 16),
                                _buildSpecItem('Min. Bid Increment', 'Rs. ${auction.minBidIncrement.toStringAsFixed(2)}'),
                                const Divider(height: 16),
                                _buildSpecItem('Delivery Logistics', auction.deliveryTerms),
                                if (auction.harvestDate != null) ...[
                                  const Divider(height: 16),
                                  _buildSpecItem(
                                    'Harvest Date',
                                    '${auction.harvestDate!.day}/${auction.harvestDate!.month}/${auction.harvestDate!.year}',
                                  ),
                                ],
                                if (auction.description.isNotEmpty) ...[
                                  const Divider(height: 16),
                                  _buildSpecItem('Quality Notes', auction.description),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Bidding Activity Feed
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Live Bid Activity'.trAuto(context),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                              ),
                              Text(
                                '${auction.bids.length} ${'total bids'.trAuto(context)}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (auction.bids.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Center(
                                child: Text(
                                  'No bids placed yet. Be the first to place a bid!'.trAuto(context),
                                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: auction.bids.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, idx) {
                                final b = auction.bids[idx];
                                final isLeader = idx == 0;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isLeader ? const Color(0xFFF0FDF4) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isLeader ? const Color(0xFF86EFAC) : const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isLeader ? Icons.emoji_events_rounded : Icons.check_circle_outline_rounded,
                                        size: 18,
                                        color: isLeader ? _gold : const Color(0xFF9CA3AF),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              b.bidderName,
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: isLeader ? FontWeight.w800 : FontWeight.w600,
                                                color: const Color(0xFF111827),
                                              ),
                                            ),
                                            Text(
                                              '${b.createdAt.hour.toString().padLeft(2, '0')}:${b.createdAt.minute.toString().padLeft(2, '0')}',
                                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF9CA3AF)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Rs. ${b.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: isLeader ? const Color(0xFF15803D) : const Color(0xFF111827),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Sticky Floating Bidding Control Bar at Bottom
              if (isActive)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 18,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Quick increment chips: +Rs. 5, +Rs. 10, +Rs. 25, +Rs. 50
                          Row(
                            children: [
                              Text(
                                'Quick Bid:'.trAuto(context),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
                              ),
                              const SizedBox(width: 8),
                              ...[
                                auction.minBidIncrement,
                                auction.minBidIncrement * 2,
                                auction.minBidIncrement * 5,
                              ].map((inc) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ActionChip(
                                    label: Text('+Rs. ${inc.toStringAsFixed(0)}'),
                                    labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _primaryGreen),
                                    backgroundColor: const Color(0xFFECFDF5),
                                    side: const BorderSide(color: Color(0xFFA7F3D0)),
                                    onPressed: () => _incrementBidBy(inc),
                                  ),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Bid input and Place Bid button
                          Row(
                            children: [
                              // Bid Amount text field
                              Container(
                                width: 110,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFD1D5DB)),
                                ),
                                child: Center(
                                  child: TextField(
                                    controller: _customBidCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                                    decoration: const InputDecoration(
                                      prefixText: 'Rs. ',
                                      prefixStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (val) {
                                      final parsed = double.tryParse(val);
                                      if (parsed != null) {
                                        setState(() => _selectedBidAmount = parsed);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Place Bid button
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: _isSubmittingBid ? null : () => _submitBid(auction),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primaryGreen,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      elevation: 0,
                                    ),
                                    icon: const Icon(Icons.gavel_rounded, size: 18),
                                    label: Text(
                                      '${'Place Bid'.trAuto(context)} (Rs. ${_selectedBidAmount?.toStringAsFixed(0) ?? auction.minNextBid.toStringAsFixed(0)})',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Optional Buy-Now button
                          if (hasBuyNow) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 38,
                              child: OutlinedButton.icon(
                                onPressed: () => _handleBuyNow(auction),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _orangeAccent,
                                  side: const BorderSide(color: _orangeAccent, width: 1.2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.flash_on_rounded, size: 16),
                                label: Text(
                                  '${'⚡ Buy Now Immediately'.trAuto(context)}: Rs. ${auction.buyNowPrice!.toStringAsFixed(2)} / ${auction.unit}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label.trAuto(context),
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value.trAuto(context),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF111827), fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

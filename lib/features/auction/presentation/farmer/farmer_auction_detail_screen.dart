import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/auction_model.dart';
import '../../services/auction_manager.dart';
import 'create_edit_auction_screen.dart';

class FarmerAuctionDetailScreen extends StatefulWidget {
  final String auctionId;

  const FarmerAuctionDetailScreen({super.key, required this.auctionId});

  @override
  State<FarmerAuctionDetailScreen> createState() => _FarmerAuctionDetailScreenState();
}

class _FarmerAuctionDetailScreenState extends State<FarmerAuctionDetailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Refresh countdown every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleAcceptBid(AuctionModel auction) async {
    final highestBid = auction.currentHighestBid;
    final highestBidder = auction.highestBidderName ?? 'Top Bidder';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.handshake_rounded, color: Color(0xFF1E5E3A), size: 24),
            SizedBox(width: 8),
            Text('Accept Highest Bid?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to accept the leading bid of Rs. ${highestBid.toStringAsFixed(2)} / ${auction.unit} from $highestBidder?\n\nThis will immediately finalize the auction and mark the lot as SOLD.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Bidding Active', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E5E3A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Accept & Finalize'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      HapticFeedback.heavyImpact();
      await AuctionManager.instance.endAuction(auction.id, markAsSold: true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Congratulations! Crop lot sold to $highestBidder!'),
            backgroundColor: const Color(0xFF1E5E3A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleDeleteAuction(AuctionModel auction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 24),
            SizedBox(width: 8),
            Text('Delete Auction?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to permanently delete this crop auction? This action cannot be undone.',
          style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuctionManager.instance.deleteAuction(auction.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auction removed successfully.'),
            backgroundColor: Color(0xFF111827),
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
            appBar: AppBar(title: const Text('Auction Details')),
            body: const Center(child: Text('Auction not found or deleted.')),
          );
        }

        const primaryColor = Color(0xFF1E5E3A);
        final isActive = auction.isActive;
        final isSold = auction.isSold;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FBFA),
          body: CustomScrollView(
            slivers: [
              // Header Sliver
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: primaryColor,
                leading: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 16,
                    child: Icon(Icons.arrow_back_rounded, color: Color(0xFF111827), size: 18),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  if (!isSold)
                    IconButton(
                      icon: const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 16,
                        child: Icon(Icons.edit_rounded, color: Color(0xFF111827), size: 18),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateEditAuctionScreen(existingAuction: auction),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 18),
                    ),
                    onPressed: () => _handleDeleteAuction(auction),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        auction.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: primaryColor),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.65),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSold
                                    ? const Color(0xFF0284C7)
                                    : (isActive ? const Color(0xFF10B981) : const Color(0xFF6B7280)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSold
                                        ? Icons.check_circle_rounded
                                        : (isActive ? Icons.bolt_rounded : Icons.timer_off_rounded),
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isSold ? 'SOLD' : (isActive ? 'LIVE AUCTION' : 'CLOSED'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              auction.cropName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${auction.quantity.toStringAsFixed(0)} ${auction.unit} • ${auction.location}',
                              style: const TextStyle(
                                color: Color(0xFFD1FAE5),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status card with live countdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Time Remaining',
                                  style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, size: 16, color: Color(0xFFEA580C)),
                                    const SizedBox(width: 5),
                                    Text(
                                      auction.remainingTimeString,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFEA580C),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(height: 36, width: 1, color: const Color(0xFFE5E7EB)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Total Bids Received',
                                  style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(Icons.people_outline_rounded, size: 16, color: primaryColor),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${auction.totalBids} Bids',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Current Bid Highlights Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F3822), Color(0xFF1E5E3A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E5E3A).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
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
                                    const Text(
                                      'CURRENT HIGHEST BID',
                                      style: TextStyle(
                                        color: Color(0xFF86EFAC),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rs. ${auction.effectivePrice.toStringAsFixed(2)} / ${auction.unit}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFDE047), size: 30),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Divider(color: Color(0x33FFFFFF), height: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Top Bidder: ${auction.highestBidderName ?? "No bids yet"}',
                                  style: const TextStyle(
                                    color: Color(0xFFD1FAE5),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Lot Value: Rs. ${auction.totalLotValue.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Color(0xFFFEF08A),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Accept highest bid CTA (If bids exist and active)
                      if (isActive && auction.totalBids > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleAcceptBid(auction),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.check_circle_rounded),
                              label: const Text(
                                'Accept Leading Bid & Sell Now',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),

                      // Bid History Log Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Live Bids History',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${auction.bids.length} Entries',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (auction.bids.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const Center(
                            child: Column(
                              children: [
                                Icon(Icons.history_toggle_off_rounded, size: 36, color: Color(0xFF9CA3AF)),
                                SizedBox(height: 8),
                                Text(
                                  'No bids placed yet',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF374151)),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Your auction is published. Bids from interested buyers will appear here in real-time.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                ),
                              ],
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
                            final bid = auction.bids[idx];
                            final isTop = idx == 0;

                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isTop ? const Color(0xFFF0FDF4) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isTop ? const Color(0xFF86EFAC) : const Color(0xFFE5E7EB),
                                  width: isTop ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isTop ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: isTop
                                          ? const Icon(Icons.emoji_events_rounded, color: Color(0xFFEAB308), size: 18)
                                          : Text('#${auction.bids.length - idx}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF6B7280),
                                              )),
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
                                              bid.bidderName,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF111827),
                                              ),
                                            ),
                                            if (isTop) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF16A34A),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  'LEADING',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 8.5,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (bid.notes.isNotEmpty)
                                          Text(
                                            bid.notes,
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Rs. ${bid.amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: isTop ? const Color(0xFF15803D) : const Color(0xFF111827),
                                        ),
                                      ),
                                      Text(
                                        'per ${auction.unit}',
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 24),

                      // Auction Specifications Details Card
                      const Text(
                        'Harvest & Terms Details',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
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
                            _buildInfoRow('Starting Price', 'Rs. ${auction.startingPrice.toStringAsFixed(2)} / ${auction.unit}'),
                            const Divider(height: 16),
                            _buildInfoRow('Min. Bid Increment', 'Rs. ${auction.minBidIncrement.toStringAsFixed(2)}'),
                            const Divider(height: 16),
                            _buildInfoRow(
                              'Reserve Price',
                              auction.reservePrice != null ? 'Rs. ${auction.reservePrice!.toStringAsFixed(2)}' : 'No Reserve (Open)',
                            ),
                            const Divider(height: 16),
                            _buildInfoRow(
                              'Buy-Now Price',
                              auction.buyNowPrice != null ? 'Rs. ${auction.buyNowPrice!.toStringAsFixed(2)}' : 'Bidding Only',
                            ),
                            const Divider(height: 16),
                            _buildInfoRow('Delivery Terms', auction.deliveryTerms),
                            if (auction.description.isNotEmpty) ...[
                              const Divider(height: 16),
                              _buildInfoRow('Quality Notes', auction.description),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF111827), fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

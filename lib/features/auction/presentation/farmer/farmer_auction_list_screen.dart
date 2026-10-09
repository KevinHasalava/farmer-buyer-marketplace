import 'package:flutter/material.dart';

import '../../../../core/localization/app_settings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/auction_model.dart';
import '../../services/auction_manager.dart';
import 'create_edit_auction_screen.dart';
import 'farmer_auction_detail_screen.dart';

class FarmerAuctionListScreen extends StatefulWidget {
  const FarmerAuctionListScreen({super.key});

  @override
  State<FarmerAuctionListScreen> createState() => _FarmerAuctionListScreenState();
}

class _FarmerAuctionListScreenState extends State<FarmerAuctionListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _primaryGreen = Color(0xFF1E5E3A);
  static const Color _bgSoft = Color(0xFFF9FBFA);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuctionManager.instance,
      builder: (context, _) {
        final allAuctions = AuctionManager.instance.auctions;
        final activeList = allAuctions.where((a) => a.isActive).toList();
        final completedList = allAuctions.where((a) => !a.isActive).toList();

        final totalBids = allAuctions.fold<int>(0, (s, a) => s + a.totalBids);
        final totalLotValue = activeList.fold<double>(0.0, (s, a) => s + a.totalLotValue);

        return Scaffold(
          backgroundColor: _bgSoft,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'My Crop Auctions',
              style: AppTheme.fontStyle(
                context.currentLanguage,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
            ),
            centerTitle: false,
            iconTheme: const IconThemeData(color: Color(0xFF111827)),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: _primaryGreen, size: 26),
                tooltip: 'Create New Auction',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateEditAuctionScreen()),
                ),
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: _primaryGreen,
                  indicatorWeight: 3,
                  labelColor: _primaryGreen,
                  unselectedLabelColor: const Color(0xFF6B7280),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: [
                    Tab(text: 'Live (${activeList.length})'),
                    Tab(text: 'Completed (${completedList.length})'),
                    Tab(text: 'All (${allAuctions.length})'),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateEditAuctionScreen()),
            ),
            backgroundColor: _primaryGreen,
            icon: const Icon(Icons.gavel_rounded, color: Colors.white),
            label: const Text(
              'New Auction',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
          body: Column(
            children: [
              // Executive stats overview banner
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F3822), Color(0xFF1E5E3A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E5E3A).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTopStat('Live Lots', '${activeList.length}'),
                    Container(height: 32, width: 1, color: Colors.white24),
                    _buildTopStat('Bids Received', '$totalBids'),
                    Container(height: 32, width: 1, color: Colors.white24),
                    _buildTopStat('Active Volume', 'Rs. ${(totalLotValue / 1000).toStringAsFixed(0)}k'),
                  ],
                ),
              ),

              // TabBar View Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAuctionListView(activeList, 'No active auctions right now.'),
                    _buildAuctionListView(completedList, 'No completed auctions yet.'),
                    _buildAuctionListView(allAuctions, 'No auctions created yet.'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD1FAE5),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAuctionListView(List<AuctionModel> list, String emptyMessage) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.gavel_rounded, size: 36, color: _primaryGreen),
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create an auction for bulk harvest lots and let verified buyers bid for top market rates.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateEditAuctionScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Crop Auction', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, idx) {
        final auction = list[idx];
        return _buildAuctionCard(auction);
      },
    );
  }

  Widget _buildAuctionCard(AuctionModel auction) {
    final isActive = auction.isActive;
    final isSold = auction.isSold;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FarmerAuctionDetailScreen(auctionId: auction.id),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? const Color(0xFFA7F3D0) : const Color(0xFFE5E7EB),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Top Row with Photo, Title, and Badges
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      auction.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: const Color(0xFFDCFCE7),
                        child: const Icon(Icons.grass_rounded, color: _primaryGreen),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSold
                                    ? const Color(0xFFE0F2FE)
                                    : (isActive ? const Color(0xFFECFDF5) : const Color(0xFFF3F4F6)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isSold ? 'SOLD' : (isActive ? 'LIVE' : 'CLOSED'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isSold
                                      ? const Color(0xFF0369A1)
                                      : (isActive ? const Color(0xFF059669) : const Color(0xFF6B7280)),
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (isActive)
                              Row(
                                children: [
                                  const Icon(Icons.timer_outlined, size: 13, color: Color(0xFFEA580C)),
                                  const SizedBox(width: 3),
                                  Text(
                                    auction.remainingTimeString,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFEA580C),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          auction.cropName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${auction.quantity.toStringAsFixed(0)} ${auction.unit} • ${auction.category}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // Bottom bar with Highest Bid and CTA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: const Color(0xFFF8FAFC),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auction.totalBids > 0 ? 'Top Bid' : 'Starting Price',
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Rs. ${auction.effectivePrice.toStringAsFixed(2)} / ${auction.unit}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: auction.totalBids > 0 ? const Color(0xFF059669) : const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.gavel_rounded, size: 12, color: _primaryGreen),
                        const SizedBox(width: 4),
                        Text(
                          '${auction.totalBids} bids',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFF9CA3AF)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

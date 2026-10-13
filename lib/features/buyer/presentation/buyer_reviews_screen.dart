import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/buyer_review_model.dart';
import '../services/buyer_profile_manager.dart';
import '../services/buyer_review_service.dart';

/// 🌟 Buyer Reviews & Ratings Management Screen (Member 1 - IT23843770 Thennakoon T.M.S.N)
/// Full Create, Read, Update, Delete (CRUD) for verified produce reviews & farmer ratings.
class BuyerReviewsScreen extends StatefulWidget {
  const BuyerReviewsScreen({
    super.key,
    this.initialProductId,
    this.initialProductName,
    this.initialFarmerName,
    this.initialProductImage,
    this.initialFilterIndex = 0,
  });

  final String? initialProductId;
  final String? initialProductName;
  final String? initialFarmerName;
  final String? initialProductImage;
  final int initialFilterIndex;

  @override
  State<BuyerReviewsScreen> createState() => _BuyerReviewsScreenState();
}

class _BuyerReviewsScreenState extends State<BuyerReviewsScreen> {
  final BuyerReviewService _service = BuyerReviewService.instance;
  final BuyerProfileManager _profileManager = BuyerProfileManager.instance;

  late int _selectedFilterIndex; // 0: All, 1: My Reviews, 2: 5 Stars, 3: Farmer Replies

  static const Color _forestGreen = Color(0xFF0F3D24);
  static const Color _emerald = Color(0xFF059669);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _workspaceBg = Color(0xFFF8FAFC);
  static const Color _goldStar = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _selectedFilterIndex = widget.initialFilterIndex;
    _service.addListener(_onServiceChanged);
    _service.loadReviews();

    // If navigated with initial product, prompt to write review after frame renders
    if (widget.initialProductId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWriteOrEditReviewSheet(
          preselectedProductId: widget.initialProductId,
          preselectedProductName: widget.initialProductName,
          preselectedFarmerName: widget.initialFarmerName,
          preselectedProductImage: widget.initialProductImage,
        );
      });
    }
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  String get _currentBuyerId => _profileManager.profile.id;
  String get _currentBuyerName =>
      _profileManager.profile.name.isNotEmpty ? _profileManager.profile.name : 'Chamara Perera';

  List<BuyerReview> _getFilteredReviews() {
    final list = _service.allReviews;
    return switch (_selectedFilterIndex) {
      1 => list.where((r) => r.isOwnedBy(_currentBuyerId)).toList(),
      2 => list.where((r) => r.rating >= 4.9).toList(),
      3 => list.where((r) => r.hasFarmerReply).toList(),
      _ => list,
    };
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _getFilteredReviews();
    final allList = _service.allReviews;
    final avgRating = allList.isEmpty
        ? 4.9
        : (allList.fold<double>(0.0, (acc, r) => acc + r.rating) / allList.length);
    final myCount = _service.myReviews(_currentBuyerId).length;

    return Scaffold(
      backgroundColor: _workspaceBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ratings & Buyer Reviews',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Verified Farm Produce & Farmer Feedback',
              style: TextStyle(fontSize: 11, color: _emerald, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sync Reviews',
            icon: const Icon(Icons.sync_rounded, color: _emerald, size: 21),
            onPressed: () async {
              HapticFeedback.lightImpact();
              await _service.loadReviews();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Reviews synchronized with cloud.'),
                  backgroundColor: _emerald,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWriteOrEditReviewSheet(),
        backgroundColor: _forestGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.rate_review_rounded, size: 19),
        label: const Text(
          'Write a Review',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _service.loadReviews(),
        color: _emerald,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Top Summary Rating Analytics Card ────────────────────────
              _buildRatingSummaryCard(avgRating, allList.length, myCount),
              const SizedBox(height: 16),

              // ── 2. Filter Pills ─────────────────────────────────────────────
              _buildFilterPills(allList.length, myCount),
              const SizedBox(height: 16),

              // ── 3. Reviews List (or Empty State) ─────────────────────────────
              if (reviews.isEmpty) ...[
                _buildEmptyState(),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => _buildReviewCard(reviews[i]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📊 1. RATING SUMMARY STATS CARD
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildRatingSummaryCard(double avgRating, int totalReviews, int myCount) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Big Rating Number & Stars
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: _textDark,
                  letterSpacing: -1,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return const Icon(Icons.star_rounded, color: _goldStar, size: 16);
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalReviews Verified Reviews',
                style: const TextStyle(fontSize: 10.5, color: _textMuted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(width: 18),
          const SizedBox(
            height: 60,
            child: VerticalDivider(color: Color(0xFFF1F5F9), thickness: 1.5),
          ),
          const SizedBox(width: 14),

          // Right: Key Badges & User Reviews Count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 12, color: _emerald),
                          SizedBox(width: 4),
                          Text(
                            '96% Positive Rating',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _emerald,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'You have posted $myCount ${myCount == 1 ? 'review' : 'reviews'}. Your feedback directly helps farmers maintain organic quality standards.',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏷️ 2. FILTER PILLS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFilterPills(int total, int myCount) {
    final filters = [
      'All ($total)',
      'My Reviews ($myCount)',
      '5 Stars ★★★★★',
      'Farmer Responses',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSel = _selectedFilterIndex == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filters[i]),
              selected: isSel,
              onSelected: (val) {
                if (val) setState(() => _selectedFilterIndex = i);
              },
              selectedColor: const Color(0xFFDCFCE7),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                color: isSel ? const Color(0xFF047857) : const Color(0xFF475569),
              ),
              side: BorderSide(
                color: isSel ? _emerald : _borderColor,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📝 3. INDIVIDUAL REVIEW CARD (WITH EDIT & DELETE)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildReviewCard(BuyerReview r) {
    final isMyReview = r.isOwnedBy(_currentBuyerId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isMyReview ? const Color(0xFFA7F3D0) : _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Produce Header: Thumbnail + Product Name + Farmer Name + (My Review badge)
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: r.productImage.isNotEmpty
                    ? Image.network(
                        r.productImage,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackProductIcon(),
                      )
                    : _buildFallbackProductIcon(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.productName,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Farmer: ${r.farmerName}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
              if (isMyReview) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: const Text(
                    'Your Review',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Rating Row: Stars + Quality Tag + Time Ago
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (idx) {
                  final filled = idx < r.rating.floor();
                  return Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: filled ? _goldStar : const Color(0xFFCBD5E1),
                    size: 17,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Text(
                  r.qualityTag,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                r.timeAgo,
                style: const TextStyle(fontSize: 10.5, color: _textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Review Title
          Text(
            r.title,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 4),

          // Comment Body
          Text(
            r.comment,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF334155),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),

          // Reviewer Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFFE2E8F0),
                backgroundImage: r.buyerAvatar.isNotEmpty ? NetworkImage(r.buyerAvatar) : null,
                child: r.buyerAvatar.isEmpty
                    ? const Icon(Icons.person, size: 14, color: Color(0xFF64748B))
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                r.buyerName,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _textDark),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.verified_rounded, size: 13, color: _emerald),
              const SizedBox(width: 3),
              const Text(
                'Verified Buyer',
                style: TextStyle(fontSize: 10, color: _emerald, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          // Farmer Reply Quote (if exists)
          if (r.hasFarmerReply) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.reply_rounded, size: 16, color: Color(0xFF15803D)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Response from ${r.farmerName}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF15803D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '"${r.farmerReply}"',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF166534),
                            fontStyle: FontStyle.italic,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── ACTION BUTTONS: FARMER REPLY & OWNER EDIT/DELETE ─────────────
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!r.hasFarmerReply) ...[
                TextButton.icon(
                  onPressed: () => _showFarmerReplyDialog(r),
                  icon: const Icon(Icons.reply_rounded, size: 14, color: _forestGreen),
                  label: const Text(
                    'Farmer Reply',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _forestGreen),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              if (isMyReview) ...[
                // Edit Button
                TextButton.icon(
                  onPressed: () => _showWriteOrEditReviewSheet(existingReview: r),
                  icon: const Icon(Icons.edit_outlined, size: 14, color: _emerald),
                  label: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _emerald),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 4),

                // Delete Button
                TextButton.icon(
                  onPressed: () => _confirmDeleteReview(r),
                  icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFDC2626)),
                  label: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackProductIcon() {
    return Container(
      width: 44,
      height: 44,
      color: const Color(0xFFDCFCE7),
      child: const Center(
        child: Icon(Icons.eco_rounded, color: _forestGreen, size: 20),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.rate_review_outlined, color: _forestGreen, size: 36),
            ),
            const SizedBox(height: 14),
            const Text(
              'No Reviews Found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark),
            ),
            const SizedBox(height: 4),
            const Text(
              'Be the first to leave feedback on freshly harvested farm produce.',
              style: TextStyle(fontSize: 12, color: _textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showWriteOrEditReviewSheet(),
              icon: const Icon(Icons.add_rounded, size: 17),
              label: const Text('Write First Review'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✍️ WRITE / EDIT REVIEW BOTTOM SHEET MODAL (CREATE & UPDATE CRUD)
  // ═══════════════════════════════════════════════════════════════════════════
  void _showWriteOrEditReviewSheet({
    BuyerReview? existingReview,
    String? preselectedProductId,
    String? preselectedProductName,
    String? preselectedFarmerName,
    String? preselectedProductImage,
  }) {
    HapticFeedback.lightImpact();

    // Available produce catalogue for selection
    final catalogOptions = [
      {
        'id': 'prod_1',
        'name': 'Nuwara Eliya Highland Carrots',
        'farmer': 'K. M. Bandara',
        'image': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5c317?w=600&auto=format&fit=crop&q=80',
      },
      {
        'id': 'prod_2',
        'name': 'Welimada Fresh White Potatoes',
        'farmer': 'K. M. Bandara',
        'image': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&auto=format&fit=crop&q=80',
      },
      {
        'id': 'prod_3',
        'name': 'Hakgala Crispy Organic Leeks',
        'farmer': 'K. M. Bandara',
        'image': 'https://images.unsplash.com/photo-1524179091875-bf99a9a6fa57?w=600&auto=format&fit=crop&q=80',
      },
      {
        'id': 'prod_4',
        'name': 'Kandy Green Crisp Beans',
        'farmer': 'Sunil Perera',
        'image': 'https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=600&auto=format&fit=crop&q=80',
      },
      {
        'id': 'prod_5',
        'name': 'Dambulla Vine-Ripened Red Tomatoes',
        'farmer': 'Sunil Perera',
        'image': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80',
      },
    ];

    // Determine initial values
    String selectedProdId = existingReview?.productId ??
        preselectedProductId ??
        catalogOptions.first['id']!;

    var selectedItem = catalogOptions.firstWhere(
      (opt) => opt['id'] == selectedProdId,
      orElse: () => {
        'id': selectedProdId,
        'name': preselectedProductName ?? 'Fresh Produce',
        'farmer': preselectedFarmerName ?? 'Local Farmer',
        'image': preselectedProductImage ?? '',
      },
    );

    if (!catalogOptions.any((opt) => opt['id'] == selectedProdId)) {
      catalogOptions.insert(0, selectedItem);
    }

    double currentRating = existingReview?.rating ?? 5.0;
    String selectedTag = existingReview?.qualityTag ?? 'Grade-A Fresh';

    final titleController = TextEditingController(text: existingReview?.title ?? '');
    final commentController = TextEditingController(text: existingReview?.comment ?? '');

    final qualityTags = [
      'Grade-A Fresh',
      '100% Organic',
      'Crisp & Sweet',
      'Fast Cold Transit',
      'Zero Chemical',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final isEditing = existingReview != null;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(modalCtx).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top drag pill
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isEditing ? Icons.edit_note_rounded : Icons.star_rate_rounded,
                            color: _forestGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? 'Edit Your Review' : 'Write Produce Review',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark,
                                ),
                              ),
                              Text(
                                'Verified customer feedback for direct farm quality',
                                style: TextStyle(fontSize: 11, color: _textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 1. Choose Product to Review
                    const Text(
                      'SELECTED HARVEST PRODUCE',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedProdId,
                          isExpanded: true,
                          items: catalogOptions.map((opt) {
                            return DropdownMenuItem<String>(
                              value: opt['id'],
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      opt['image']!,
                                      width: 28,
                                      height: 28,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.eco, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${opt['name']} (${opt['farmer']})',
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _textDark),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: isEditing
                              ? null
                              : (val) {
                                  if (val != null) {
                                    setModalState(() {
                                      selectedProdId = val;
                                      selectedItem = catalogOptions.firstWhere((o) => o['id'] == val);
                                    });
                                  }
                                },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Interactive Star Rating Selector
                    const Text(
                      'YOUR RATING (TAP STARS)',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (idx) {
                              final starVal = (idx + 1).toDouble();
                              final isSelected = starVal <= currentRating;

                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setModalState(() => currentRating = starVal);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Icon(
                                    isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: isSelected ? _goldStar : const Color(0xFFCBD5E1),
                                    size: 32,
                                  ),
                                ),
                              );
                            }),
                          ),
                          Text(
                            switch (currentRating.toInt()) {
                              5 => 'Outstanding! 5.0',
                              4 => 'Very Good 4.0',
                              3 => 'Good 3.0',
                              2 => 'Fair 2.0',
                              _ => 'Poor 1.0',
                            },
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Quality Highlights Tag Chips
                    const Text(
                      'HARVEST QUALITY HIGHLIGHT',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: qualityTags.map((tag) {
                        final isSel = selectedTag == tag;
                        return ChoiceChip(
                          label: Text(tag),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) setModalState(() => selectedTag = tag);
                          },
                          selectedColor: const Color(0xFFDCFCE7),
                          backgroundColor: const Color(0xFFF8FAFC),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? const Color(0xFF047857) : const Color(0xFF475569),
                          ),
                          side: BorderSide(color: isSel ? _emerald : _borderColor),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 4. Review Title Field
                    TextField(
                      controller: titleController,
                      style: const TextStyle(fontSize: 13, color: _textDark),
                      decoration: InputDecoration(
                        labelText: 'Headline / Summary (e.g. Crisp & Sweet)',
                        labelStyle: const TextStyle(fontSize: 12, color: _textMuted),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _emerald, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 5. Review Comment Body Field
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13, color: _textDark),
                      decoration: InputDecoration(
                        labelText: 'Your Experience & Farmer Feedback',
                        hintText: 'Describe freshness, taste, cold van transit arrival...',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        labelStyle: const TextStyle(fontSize: 12, color: _textMuted),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _emerald, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 6. Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _forestGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final comment = commentController.text.trim();

                          if (title.isEmpty || comment.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a review headline and comment.'),
                                backgroundColor: Color(0xFFDC2626),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(ctx);
                          HapticFeedback.mediumImpact();

                          if (isEditing) {
                            // UPDATE (U)
                            await _service.updateReview(
                              reviewId: existingReview.id,
                              rating: currentRating,
                              title: title,
                              comment: comment,
                              qualityTag: selectedTag,
                            );

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✓ Review updated successfully!'),
                                  backgroundColor: _emerald,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } else {
                            // CREATE (C)
                            await _service.createReview(
                              buyerId: _currentBuyerId,
                              buyerName: _currentBuyerName,
                              productId: selectedItem['id']!,
                              productName: selectedItem['name']!,
                              productImage: selectedItem['image']!,
                              farmerId: 'farmer_${selectedItem['farmer']!.toLowerCase().replaceAll(' ', '_')}',
                              farmerName: selectedItem['farmer']!,
                              rating: currentRating,
                              title: title,
                              comment: comment,
                              qualityTag: selectedTag,
                            );

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('✓ Verified review submitted for ${selectedItem['name']}!'),
                                  backgroundColor: _emerald,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          isEditing ? 'Save Changes' : 'Submit Verified Review',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🗑️ DELETE CONFIRMATION DIALOG (DELETE CRUD)
  // ═══════════════════════════════════════════════════════════════════════════
  void _confirmDeleteReview(BuyerReview r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 22),
            SizedBox(width: 8),
            Text(
              'Delete Review',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete your review for "${r.productName}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              await _service.deleteReview(r.id);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Review removed.'),
                    backgroundColor: Color(0xFF0F172A),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 👨‍🌾 FARMER REPLY DIALOG (TWO-WAY FEEDBACK COMMUNICATION)
  // ═══════════════════════════════════════════════════════════════════════════
  void _showFarmerReplyDialog(BuyerReview r) {
    final replyController = TextEditingController();
    final templates = [
      'Thank you! Harvested fresh at dawn.',
      'Glad you loved our produce! Packed with care.',
      'Appreciate your trust in direct organic harvest!',
    ];

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.reply_rounded, color: _forestGreen, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Farmer Reply',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark),
                    ),
                    Text(
                      'Replying as ${r.farmerName}',
                      style: const TextStyle(fontSize: 11, color: _forestGreen, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Review: "${r.title}" (${r.rating}★)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 10),
              const Text(
                'Quick Templates:',
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: _textMuted),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: templates.map((tmpl) {
                  return GestureDetector(
                    onTap: () {
                      setDlgState(() => replyController.text = tmpl);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        tmpl,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF334155)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: replyController,
                maxLines: 3,
                style: const TextStyle(fontSize: 12.5, color: _textDark),
                decoration: InputDecoration(
                  hintText: 'Type reply to buyer...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _forestGreen, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dlgCtx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final text = replyController.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(dlgCtx);
                HapticFeedback.mediumImpact();
                await _service.addFarmerReply(reviewId: r.id, replyText: text);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ Response from ${r.farmerName} published!'),
                      backgroundColor: _forestGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Post Reply'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/constants/constants.dart';
import '../../../widgets/premium/premium_widgets.dart';
import '../models/pre_order_model.dart';
import '../services/pre_order_manager.dart';
import 'create_pre_order_screen.dart';
import 'pre_order_detail_screen.dart';

class PreOrderListScreen extends StatefulWidget {
  final bool isFarmerMode;
  final bool isEmbedded;

  const PreOrderListScreen({
    super.key,
    this.isFarmerMode = false,
    this.isEmbedded = false,
  });

  @override
  State<PreOrderListScreen> createState() => _PreOrderListScreenState();
}

class _PreOrderListScreenState extends State<PreOrderListScreen> {
  int _selectedFilterIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  List<String> get _filters => widget.isFarmerMode
      ? ['Open Requests', 'Active Contracts', 'Completed', 'All']
      : ['All Requests', 'Pending', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PreOrderManager.instance.loadPreOrders();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<PreOrderModel> _filterOrders(List<PreOrderModel> orders) {
    var filtered = orders;

    // Apply Tab/Filter
    if (widget.isFarmerMode) {
      if (_selectedFilterIndex == 0) {
        filtered = filtered.where((o) => o.status == 'Pending').toList();
      } else if (_selectedFilterIndex == 1) {
        filtered = filtered.where((o) => o.status == 'In Progress').toList();
      } else if (_selectedFilterIndex == 2) {
        filtered = filtered.where((o) => o.status == 'Completed').toList();
      }
    } else {
      if (_selectedFilterIndex == 1) {
        filtered = filtered.where((o) => o.status == 'Pending').toList();
      } else if (_selectedFilterIndex == 2) {
        filtered = filtered.where((o) => o.status == 'In Progress').toList();
      } else if (_selectedFilterIndex == 3) {
        filtered = filtered.where((o) => o.status == 'Completed').toList();
      }
    }

    // Apply Search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((o) {
        final query = _searchQuery.toLowerCase();
        return o.cropName.toLowerCase().contains(query) ||
            o.buyerName.toLowerCase().contains(query) ||
            (o.farmerName?.toLowerCase().contains(query) ?? false) ||
            o.deliveryLocation.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final listContent = Column(
      children: [
        // Search & Filter Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              // Search input
              TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: widget.isFarmerMode
                      ? 'Search open crops, buyers or locations...'
                      : 'Search contracts or crop variety...',
                  hintStyle: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryGreen, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Filter Chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final label = _filters[index];
                    final isSelected = _selectedFilterIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilterIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryGreen : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryGreen : const Color(0xFFCBD5E1),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Main List Content
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () => PreOrderManager.instance.loadPreOrders(),
            child: ListenableBuilder(
              listenable: PreOrderManager.instance,
              builder: (context, _) {
                if (PreOrderManager.instance.isLoading && PreOrderManager.instance.preOrders.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                }

                final allOrders = PreOrderManager.instance.preOrders;
                final orders = _filterOrders(allOrders);

                if (orders.isEmpty) {
                  return ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDCFCE7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.handshake_outlined, size: 36, color: AppColors.primaryGreen),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.isFarmerMode
                                  ? (_selectedFilterIndex == 0 ? 'No Open Requests Awaiting Farmers' : 'No Contracts Found')
                                  : 'No Pre-Order Contracts Found',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                widget.isFarmerMode
                                    ? 'Check back soon as wholesale buyers submit new crop demands.'
                                    : 'Create forward contracts to request fresh harvests directly from verified local farmers.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ),
                            if (!widget.isFarmerMode) ...[
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const CreatePreOrderScreen()),
                                  );
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Create Pre-Order Request', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _PreOrderCard(
                      order: order,
                      isFarmerMode: widget.isFarmerMode,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PreOrderDetailScreen(
                              preOrderId: order.id,
                              isFarmerMode: widget.isFarmerMode,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return listContent;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          AppHeaderBanner(
            title: 'Contract Farming',
            subtitle: widget.isFarmerMode
                ? 'Accept pre-orders and guarantee sales'
                : 'Request crops directly from farmers',
            showBack: true,
            badgeText: widget.isFarmerMode ? 'FARMER' : 'BUYER',
          ),
          Expanded(child: listContent),
        ],
      ),
      floatingActionButton: !widget.isFarmerMode
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePreOrderScreen()),
                );
              },
              backgroundColor: AppColors.primaryGreen,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(context.tr.newRequest, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : FloatingActionButton.extended(
              onPressed: () {
                PreOrderManager.instance.loadPreOrders();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refreshed contract requests!'), duration: Duration(seconds: 1)),
                );
              },
              backgroundColor: const Color(0xFF166534),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text('Refresh', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
    );
  }
}

class _PreOrderCard extends StatelessWidget {
  final PreOrderModel order;
  final bool isFarmerMode;
  final VoidCallback onTap;

  const _PreOrderCard({
    required this.order,
    required this.isFarmerMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (order.status == 'Pending') {
      statusColor = AppColors.accentOrange;
    } else if (order.status == 'In Progress') {
      statusColor = const Color(0xFF2563EB);
    } else if (order.status == 'Completed') {
      statusColor = AppColors.primaryGreen;
    } else {
      statusColor = Colors.grey;
    }

    final totalValue = (order.requiredQuantityKg * order.offeredPricePerKg).toStringAsFixed(0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Status & Price Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      order.status == 'Pending' && isFarmerMode
                          ? 'OPEN FOR ACCEPTANCE'
                          : order.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs ${order.offeredPricePerKg.toInt()}/Kg',
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Est. Rs $totalValue',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Crop Name & Qty
              Text(
                '${order.requiredQuantityKg.toInt()} Kg of ${order.cropName}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),

              // Buyer info
              Row(
                children: [
                  const Icon(Icons.storefront_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Buyer: ${order.buyerName}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Farmer info or Open Status
              if (order.farmerName != null && order.farmerName!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.agriculture_rounded, size: 14, color: Color(0xFF047857)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Farmer: ${order.farmerName}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF047857), fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ] else if (isFarmerMode && order.status == 'Pending') ...[
                const SizedBox(height: 3),
                const Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 14, color: AppColors.accentOrange),
                    SizedBox(width: 5),
                    Text(
                      'Awaiting Farmer Proposal',
                      style: TextStyle(fontSize: 12.5, color: AppColors.accentOrange, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],

              if (order.deliveryLocation.isNotEmpty) ...[
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        order.deliveryLocation,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: AppColors.divider),
              ),

              // Bottom Date and Action indicator
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Target: ${order.expectedDeliveryDate.day}/${order.expectedDeliveryDate.month}/${order.expectedDeliveryDate.year}',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textDark, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (isFarmerMode && order.status == 'Pending')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.handshake_rounded, size: 13, color: Color(0xFF047857)),
                          SizedBox(width: 4),
                          Text(
                            'Accept Contract',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                          ),
                        ],
                      ),
                    )
                  else
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

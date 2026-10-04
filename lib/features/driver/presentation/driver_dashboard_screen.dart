import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/routes/app_router.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/premium/premium_widgets.dart';

class _DeliveryOrder {
  const _DeliveryOrder({
    required this.id,
    required this.produce,
    required this.weightKg,
    required this.pickup,
    required this.dropoff,
    required this.km,
    required this.payout,
    required this.emoji,
  });

  final String id, produce, pickup, dropoff, emoji;
  final double weightKg, km;
  final int payout;
}

const _mockOrders = [
  _DeliveryOrder(
    id: '#F2H-1042',
    produce: 'Carrots & Leeks',
    weightKg: 25,
    pickup: 'Nuwara Eliya Farm Gate',
    dropoff: 'Kandy City Centre',
    km: 12.4,
    payout: 1250,
    emoji: '🥕',
  ),
  _DeliveryOrder(
    id: '#F2H-1043',
    produce: 'Mangoes (TJC)',
    weightKg: 18,
    pickup: 'Dambulla Economic Centre',
    dropoff: 'Kurunegala Town',
    km: 8.1,
    payout: 860,
    emoji: '🥭',
  ),
  _DeliveryOrder(
    id: '#F2H-1044',
    produce: 'Tomatoes',
    weightKg: 30,
    pickup: 'Bandarawela Farms',
    dropoff: 'Badulla Market',
    km: 15.7,
    payout: 1480,
    emoji: '🍅',
  ),
];

/// Role-based home for drivers: availability toggle, earnings, and orders.
class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  bool _online = true;
  int _tab = 0;
  final Set<String> _accepted = {};

  String get _name {
    final n = const AuthService().currentUserModel?.name ?? '';
    return n.isEmpty ? 'Driver' : n.split(' ').first;
  }

  Future<void> _logout() async {
    try {
      await const AuthService().signOut();
    } catch (_) {}
    if (!mounted) return;
    await context.settings.clearRole();
    if (mounted) context.go(AppRoutes.roleSelection);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    const g = AppColors.driverGradient;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero header ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32)),
              child: AuroraBackground(
                accent: g.first,
                secondary: g.last,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: g),
                              ),
                              child: const Icon(Icons.delivery_dining_rounded,
                                  color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${tr.hello} 👋',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.6),
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    _name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const LanguagePill(),
                            const SizedBox(width: 8),
                            GlassIconButton(
                              icon: Icons.logout_rounded,
                              onTap: _logout,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Online toggle
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            setState(() => _online = !_online);
                          },
                          child: GlassCard(
                            radius: 20,
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _online
                                        ? const Color(0xFF4ADE80)
                                        : Colors.white38,
                                    boxShadow: _online
                                        ? [
                                            const BoxShadow(
                                              color: Color(0xFF4ADE80),
                                              blurRadius: 10,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _online ? tr.online : tr.offline,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Switch.adaptive(
                                  value: _online,
                                  activeThumbColor: Colors.white,
                                  activeTrackColor: const Color(0xFF22C55E),
                                  onChanged: (v) => setState(() => _online = v),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Earnings
                        GlassCard(
                          radius: 24,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr.todaysEarnings,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Rs. 4,860',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E)
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      '▲ 18%',
                                      style: TextStyle(
                                        color: Color(0xFF4ADE80),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _stat(Icons.route_rounded, '6', tr.trips),
                                  _divider(),
                                  _stat(Icons.straighten_rounded, '58 km',
                                      tr.distance),
                                  _divider(),
                                  _stat(Icons.star_rounded, '4.9', tr.rating),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Orders header ────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tr.availableOrders,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  if (_online)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: g.last.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_mockOrders.length} ${tr.nearby}',
                        style: TextStyle(
                          color: g.last,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Orders list / offline state ──────────────────────────────────
          if (!_online)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.power_settings_new_rounded,
                        size: 56, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    Text(
                      tr.offlineHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.separated(
                itemCount: _mockOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final o = _mockOrders[i];
                  return FadeSlideIn(
                    delay: Duration(milliseconds: 100 * i),
                    child: _OrderCard(
                      order: o,
                      accepted: _accepted.contains(o.id),
                      onAccept: () {
                        HapticFeedback.mediumImpact();
                        setState(() => _accepted.add(o.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr.orderAccepted)),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        backgroundColor: Colors.white,
        indicatorColor: g.last.withValues(alpha: 0.12),
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: g.last),
            label: tr.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded, color: g.last),
            label: tr.navOrders,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon:
                Icon(Icons.account_balance_wallet_rounded, color: g.last),
            label: tr.navEarnings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: g.last),
            label: tr.navProfile,
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label) => Expanded(
        child: Column(
          children: [
            Icon(icon, color: AppColors.gold, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      );

  Widget _divider() => Container(
        width: 1,
        height: 40,
        color: Colors.white.withValues(alpha: 0.12),
      );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.accepted,
    required this.onAccept,
  });

  final _DeliveryOrder order;
  final bool accepted;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    const g = AppColors.driverGradient;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(order.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.produce,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${order.id}  •  ${order.weightKg.toStringAsFixed(0)} kg  •  ${order.km} km',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rs. ${order.payout}',
                style: TextStyle(
                  color: g.last,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Route timeline
          Row(
            children: [
              Column(
                children: [
                  _dot(const Color(0xFF22C55E)),
                  Container(width: 2, height: 22, color: AppColors.divider),
                  _dot(g.last),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _place(tr.pickup, order.pickup),
                    const SizedBox(height: 10),
                    _place(tr.dropoff, order.dropoff),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: accepted
                  ? Container(
                      key: const ValueKey('ok'),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF16A34A), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            tr.accepted,
                            style: const TextStyle(
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GradientButton(
                      key: const ValueKey('accept'),
                      label: tr.accept,
                      colors: g,
                      foreground: Colors.white,
                      height: 48,
                      icon: Icons.check_rounded,
                      onPressed: onAccept,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: c, width: 3),
        ),
      );

  Widget _place(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}

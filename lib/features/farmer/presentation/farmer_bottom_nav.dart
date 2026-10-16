import 'package:flutter/material.dart';

import '../../../core/localization/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/presentation/farmer_profile_screen.dart';
import '../../orders_chat/presentation/chat_list_screen.dart';
import '../services/farmer_profile_manager.dart';
import 'farmer_orders_screen.dart';
import 'farmer_products_screen.dart';

/// Single bottom navigation bar shared by every farmer screen, so the tabs are
/// always the same 5 items: Home, Products, Orders, Chat, Profile.
class FarmerBottomNav extends StatelessWidget {
  const FarmerBottomNav({super.key, required this.current});

  /// 0 = Home, 1 = Products, 2 = Orders, 3 = Chat, 4 = Profile.
  final int current;

  static const _active = Color(0xFF235A43);
  static const _inactive = Color(0xFF9CA3AF);

  void _go(BuildContext context, int target) {
    if (target == current) return;
    final nav = Navigator.of(context);
    if (target == 0) {
      nav.popUntil((r) => r.isFirst);
      return;
    }
    final Widget page = switch (target) {
      1 => const FarmerProductsScreen(),
      2 => const FarmerOrdersScreen(),
      3 => const ChatListScreen(currentRole: 'farmer'),
      _ => FarmerProfileScreen(
        farmer: FarmerProfileManager.instance.profile.toFarmerData(),
      ),
    };
    final route = MaterialPageRoute<void>(builder: (_) => page);
    // From Home stack on top; from another tab swap, so Back always returns Home.
    if (current == 0) {
      nav.push(route);
    } else {
      nav.pushReplacement(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, bool)>[
      (Icons.home_rounded, context.tr.navHome, false),
      (Icons.spa_outlined, 'Products'.trAuto(context), false),
      (Icons.assignment_outlined, context.tr.navOrders, true),
      (Icons.chat_bubble_outline_rounded, context.tr.navChat, false),
      (Icons.person_outline_rounded, context.tr.navProfile, false),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _item(
                    context,
                    icon: items[i].$1,
                    label: items[i].$2,
                    hasBadge: items[i].$3,
                    selected: i == current,
                    onTap: () => _go(context, i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool hasBadge,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color = selected ? _active : _inactive;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 24, color: color),
              if (hasBadge)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTheme.fontStyle(
              context.currentLanguage,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

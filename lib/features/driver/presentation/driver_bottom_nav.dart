import 'package:flutter/material.dart';

import '../../../core/localization/app_settings.dart';
import 'deliveries_screen.dart';
import 'delivery_history_screen.dart';
import 'driver_chat_screen.dart';
import 'driver_dashboard_screen.dart';
import 'driver_profile_screen.dart';

/// Single bottom navigation bar shared by every driver screen, so the tabs are
/// always the same 5 items: Home, Deliveries, History, Chat, Profile.
class DriverBottomNav extends StatelessWidget {
  const DriverBottomNav({
    super.key,
    required this.current,
    this.driverId,
    this.driverName,
    this.vehicleType,
    this.plateNumber,
    this.bankName,
    this.accountNumber,
    this.cargoCapacity,
    this.licenseNumber,
  });

  /// 0 = Home, 1 = Deliveries, 2 = History, 3 = Chat, 4 = Profile.
  final int current;

  final String? driverId;
  final String? driverName;
  final String? vehicleType;
  final String? plateNumber;
  final String? bankName;
  final String? accountNumber;
  final String? cargoCapacity;
  final String? licenseNumber;

  static const _active = Color(0xFF065F46);
  static const _inactive = Color(0xFF94A3B8);

  void _go(BuildContext context, int target) {
    if (target == current) return;
    final nav = Navigator.of(context);
    if (target == 0) {
      nav.pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => DriverDashboardScreen(
            driverId: driverId,
            driverName: driverName,
            vehicleType: vehicleType,
            plateNumber: plateNumber,
            bankName: bankName,
            accountNumber: accountNumber,
            cargoCapacity: cargoCapacity,
            licenseNumber: licenseNumber,
          ),
        ),
        (route) => route.isFirst,
      );
      return;
    }

    final Widget page = switch (target) {
      1 => const DeliveriesScreen(),
      2 => const DeliveryHistoryScreen(),
      3 => DriverChatScreen(
          driverId: driverId,
          driverName: driverName,
          vehicleType: vehicleType,
          plateNumber: plateNumber,
          bankName: bankName,
          accountNumber: accountNumber,
          cargoCapacity: cargoCapacity,
          licenseNumber: licenseNumber,
        ),
      _ => DriverProfileScreen(
          driverId: driverId,
          driverName: driverName,
          vehicleType: vehicleType,
          plateNumber: plateNumber,
          bankName: bankName,
          accountNumber: accountNumber,
          cargoCapacity: cargoCapacity,
          licenseNumber: licenseNumber,
        ),
    };

    final route = MaterialPageRoute<void>(builder: (_) => page);
    if (current == 0) {
      nav.push(route);
    } else {
      nav.pushReplacement(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, bool)>[
      (Icons.local_shipping_rounded, context.tr.navHome, false),
      (Icons.inventory_2_outlined, context.tr.navDeliveries, true),
      (Icons.receipt_long_rounded, 'History'.trAuto(context), false),
      (Icons.chat_bubble_outline_rounded, context.tr.navChat, false),
      (Icons.person_outline_rounded, context.tr.navProfile, false),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
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
              if (hasBadge && !selected)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 7,
                    height: 7,
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
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

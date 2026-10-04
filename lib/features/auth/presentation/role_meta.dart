import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/localization/app_strings.dart';

/// Visual + text metadata for each [UserRole].
extension UserRoleMeta on UserRole {
  String label(AppStrings tr) => switch (this) {
        UserRole.buyer => tr.roleBuyer,
        UserRole.farmer => tr.roleFarmer,
        UserRole.driver => tr.roleDriver,
      };

  String subtitle(AppStrings tr) => switch (this) {
        UserRole.buyer => tr.roleBuyerSub,
        UserRole.farmer => tr.roleFarmerSub,
        UserRole.driver => tr.roleDriverSub,
      };

  IconData get icon => switch (this) {
        UserRole.buyer => Icons.shopping_basket_rounded,
        UserRole.farmer => Icons.agriculture_rounded,
        UserRole.driver => Icons.delivery_dining_rounded,
      };

  String get emoji => switch (this) {
        UserRole.buyer => '🛒',
        UserRole.farmer => '👨‍🌾',
        UserRole.driver => '🛵',
      };

  List<Color> get gradient => switch (this) {
        UserRole.buyer => AppColors.buyerGradient,
        UserRole.farmer => AppColors.farmerGradient,
        UserRole.driver => AppColors.driverGradient,
      };
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/routes/app_router.dart';
import '../../../widgets/premium/premium_widgets.dart';
import 'role_meta.dart';

/// Step 4: Role Selection Screen — matching original Login Account Type selector.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selected;

  @override
  void initState() {
    super.initState();
    _selected = context.settings.role;
  }

  Future<void> _continue() async {
    final role = _selected;
    if (role == null) return;
    await context.settings.setRole(role);
    if (mounted) context.push(AppRoutes.phoneAuth);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // ── Signature Curved Header matching login_screen.dart ──────────
          AppHeaderBanner(
            title: tr.whoAreYou.replaceAll('\n', ' '),
            subtitle: tr.whoAreYouSub,
            badgeText: 'STEP 2 OF 3',
            showBack: true,
            onBack: () => context.go(AppRoutes.onboarding),
            trailing: const AppLanguagePill(isDarkHeader: true),
            heightFactor: 0.27,
          ),

          // ── Selectable Cards ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spaceLG,
                AppDimensions.spaceMD,
                AppDimensions.spaceLG,
                AppDimensions.spaceLG,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECT YOUR ACCOUNT TYPE',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),

                  // 1. Buyer
                  AppSelectableCard(
                    title: UserRole.buyer.label(tr),
                    subtitle: UserRole.buyer.subtitle(tr),
                    icon: Icons.shopping_basket_rounded,
                    iconEmoji: '🛒',
                    badgeText: 'POPULAR',
                    isSelected: _selected == UserRole.buyer,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = UserRole.buyer);
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),

                  // 2. Farmer
                  AppSelectableCard(
                    title: UserRole.farmer.label(tr),
                    subtitle: UserRole.farmer.subtitle(tr),
                    icon: Icons.agriculture_rounded,
                    iconEmoji: '👨‍🌾',
                    isSelected: _selected == UserRole.farmer,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = UserRole.farmer);
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),

                  // 3. Driver
                  AppSelectableCard(
                    title: UserRole.driver.label(tr),
                    subtitle: UserRole.driver.subtitle(tr),
                    icon: Icons.local_shipping_rounded,
                    iconEmoji: '🛵',
                    badgeText: 'EARN',
                    isSelected: _selected == UserRole.driver,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = UserRole.driver);
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Continue CTA ──────────────────────────────────────────
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spaceLG,
                0,
                AppDimensions.spaceLG,
                AppDimensions.spaceLG,
              ),
              child: AppPrimaryButton(
                label: tr.continueBtn,
                onPressed: _selected == null ? null : _continue,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

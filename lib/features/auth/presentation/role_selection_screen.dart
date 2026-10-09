import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/premium/premium_widgets.dart';
import 'role_meta.dart';

/// Step 4: Role Selection Screen — rich agricultural styling tailored for Sri Lankan Farmers & Buyers.
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
            badgeText: tr.stepOf(2, 3),
            showBack: true,
            onBack: () => context.go(AppRoutes.onboarding),
            trailing: const AppLanguagePill(isDarkHeader: true),
            heightFactor: 0.27,
          ),

          // ── Rich Agro Role Selection Cards ──────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spaceLG,
                AppDimensions.spaceMD,
                AppDimensions.spaceLG,
                AppDimensions.spaceLG,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tr.roleSelectHint,
                          style: AppTheme.fontStyle(
                            context.currentLanguage,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🌾 Farm2Home Direct',
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTheme.fontStyle(
                            context.currentLanguage,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),

                  // 1. Farmer Card (ගොවි මහතා)
                  AppSelectableCard(
                    title: tr.roleFarmerTitle,
                    subtitle: UserRole.farmer.subtitle(tr),
                    icon: Icons.agriculture_rounded,
                    iconEmoji: '🌾',
                    imageUrl:
                        'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=400&auto=format&fit=crop&q=80',
                    categoryTag: '🌾 ${tr.roleFarmer}',
                    badgeText: tr.direct100,
                    selectedLabel: tr.roleSelectedBadge,
                    featureChips: [
                      '🌾 ${tr.onb1ChipA}',
                      '💰 ${tr.onb1ChipB}',
                      '⚡ ${tr.onb1ChipC}',
                    ],
                    isSelected: _selected == UserRole.farmer,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = UserRole.farmer);
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),

                  // 2. Buyer Card (ගැණුම්කරු)
                  AppSelectableCard(
                    title: tr.roleBuyerTitle,
                    subtitle: UserRole.buyer.subtitle(tr),
                    icon: Icons.shopping_basket_rounded,
                    iconEmoji: '🥕',
                    imageUrl:
                        'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&auto=format&fit=crop&q=80',
                    categoryTag: '🥕 ${tr.roleBuyer}',
                    badgeText: tr.badgePopular,
                    selectedLabel: tr.roleSelectedBadge,
                    featureChips: [
                      '🥕 ${tr.onb2ChipA}',
                      '🏷️ ${tr.onb2ChipB}',
                      '🚚 ${tr.onb2ChipC}',
                    ],
                    isSelected: _selected == UserRole.buyer,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selected = UserRole.buyer);
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),

                  // 3. Driver Card (ප්‍රවාහකයා)
                  AppSelectableCard(
                    title: tr.roleDriverTitle,
                    subtitle: UserRole.driver.subtitle(tr),
                    icon: Icons.local_shipping_rounded,
                    iconEmoji: '🛵',
                    imageUrl:
                        'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=400&auto=format&fit=crop&q=80',
                    categoryTag: '🛵 ${tr.roleDriver}',
                    badgeText: tr.badgeEarn,
                    selectedLabel: tr.roleSelectedBadge,
                    featureChips: [
                      '⏰ ${tr.onb3ChipA}',
                      '💵 ${tr.onb3ChipB}',
                      '📍 ${tr.onb3ChipC}',
                    ],
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

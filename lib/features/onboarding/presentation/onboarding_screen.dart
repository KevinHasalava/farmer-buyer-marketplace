import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../widgets/premium/premium_widgets.dart';

class _SlideData {
  const _SlideData({
    required this.tag,
    required this.title,
    required this.body,
    required this.icon,
    required this.chipA,
    required this.chipB,
  });

  final String tag;
  final String title;
  final String body;
  final IconData icon;
  final String chipA;
  final String chipB;
}

List<_SlideData> _getSlides(AppStrings tr) => [
      _SlideData(
        tag: tr.onb1Tag,
        title: tr.onb1Title,
        body: tr.onb1Body,
        icon: Icons.agriculture_rounded,
        chipA: tr.onb1ChipA,
        chipB: tr.onb1ChipB,
      ),
      _SlideData(
        tag: tr.onb2Tag,
        title: tr.onb2Title,
        body: tr.onb2Body,
        icon: Icons.shopping_basket_rounded,
        chipA: tr.onb2ChipA,
        chipB: tr.onb2ChipB,
      ),
      _SlideData(
        tag: tr.onb3Tag,
        title: tr.onb3Title,
        body: tr.onb3Body,
        icon: Icons.local_shipping_rounded,
        chipA: tr.onb3ChipA,
        chipB: tr.onb3ChipB,
      ),
    ];

/// Step 3: Onboarding Carousel matching original light theme styling.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.settings.completeOnboarding();
    if (mounted) context.go(AppRoutes.roleSelection);
  }

  void _nextPage(int total) {
    HapticFeedback.lightImpact();
    if (_currentPage < total - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final slides = _getSlides(tr);
    final isLast = _currentPage == slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar with Language Pill and Skip ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceMD,
                vertical: AppDimensions.spaceXS,
              ),
              child: Row(
                children: [
                  const AppLanguagePill(isDarkHeader: false),
                  const Spacer(),
                  if (!isLast)
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        tr.skip,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),

            // ── Carousel Slider ─────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) {
                  final slide = slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceLG,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        // Hero Icon Illustration Card
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWhite,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen
                                    .withValues(alpha: 0.12),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: AppColors.darkGreen,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Icon(
                                slide.icon,
                                size: 48,
                                color: AppColors.accentOrange,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceXL),

                        // Tag Chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceMD,
                            vertical: AppDimensions.spaceXXS + 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            slide.tag,
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryGreen,
                              fontSize: 11,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceMD),

                        // Title
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            height: 1.25,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceSM),

                        // Subtitle
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.spaceLG),

                        // Highlight chips row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _featureChip(slide.chipA),
                            const SizedBox(width: 8),
                            _featureChip(slide.chipB),
                          ],
                        ),

                        const Spacer(flex: 2),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Bottom Controls ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spaceLG,
                0,
                AppDimensions.spaceLG,
                AppDimensions.spaceLG,
              ),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.primaryGreen
                              : const Color(0xFFD1D5DB),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceLG),

                  // Button
                  AppPrimaryButton(
                    label: isLast ? tr.getStarted : tr.next,
                    onPressed: () => _nextPage(slides.length),
                    icon: Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 14,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

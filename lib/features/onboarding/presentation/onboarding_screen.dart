import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/constants.dart';
import '../../../core/localization/app_settings.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_router.dart';
import '../../../widgets/premium/premium_widgets.dart';

class _OnboardSlide {
  const _OnboardSlide({
    required this.tag,
    required this.badge,
    required this.topRightBadge,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.quote,
    required this.fallbackIcon,
    required this.chipA,
    required this.chipB,
    required this.chipC,
  });

  final String tag;
  final String badge;
  final String topRightBadge;
  final String title;
  final String body;
  final String imageUrl;
  final String quote;
  final IconData fallbackIcon;
  final String chipA;
  final String chipB;
  final String chipC;
}

List<_OnboardSlide> _getSlides(AppStrings tr) => [
      _OnboardSlide(
        tag: tr.onb1Tag,
        badge: '🌾 100% කෙළින්ම ගොවිබිමෙන්',
        topRightBadge: '0% MIDDLEMEN',
        title: tr.onb1Title,
        body: tr.onb1Body,
        // High quality smiling Sri Lankan / Asian farmer in lush farm field
        imageUrl:
            'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=900&auto=format&fit=crop&q=85',
        quote: tr.onb1Quote,
        fallbackIcon: Icons.agriculture_rounded,
        chipA: tr.onb1ChipA,
        chipB: tr.onb1ChipB,
        chipC: tr.onb1ChipC,
      ),
      _OnboardSlide(
        tag: tr.onb2Tag,
        badge: '🥕 දිනපතා නැවුම් අස්වැන්න',
        topRightBadge: 'FAIR RATES',
        title: tr.onb2Title,
        body: tr.onb2Body,
        // Fresh farm vegetables and produce basket direct from soil
        imageUrl:
            'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=900&auto=format&fit=crop&q=85',
        quote: tr.onb2Quote,
        fallbackIcon: Icons.shopping_basket_rounded,
        chipA: tr.onb2ChipA,
        chipB: tr.onb2ChipB,
        chipC: tr.onb2ChipC,
      ),
      _OnboardSlide(
        tag: tr.onb3Tag,
        badge: '🚚 ප්‍රදේශයේ ගොවි ප්‍රවාහනය',
        topRightBadge: 'DAILY CASH',
        title: tr.onb3Title,
        body: tr.onb3Body,
        // Farm-to-home fresh deliveries & transport
        imageUrl:
            'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=900&auto=format&fit=crop&q=85',
        quote: tr.onb3Quote,
        fallbackIcon: Icons.local_shipping_rounded,
        chipA: tr.onb3ChipA,
        chipB: tr.onb3ChipB,
        chipC: tr.onb3ChipC,
      ),
    ];

/// Premium Onboarding with rich agricultural imagery, badges & farmer-market aesthetic.
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
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
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
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextButton(
                        onPressed: _finish,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          tr.skip,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 38),
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
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceLG,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 4),

                        // ── Rich Agricultural Image Card ────────────────────
                        _buildHeroImageCard(slide),

                        const SizedBox(height: 18),

                        // ── Tag Badge with Pulse Dot ────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primaryGreen.withValues(alpha: 0.10),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusFull),
                            border: Border.all(
                              color: AppColors.primaryGreen
                                  .withValues(alpha: 0.28),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                slide.tag.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryGreen,
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Headline ────────────────────────────────────────
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            height: 1.24,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ── Subtitle ────────────────────────────────────────
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── 3 Agricultural Feature Chips ─────────────────────
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            _featureChip(slide.chipA, Icons.verified_rounded),
                            _featureChip(slide.chipB, Icons.payments_rounded),
                            _featureChip(slide.chipC, Icons.bolt_rounded),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Bottom Controls & Indicators ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spaceLG,
                0,
                AppDimensions.spaceLG,
                AppDimensions.spaceMD,
              ),
              child: Column(
                children: [
                  // Modern Animated Leaf / Pill Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: i == _currentPage
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF22C55E),
                                    Color(0xFF15803D),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: i == _currentPage
                              ? null
                              : const Color(0xFFD1D5DB),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusFull),
                          boxShadow: i == _currentPage
                              ? [
                                  BoxShadow(
                                    color: AppColors.primaryGreen
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceMD),

                  // Button
                  AppPrimaryButton(
                    label: isLast ? tr.getStarted : tr.next,
                    onPressed: () => _nextPage(slides.length),
                    icon: Icons.arrow_forward_rounded,
                  ),

                  const SizedBox(height: 8),

                  // Reassuring Local Agricultural Heritage Tag
                  Text(
                    '🇱🇰 ශ්‍රී ලාංකික ගොවි ජනතාව සවිබල ගන්වන විශ්වාසනීය වෙළඳපොළ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero Image Card with Nature Gradient Overlay & Badges ────────────────
  Widget _buildHeroImageCard(_OnboardSlide slide) {
    return Container(
      width: double.infinity,
      height: 255,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.darkGreen.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image with smooth fade & fallback
            Image.network(
              slide.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF032B1C), Color(0xFF0F5A2C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        slide.fallbackIcon,
                        size: 72,
                        color: AppColors.accentOrange,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Farm2Home Agriculture',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                );
              },
            ),

            // Subtle dark gradients for pristine badge & quote contrast
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.40),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.70),
                    ],
                  ),
                ),
              ),
            ),

            // Top-Left Floating Trust Badge
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      color: AppColors.accentOrange,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      slide.badge,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top-Right Agro Tag
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  slide.topRightBadge,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),

            // Bottom Floating Agro Quote Banner
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
                child: Text(
                  slide.quote,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

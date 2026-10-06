import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_settings.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/routes/app_router.dart';

class _OnboardSlideData {
  const _OnboardSlideData({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.networkFallbackUrl,
    required this.buttonText,
  });

  final String tag;
  final String title;
  final String subtitle;
  final String assetPath;
  final String networkFallbackUrl;
  final String buttonText;
}

/// Fullscreen premium Onboarding screens matching the custom design
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
    await context.read<AppSettings>().completeOnboarding();
    if (mounted) context.go(AppRoutes.roleSelection);
  }

  void _onNextTap(int totalSlides) {
    HapticFeedback.lightImpact();
    if (_currentPage < totalSlides - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _onBackTap() {
    HapticFeedback.selectionClick();
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  List<_OnboardSlideData> _getSlides(AppStrings tr) => [
        _OnboardSlideData(
          tag: tr.onb1Tag,
          title: tr.onb1Title,
          subtitle: tr.onb1Body,
          assetPath: 'assets/images/onboarding_1.jpg',
          networkFallbackUrl:
              'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=1200&auto=format&fit=crop&q=85',
          buttonText: tr.continueBtn,
        ),
        _OnboardSlideData(
          tag: tr.onb2Tag,
          title: tr.onb2Title,
          subtitle: tr.onb2Body,
          assetPath: 'assets/images/onboarding_2.jpg',
          networkFallbackUrl:
              'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1200&auto=format&fit=crop&q=85',
          buttonText: tr.getStarted,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final slides = _getSlides(tr);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF05170C),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background Carousel ─────────────────────────────────────────
            PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                final slide = slides[index];
                return _buildBackground(slide);
              },
            ),

            // ── Dark Lush Agricultural Gradient Overlay ─────────────────────
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.20, 0.48, 0.76, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.40),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.25),
                      const Color(0xD9062313), // Deep natural forest green
                      const Color(0xFA04170C),
                    ],
                  ),
                ),
              ),
            ),

            // ── Top Navigation Bar ──────────────────────────────────────────
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Item: Back arrow on slide 1, or Language switcher on slide 2
                      if (_currentPage == 0)
                        _buildBackButton()
                      else
                        _buildLanguageTogglePill(),

                      // Right Item: Translucent "Skip" pill
                      _buildSkipButton(tr.skip),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom Content: Tag, Title, Subtitle, Indicator, Button ─────
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag with glowing mint dot
                      _buildTagPill(slides[_currentPage].tag),

                      const SizedBox(height: 14),

                      // Headline
                      Text(
                        slides[_currentPage].title,
                        style: GoogleFonts.poppins(
                          fontSize: 29,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.22,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Subtitle
                      Text(
                        slides[_currentPage].subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.45,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Animated Page Indicators (matching reference mockup)
                      _buildIndicators(slides.length),

                      const SizedBox(height: 24),

                      // Action Button (Continue / Get Started)
                      _buildActionButton(
                        label: slides[_currentPage].buttonText,
                        onPressed: () => _onNextTap(slides.length),
                      ),

                      const SizedBox(height: 14),

                      // Home indicator line
                      Center(
                        child: Container(
                          width: 140,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Background Image Widget (Asset with Network & Gradient Fallback) ──────
  Widget _buildBackground(_OnboardSlideData slide) {
    return Image.asset(
      slide.assetPath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => Image.network(
        slide.networkFallbackUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F3B25), Color(0xFF061E11)],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.agriculture_rounded,
              size: 80,
              color: Colors.white24,
            ),
          ),
        ),
      ),
    );
  }

  // ── Back Button (Slide 1) ────────────────────────────────────────────────
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: _onBackTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.20),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.chevron_left_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  // ── Language Toggle Pill [ EN | සිං ] (Slide 2) ──────────────────────────
  Widget _buildLanguageTogglePill() {
    final settings = context.watch<AppSettings>();
    final isSinhala = settings.language == AppLanguage.sinhala;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // English Pill
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              settings.setLanguage(AppLanguage.english);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: !isSinhala ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'EN',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: !isSinhala
                      ? const Color(0xFF0A2E1A)
                      : Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),

          // Sinhala Pill
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              settings.setLanguage(AppLanguage.sinhala);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSinhala ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'සිං',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSinhala
                      ? const Color(0xFF0A2E1A)
                      : Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Frosted "Skip" Pill ──────────────────────────────────────────────────
  Widget _buildSkipButton(String label) {
    return GestureDetector(
      onTap: _finish,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.20),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Tag Badge with mint dot ──────────────────────────────────────────────
  Widget _buildTagPill(String tag) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF6EE7B7), // Mint green dot
          ),
        ),
        const SizedBox(width: 8),
        Text(
          tag.toUpperCase(),
          style: GoogleFonts.poppins(
            color: const Color(0xFF6EE7B7),
            fontSize: 12,
            letterSpacing: 1.3,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ── Left-Aligned Animated Page Indicators ────────────────────────────────
  Widget _buildIndicators(int total) {
    return Row(
      children: List.generate(total, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 26 : 6,
          height: 4.5,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF6EE7B7)
                : Colors.white.withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  // ── Full-Width White Pill Action Button with Circular Arrow ──────────────
  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.only(left: 28, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F2B1D),
                    letterSpacing: -0.2,
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0D2E1C), // Deep forest green circle
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

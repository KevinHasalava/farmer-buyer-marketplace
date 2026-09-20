import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/constants.dart';
import '../../../core/routes/app_router.dart';

/// Onboarding slide data model.
class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
}

/// Multi-page onboarding carousel.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      title: 'Grown this morning.\nYours by evening.',
      subtitle:
          'Shop the real farmer. Pay the farmer, not the middlemen.',
      icon: Icons.agriculture_rounded,
      bgColor: AppColors.darkGreen,
    ),
    _OnboardingPage(
      title: 'From soil to doorstep,\novernight.',
      subtitle: 'Order by 6pm and it\'s at your door before breakfast.',
      icon: Icons.local_shipping_rounded,
      bgColor: AppColors.primaryGreen,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          // ── Page Content ────────────────────────────────────────────────
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return _OnboardingPageView(page: page);
            },
          ),

          // ── Skip Button ─────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + AppDimensions.spaceSM,
            right: AppDimensions.spaceMD,
            child: TextButton(
              onPressed: () => context.go(AppRoutes.login),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.surfaceWhite,
              ),
              child: Text(
                'Skip',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.surfaceWhite,
                ),
              ),
            ),
          ),

          // ── Bottom Controls ─────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spaceLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dots indicator
                    Row(
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(
                              right: AppDimensions.spaceXXS),
                          width: i == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? AppColors.surfaceWhite
                                : AppColors.surfaceWhite.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimensions.spaceLG),

                    // Next / Get Started button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceWhite,
                          foregroundColor: AppColors.darkGreen,
                        ),
                        child: Text(isLast ? 'Get Started' : 'Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});
  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: page.bgColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(page.icon, size: 120, color: AppColors.surfaceWhite.withValues(alpha: 0.2)),
          const SizedBox(height: AppDimensions.spaceXL),
          Padding(
            padding: AppDimensions.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceSM,
                    vertical: AppDimensions.spaceXXS,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    '• FARM DIRECT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.surfaceWhite,
                      letterSpacing: AppTextStyles.trackingWidest,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceMD),
                Text(
                  page.title,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: AppColors.surfaceWhite,
                    fontWeight: FontWeight.w700,
                    height: AppTextStyles.lineHeightTight,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceMD),
                Text(
                  page.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.surfaceWhite.withValues(alpha: 0.8),
                    height: AppTextStyles.lineHeightLoose,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

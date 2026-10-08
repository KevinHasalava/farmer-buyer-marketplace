import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/constants.dart';
import '../../core/localization/app_settings.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Signature Curved Green Header (matching Login & Welcome screens)
// ─────────────────────────────────────────────────────────────────────────────
class AppHeaderBanner extends StatelessWidget {
  const AppHeaderBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.showBack = false,
    this.onBack,
    this.trailing,
    this.heightFactor = 0.25,
  });

  final String title;
  final String? subtitle;
  final String? badgeText;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Stack(
      children: [
        // Dark forest green gradient background
        Container(
          width: double.infinity,
          height: screenHeight * heightFactor,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF032B1C),
                Color(0xFF063725),
                Color(0xFF0D5C38),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // Decorative background leaf icons
        Positioned(
          right: -20,
          top: -10,
          child: Transform.rotate(
            angle: -0.3,
            child: Icon(
              Icons.eco_rounded,
              size: 110,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          left: -20,
          bottom: 10,
          child: Transform.rotate(
            angle: 0.4,
            child: Icon(
              Icons.local_florist_rounded,
              size: 80,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),

        // Content
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top navigation row
                  Row(
                    children: [
                      if (showBack)
                        GestureDetector(
                          onTap: onBack ?? () => Navigator.maybePop(context),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 38),
                      const Spacer(),
                      if (badgeText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            badgeText!,
                            style: AppTheme.fontStyle(
                              context.currentLanguage,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (trailing != null)
                        trailing!
                      else
                        const SizedBox(width: 38),
                    ],
                  ),
                  const Spacer(),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTheme.fontStyle(
                      context.currentLanguage,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),

                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: AppTheme.fontStyle(
                        context.currentLanguage,
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),

        // Signature wave clipper at the bottom connecting to backgroundLight
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: AppBottomWaveClipper(),
            child: Container(
              height: 28,
              color: AppColors.backgroundLight,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Signature Bottom Wave Clipper (reusable)
// ─────────────────────────────────────────────────────────────────────────────
class AppBottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width * 0.25,
      0,
      size.width * 0.5,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width,
      0,
    );
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// App Brand Logo (squircle dark green + amber leaf motif matching Welcome screen)
// ─────────────────────────────────────────────────────────────────────────────
class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.eco_rounded,
        color: AppColors.accentOrange,
        size: size * 0.5,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Selectable Card (Agro-styled Role & Account Selection Card)
// ─────────────────────────────────────────────────────────────────────────────
class AppSelectableCard extends StatelessWidget {
  const AppSelectableCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badgeText,
    this.iconEmoji,
    this.imageUrl,
    this.categoryTag,
    this.featureChips,
    this.selectedLabel,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badgeText;
  final String? iconEmoji;
  final String? imageUrl;
  final String? categoryTag;
  final List<String>? featureChips;
  final String? selectedLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFFF0FDF4),
                    Color(0xFFDCFCE7),
                    Color(0xFFF7FAF7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : const Color(0xFFE2E8F0),
            width: isSelected ? 2.2 : 1.4,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Subtle Agricultural Botanical Watermark in corner
              Positioned(
                bottom: -12,
                right: -12,
                child: IgnorePointer(
                  child: Icon(
                    Icons.eco_rounded,
                    size: 84,
                    color: AppColors.primaryGreen.withValues(
                      alpha: isSelected ? 0.09 : 0.035,
                    ),
                  ),
                ),
              ),

              // Main Card Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Category & Selection Status Row
                    Row(
                      children: [
                        if (categoryTag != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryGreen
                                      .withValues(alpha: 0.12)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryGreen
                                        .withValues(alpha: 0.3)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.eco_rounded,
                                  size: 11,
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  categoryTag!.toUpperCase(),
                                  style: AppTheme.fontStyle(
                                    context.currentLanguage,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: isSelected
                                        ? AppColors.primaryGreen
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Spacer(),

                        // If Selected: Active Green Pill Badge
                        if (isSelected && selectedLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 11,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  selectedLabel!,
                                  style: AppTheme.fontStyle(
                                    context.currentLanguage,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (badgeText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badgeText!,
                              style: AppTheme.fontStyle(
                                context.currentLanguage,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentOrange,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Main Row: Rich Avatar + Texts + Glowing Tick
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Rich Agricultural Avatar ─────────────────────────
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryGreen
                                    : AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : const Color(0xFFCBD5E1),
                                  width: isSelected ? 2.5 : 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primaryGreen
                                              .withValues(alpha: 0.25),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _fallbackIcon(),
                                        loadingBuilder:
                                            (context, child, progress) {
                                          if (progress == null) return child;
                                          return Container(
                                            color: const Color(0xFFF1F5F9),
                                            child: const Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.primaryGreen,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : _fallbackIcon(),
                              ),
                            ),

                            // Micro Agro Badge on avatar corner
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : AppColors.darkGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    iconEmoji ?? '🌾',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 14),

                        // ── Role Title & Descriptive Subtitle ───────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: AppTheme.fontStyle(
                                  context.currentLanguage,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: isSelected
                                      ? AppColors.darkGreen
                                      : AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: AppTheme.fontStyle(
                                  context.currentLanguage,
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // ── Glorious Animated Agro Tick (Checkmark Seal) ────
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF22C55E),
                                      Color(0xFF15803D),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected ? null : const Color(0xFFF8FAFC),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFFCBD5E1),
                              width: isSelected ? 2.2 : 2.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryGreen
                                          .withValues(alpha: 0.45),
                                      blurRadius: 12,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: AnimatedScale(
                              scale: isSelected ? 1.0 : 0.75,
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutBack,
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 19,
                                      color: Colors.white,
                                    )
                                  : Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFCBD5E1),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Feature Chips Row
                    if (featureChips != null && featureChips!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        children: featureChips!.map((chip) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryGreen
                                        .withValues(alpha: 0.35)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              chip,
                              style: AppTheme.fontStyle(
                                context.currentLanguage,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.darkGreen
                                    : AppColors.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    if (iconEmoji != null) {
      return Center(
        child: Text(
          iconEmoji!,
          style: const TextStyle(fontSize: 28),
        ),
      );
    }
    return Icon(
      icon,
      size: 28,
      color: isSelected ? Colors.white : AppColors.primaryGreen,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Solid Primary Green CTA Button (matching Login / Welcome screens)
// ─────────────────────────────────────────────────────────────────────────────
class AppPrimaryButton extends StatefulWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? AppColors.primaryGreen;

    return GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: _enabled
          ? (_) {
              setState(() => _pressed = false);
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: widget.onPressed == null ? 0.45 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            height: AppDimensions.buttonHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              boxShadow: widget.onPressed == null
                  ? null
                  : [
                      BoxShadow(
                        color: bg.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            alignment: Alignment.center,
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.label,
                        style: AppTheme.fontStyle(
                          context.currentLanguage,
                          fontSize: AppTextStyles.labelLarge,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: AppTextStyles.trackingWide,
                        ),
                      ),
                      if (widget.icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(widget.icon, color: Colors.white, size: 20),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Language Pill (Light Themed)
// ─────────────────────────────────────────────────────────────────────────────
class AppLanguagePill extends StatelessWidget {
  const AppLanguagePill({super.key, this.isDarkHeader = false});

  final bool isDarkHeader;

  @override
  Widget build(BuildContext context) {
    AppSettings? settings;
    try {
      settings = context.watch<AppSettings>();
    } catch (_) {}
    final lang = settings?.language ?? AppLanguage.english;

    return GestureDetector(
      onTap: () => showAppLanguageSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDarkHeader
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkHeader
                ? Colors.white.withValues(alpha: 0.3)
                : const Color(0xFFE5E7EB),
          ),
          boxShadow: isDarkHeader
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.translate_rounded,
              color: isDarkHeader ? Colors.white : AppColors.primaryGreen,
              size: 15,
            ),
            const SizedBox(width: 6),
            Text(
              lang.nativeName,
              style: AppTheme.fontStyle(
                lang,
                color: isDarkHeader ? Colors.white : AppColors.textDark,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDarkHeader
                  ? Colors.white.withValues(alpha: 0.7)
                  : AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Language Bottom Sheet (Light Theme matching other bottom sheets)
// ─────────────────────────────────────────────────────────────────────────────
Future<void> showAppLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      AppSettings? settings;
      try {
        settings = ctx.watch<AppSettings>();
      } catch (_) {}
      final currentLang = settings?.language ?? AppLanguage.english;
      final strings = settings?.strings ?? const AppStrings(AppLanguage.english);

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              strings.chooseLanguage,
              style: AppTheme.fontStyle(
                currentLang,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              strings.chooseLanguageSub,
              textAlign: TextAlign.center,
              style: AppTheme.fontStyle(
                currentLang,
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            for (final l in AppLanguage.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    settings?.setLanguage(l);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: currentLang == l
                          ? const Color(0xFFE8F8EF)
                          : const Color(0xFFF9FBFA),
                      border: Border.all(
                        color: currentLang == l
                            ? AppColors.primaryGreen
                            : const Color(0xFFE5E7EB),
                        width: currentLang == l ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: currentLang == l
                                ? AppColors.primaryGreen
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: currentLang == l
                                  ? AppColors.primaryGreen
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Text(
                            l.glyph,
                            style: AppTheme.fontStyle(
                              l,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: currentLang == l
                                  ? Colors.white
                                  : AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.nativeName,
                              style: AppTheme.fontStyle(
                                l,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              l.englishName,
                              style: AppTheme.fontStyle(
                                l,
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (currentLang == l)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryGreen,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

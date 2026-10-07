import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/constants.dart';
import '../localization/app_settings.dart';

/// Provides [lightTheme] and [darkTheme] for the Farm Trust app.
///
/// Dynamically configures the native font family based on [AppLanguage]:
/// - Sinhala: Noto Sans Sinhala (fallback Poppins, Noto Sans Tamil)
/// - Tamil: Noto Sans Tamil (fallback Poppins, Noto Sans Sinhala)
/// - English: Poppins (fallback Noto Sans Sinhala, Noto Sans Tamil)
abstract final class AppTheme {
  // ── Font Helpers ───────────────────────────────────────────────────────────
  static String fontFamily(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.sinhala:
        return GoogleFonts.notoSansSinhala().fontFamily!;
      case AppLanguage.tamil:
        return GoogleFonts.notoSansTamil().fontFamily!;
      case AppLanguage.english:
        return GoogleFonts.poppins().fontFamily!;
    }
  }

  static List<String> fontFamilyFallbacks(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.sinhala:
        return [
          GoogleFonts.poppins().fontFamily!,
          GoogleFonts.notoSansTamil().fontFamily!,
        ];
      case AppLanguage.tamil:
        return [
          GoogleFonts.poppins().fontFamily!,
          GoogleFonts.notoSansSinhala().fontFamily!,
        ];
      case AppLanguage.english:
        return [
          GoogleFonts.notoSansSinhala().fontFamily!,
          GoogleFonts.notoSansTamil().fontFamily!,
        ];
    }
  }

  static TextStyle fontStyle(
    AppLanguage lang, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: fontFamily(lang),
      fontFamilyFallback: fontFamilyFallbacks(lang),
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  // ── Text Theme ─────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(
    Color baseColor, [
    AppLanguage language = AppLanguage.english,
  ]) {
    final family = fontFamily(language);
    final fallbacks = fontFamilyFallbacks(language);

    TextStyle style({
      required double fontSize,
      FontWeight? fontWeight,
      double? letterSpacing,
      double? height,
      Color? overrideColor,
    }) {
      return TextStyle(
        fontFamily: family,
        fontFamilyFallback: fallbacks,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: overrideColor ?? baseColor,
        letterSpacing: letterSpacing,
        height: height,
      );
    }

    return TextTheme(
      displayLarge: style(
        fontSize: AppTextStyles.displayLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: AppTextStyles.trackingTight,
        height: AppTextStyles.lineHeightTight,
      ),
      displayMedium: style(
        fontSize: AppTextStyles.displayMedium,
        fontWeight: FontWeight.w700,
        letterSpacing: AppTextStyles.trackingTight,
      ),
      displaySmall: style(
        fontSize: AppTextStyles.displaySmall,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: style(
        fontSize: AppTextStyles.headlineLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: AppTextStyles.trackingTight,
      ),
      headlineMedium: style(
        fontSize: AppTextStyles.headlineMedium,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: style(
        fontSize: AppTextStyles.headlineSmall,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: style(
        fontSize: AppTextStyles.titleLarge,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: style(
        fontSize: AppTextStyles.titleMedium,
        fontWeight: FontWeight.w500,
        letterSpacing: AppTextStyles.trackingNormal,
      ),
      titleSmall: style(
        fontSize: AppTextStyles.titleSmall,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: style(
        fontSize: AppTextStyles.bodyLarge,
        fontWeight: FontWeight.w400,
        height: AppTextStyles.lineHeightNormal,
      ),
      bodyMedium: style(
        fontSize: AppTextStyles.bodyMedium,
        fontWeight: FontWeight.w400,
        height: AppTextStyles.lineHeightNormal,
      ),
      bodySmall: style(
        fontSize: AppTextStyles.bodySmall,
        fontWeight: FontWeight.w400,
        overrideColor: baseColor.withValues(alpha: 0.7),
      ),
      labelLarge: style(
        fontSize: AppTextStyles.labelLarge,
        fontWeight: FontWeight.w600,
        letterSpacing: AppTextStyles.trackingWide,
      ),
      labelMedium: style(
        fontSize: AppTextStyles.labelMedium,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: style(
        fontSize: AppTextStyles.labelSmall,
        fontWeight: FontWeight.w500,
        letterSpacing: AppTextStyles.trackingWidest,
      ),
    );
  }

  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData lightTheme([AppLanguage language = AppLanguage.english]) {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryGreen,
      onPrimary: AppColors.surfaceWhite,
      primaryContainer: Color(0xFFB7F0CB),
      onPrimaryContainer: AppColors.darkGreen,
      secondary: AppColors.darkGreen,
      onSecondary: AppColors.surfaceWhite,
      secondaryContainer: Color(0xFF9FCFB5),
      onSecondaryContainer: AppColors.darkGreen,
      tertiary: AppColors.accentOrange,
      onTertiary: AppColors.surfaceWhite,
      tertiaryContainer: Color(0xFFFFE0B2),
      onTertiaryContainer: Color(0xFF4A2800),
      error: AppColors.error,
      onError: AppColors.surfaceWhite,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: AppColors.backgroundLight,
      onSurface: AppColors.textDark,
      surfaceContainerHighest: Color(0xFFE4E9E6),
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: AppColors.darkGreen,
      onInverseSurface: AppColors.surfaceWhite,
      inversePrimary: Color(0xFF6FDB97),
    );

    final textTheme = _buildTextTheme(AppColors.textDark, language);

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily(language),
      fontFamilyFallback: fontFamilyFallbacks(language),
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: fontStyle(
          language,
          fontSize: AppTextStyles.titleLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.surfaceWhite,
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          textStyle: fontStyle(
            language,
            fontSize: AppTextStyles.labelLarge,
            fontWeight: FontWeight.w600,
            letterSpacing: AppTextStyles.trackingWide,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
          ),
          side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          textStyle: fontStyle(
            language,
            fontSize: AppTextStyles.labelLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          textStyle: fontStyle(
            language,
            fontSize: AppTextStyles.labelLarge,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMD,
          vertical: AppDimensions.spaceSM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: fontStyle(
          language,
          fontSize: AppTextStyles.bodyMedium,
          color: AppColors.textHint,
        ),
        labelStyle: fontStyle(
          language,
          fontSize: AppTextStyles.bodyMedium,
          color: AppColors.textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceWhite,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: fontStyle(
          language,
          fontSize: AppTextStyles.labelSmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: fontStyle(
          language,
          fontSize: AppTextStyles.labelSmall,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundLight,
        selectedColor: AppColors.primaryGreen.withValues(alpha: 0.15),
        labelStyle: fontStyle(language, fontSize: AppTextStyles.labelMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceSM,
          vertical: AppDimensions.spaceXXS,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkGreen,
        contentTextStyle: fontStyle(
          language,
          color: AppColors.surfaceWhite,
          fontSize: AppTextStyles.bodySmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData darkTheme([AppLanguage language = AppLanguage.english]) {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF6FDB97),
      onPrimary: Color(0xFF003919),
      primaryContainer: AppColors.primaryGreen,
      onPrimaryContainer: Color(0xFFB7F0CB),
      secondary: Color(0xFF9FCFB5),
      onSecondary: Color(0xFF003824),
      secondaryContainer: AppColors.darkGreen,
      onSecondaryContainer: Color(0xFFBBEDD3),
      tertiary: Color(0xFFFFCC80),
      onTertiary: Color(0xFF3E2000),
      tertiaryContainer: Color(0xFF5A3800),
      onTertiaryContainer: Color(0xFFFFDEAA),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: AppColors.darkSurface,
      onSurface: Color(0xFFE2E8E4),
      surfaceContainerHighest: AppColors.darkCardSurface,
      onSurfaceVariant: Color(0xFFB0BDB7),
      outline: Color(0xFF4A5550),
      outlineVariant: Color(0xFF2D3A35),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE2E8E4),
      onInverseSurface: AppColors.darkSurface,
      inversePrimary: AppColors.primaryGreen,
    );

    final textTheme = _buildTextTheme(const Color(0xFFE2E8E4), language);

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily(language),
      fontFamilyFallback: fontFamilyFallbacks(language),
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: AppColors.darkSurface,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: const Color(0xFFE2E8E4),
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: fontStyle(
          language,
          fontSize: AppTextStyles.titleLarge,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE2E8E4),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6FDB97),
          foregroundColor: const Color(0xFF003919),
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          textStyle: fontStyle(
            language,
            fontSize: AppTextStyles.labelLarge,
            fontWeight: FontWeight.w600,
            letterSpacing: AppTextStyles.trackingWide,
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardSurface,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2D3A35),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/constants.dart';

/// Provides [lightTheme] and [darkTheme] for the Farm Trust app.
///
/// Built on Material 3 with Poppins (Google Fonts) as the brand typeface.
abstract final class AppTheme {
  // ── Text Theme ─────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color baseColor) {
    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: AppTextStyles.displayLarge,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: AppTextStyles.trackingTight,
        height: AppTextStyles.lineHeightTight,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: AppTextStyles.displayMedium,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: AppTextStyles.trackingTight,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: AppTextStyles.displaySmall,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: AppTextStyles.headlineLarge,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: AppTextStyles.trackingTight,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: AppTextStyles.headlineMedium,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: AppTextStyles.headlineSmall,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: AppTextStyles.titleLarge,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: AppTextStyles.titleMedium,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: AppTextStyles.trackingNormal,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: AppTextStyles.titleSmall,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: AppTextStyles.bodyLarge,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: AppTextStyles.lineHeightNormal,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: AppTextStyles.bodyMedium,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: AppTextStyles.lineHeightNormal,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: AppTextStyles.bodySmall,
        fontWeight: FontWeight.w400,
        color: baseColor.withValues(alpha: 0.7),
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: AppTextStyles.labelLarge,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: AppTextStyles.trackingWide,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: AppTextStyles.labelMedium,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: AppTextStyles.labelSmall,
        fontWeight: FontWeight.w500,
        color: baseColor,
        letterSpacing: AppTextStyles.trackingWidest,
      ),
    );
  }

  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      // Primary
      primary: AppColors.primaryGreen,
      onPrimary: AppColors.surfaceWhite,
      primaryContainer: Color(0xFFB7F0CB),
      onPrimaryContainer: AppColors.darkGreen,
      // Secondary — dark green
      secondary: AppColors.darkGreen,
      onSecondary: AppColors.surfaceWhite,
      secondaryContainer: Color(0xFF9FCFB5),
      onSecondaryContainer: AppColors.darkGreen,
      // Tertiary — accent orange
      tertiary: AppColors.accentOrange,
      onTertiary: AppColors.surfaceWhite,
      tertiaryContainer: Color(0xFFFFE0B2),
      onTertiaryContainer: Color(0xFF4A2800),
      // Error
      error: AppColors.error,
      onError: AppColors.surfaceWhite,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      // Surface / Background
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

    final textTheme = _buildTextTheme(AppColors.textDark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // ── Scaffold ────────────────────────────────────────────────────────
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: AppTextStyles.titleLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // ── Elevated Button ──────────────────────────────────────────────────
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
          textStyle: GoogleFonts.poppins(
            fontSize: AppTextStyles.labelLarge,
            fontWeight: FontWeight.w600,
            letterSpacing: AppTextStyles.trackingWide,
          ),
          elevation: 0,
        ),
      ),

      // ── Outlined Button ──────────────────────────────────────────────────
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
          textStyle: GoogleFonts.poppins(
            fontSize: AppTextStyles.labelLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Text Button ──────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          textStyle: GoogleFonts.poppins(
            fontSize: AppTextStyles.labelLarge,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ── Input Decoration ─────────────────────────────────────────────────
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
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: AppTextStyles.bodyMedium,
          color: AppColors.textHint,
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: AppTextStyles.bodyMedium,
          color: AppColors.textSecondary,
        ),
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Bottom Navigation ─────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceWhite,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: AppTextStyles.labelSmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: AppTextStyles.labelSmall,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundLight,
        selectedColor: AppColors.primaryGreen.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.poppins(fontSize: AppTextStyles.labelMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceSM,
          vertical: AppDimensions.spaceXXS,
        ),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkGreen,
        contentTextStyle: GoogleFonts.poppins(
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
  static ThemeData get darkTheme {
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

    final textTheme = _buildTextTheme(const Color(0xFFE2E8E4));

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.darkSurface,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: const Color(0xFFE2E8E4),
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
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
          textStyle: GoogleFonts.poppins(
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

/// Centralised text-style constants.
///
/// Actual [TextStyle] objects are assembled in [AppTheme] using Google Fonts.
/// This file only holds raw size / weight tokens so non-theme code can
/// reference them without importing the theme package.
abstract final class AppTextStyles {
  // ── Font Sizes ────────────────────────────────────────────────────────────
  static const double displayLarge  = 48.0;
  static const double displayMedium = 36.0;
  static const double displaySmall  = 28.0;

  static const double headlineLarge  = 24.0;
  static const double headlineMedium = 20.0;
  static const double headlineSmall  = 18.0;

  static const double titleLarge  = 16.0;
  static const double titleMedium = 14.0;
  static const double titleSmall  = 13.0;

  static const double bodyLarge  = 15.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall  = 12.0;

  static const double labelLarge  = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall  = 10.0;

  // ── Letter Spacing ────────────────────────────────────────────────────────
  static const double trackingTight  = -0.5;
  static const double trackingNormal =  0.0;
  static const double trackingWide   =  0.5;
  static const double trackingWidest =  1.2;

  // ── Line Height multipliers ───────────────────────────────────────────────
  static const double lineHeightTight  = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightLoose  = 1.8;
}

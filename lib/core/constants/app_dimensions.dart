import 'package:flutter/material.dart';

/// Spacing, radius, and sizing constants — single source of truth for layout.
abstract final class AppDimensions {
  // ── Spacing ───────────────────────────────────────────────────────────────
  static const double spaceXXS = 4.0;
  static const double spaceXS  = 8.0;
  static const double spaceSM  = 12.0;
  static const double spaceMD  = 16.0;
  static const double spaceLG  = 24.0;
  static const double spaceXL  = 32.0;
  static const double spaceXXL = 48.0;

  // ── Border Radius ─────────────────────────────────────────────────────────
  static const double radiusXS  = 4.0;
  static const double radiusSM  = 8.0;
  static const double radiusMD  = 12.0;
  static const double radiusLG  = 16.0;
  static const double radiusXL  = 24.0;
  static const double radiusFull = 999.0;

  // ── Icon Sizes ────────────────────────────────────────────────────────────
  static const double iconSM = 18.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;

  // ── Button ────────────────────────────────────────────────────────────────
  static const double buttonHeight     = 52.0;
  static const double buttonHeightSM   = 40.0;
  static const double buttonMinWidth   = 120.0;

  // ── AppBar ────────────────────────────────────────────────────────────────
  static const double appBarHeight = 60.0;

  // ── Card ──────────────────────────────────────────────────────────────────
  static const double cardElevation = 2.0;
  static const double cardPadding   = 16.0;

  // ── Screen Padding ────────────────────────────────────────────────────────
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: spaceMD);
  static const EdgeInsets screenPaddingAll =
      EdgeInsets.all(spaceMD);
}

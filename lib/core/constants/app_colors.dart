import 'package:flutter/material.dart';

/// Central color palette for Farm Trust — sourced from Figma design tokens.
abstract final class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────
  /// Primary brand green used for CTAs, icons, and active states.
  static const Color primaryGreen = Color(0xFF1E8342);

  /// Dark green used for headers, nav-bars, and hero backgrounds.
  static const Color darkGreen = Color(0xFF063725);

  // ── Surface / Background ─────────────────────────────────────────────────
  /// Light off-white background for screens and cards.
  static const Color backgroundLight = Color(0xFFF7F9F8);

  /// Pure white surface (cards, dialogs, bottom-sheets).
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  // ── Text ─────────────────────────────────────────────────────────────────
  /// Primary text colour — near-black for maximum legibility.
  static const Color textDark = Color(0xFF1A1A1A);

  /// Secondary / caption text — softer grey.
  static const Color textSecondary = Color(0xFF6B7280);

  /// Hint / placeholder text.
  static const Color textHint = Color(0xFFADB5BD);

  // ── Accent ───────────────────────────────────────────────────────────────
  /// Amber-orange accent used for badges, promotions, and highlights.
  static const Color accentOrange = Color(0xFFFFA000);

  /// Light amber tint (10 % opacity) for tag backgrounds.
  static const Color accentOrangeLight = Color(0x1AFFA000);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color error   = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info    = Color(0xFF3B82F6);

  // ── Divider / Border ─────────────────────────────────────────────────────
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border  = Color(0xFFD1D5DB);

  // ── Dark theme surfaces ───────────────────────────────────────────────────
  static const Color darkSurface    = Color(0xFF0F1F18);
  static const Color darkCardSurface = Color(0xFF1A2E23);
}

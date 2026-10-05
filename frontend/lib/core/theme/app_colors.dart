import 'package:flutter/material.dart';

/// Centralized brand color tokens for WeTravel.
///
/// Official Brand Palette:
/// - Primary Deep Teal: `#005F73`
/// - Secondary Teal: `#0A9396`
/// - Accent Warm Yellow: `#EE9B00`
/// - Warm Cloud Background: `#FFF9F4`
class AppColors {
  AppColors._();

  // ── Official Brand Palette ──────────────────────────────────────────────────
  static const Color primaryDeepTeal = Color(0xFF005F73);
  static const Color secondaryTeal = Color(0xFF0A9396);
  static const Color accentWarmYellow = Color(0xFFEE9B00);
  static const Color backgroundWarm = Color(0xFFFFF9F4);

  // Aliases for compatibility
  static const Color primary = primaryDeepTeal;
  static const Color secondary = secondaryTeal;
  static const Color accent = accentWarmYellow;
  static const Color background = backgroundWarm;

  // ── Surfaces & Elevated Layers ──────────────────────────────────────────────
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFAF5EF);
  static const Color borderWarm = Color(0xFFEAE2D8);
  static const Color borderSubtle = Color(0xFFF3ECE4);

  // ── Text & Content (Light Theme) ────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0A252C); // Charcoal Teal
  static const Color textSecondary = Color(0xFF4A6066); // Slate Teal
  static const Color textMuted = Color(0xFF869DA3); // Muted Teal
  static const Color iconColor = Color(0xFF005F73);

  // ── Dark Mode Tokens (Night Travel Editorial) ───────────────────────────────
  static const Color darkBackground = Color(0xFF041014); // Deep Midnight Teal
  static const Color darkSurface = Color(0xFF091C22); // Deep Ocean Surface
  static const Color darkSurfaceElevated = Color(0xFF0E2730);
  static const Color darkBorder = Color(0xFF163742);
  static const Color darkTextPrimary = Color(0xFFF4F8F8);
  static const Color darkTextSecondary = Color(0xFFA1BAC0);
  static const Color darkTextMuted = Color(0xFF6B878F);

  // ── Semantic & Status Indicators ────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorRed = error;
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color success = Color(0xFF1B7A68);
  static const Color successContainer = Color(0xFFD4EDE5);
  static const Color warning = Color(0xFFEE9B00);
  static const Color info = Color(0xFF0A9396);

  // ── AI Micro-moments ────────────────────────────────────────────────────────
  static const Color aiHighlight = Color(0xFFEE9B00);
  static const Color aiPillBackground = Color(0xFFFFF1D6);
  static const Color aiCardBorder = Color(0xFFF7D9A0);
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typography tokens for WeTravel.
///
/// Editorial Serif (`Playfair Display`):
/// Used for major visual display headings, hero banners, and editorial titles.
///
/// Modern Sans-Serif (`Inter`):
/// Used for UI controls, body text, buttons, form fields, navigation, and metadata.
class AppTypography {
  AppTypography._();

  // ── Serif Headings (Playfair Display) ───────────────────────────────────────
  static TextStyle displayLarge({Color color = AppColors.textPrimary}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle displayMedium({Color color = AppColors.textPrimary}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle displaySmall({Color color = AppColors.textPrimary}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: color,
      );

  static TextStyle headlineLarge({Color color = AppColors.textPrimary}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: color,
      );

  // ── Sans-Serif UI & Body (Inter) ────────────────────────────────────────────
  static TextStyle headlineMedium({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  static TextStyle headlineSmall({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  static TextStyle titleLarge({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  static TextStyle titleMedium({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.45,
        color: color,
      );

  static TextStyle titleSmall({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: color,
      );

  static TextStyle bodyLarge({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMedium({Color color = AppColors.textSecondary}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodySmall({Color color = AppColors.textMuted}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color,
      );

  static TextStyle labelLarge({Color color = AppColors.surfaceWhite}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: color,
      );

  static TextStyle labelMedium({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle labelSmall({Color color = AppColors.textSecondary}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: color,
      );

  // ── TextTheme Builders ──────────────────────────────────────────────────────
  static TextTheme createTextTheme({
    required Color primaryColor,
    required Color secondaryColor,
    required Color mutedColor,
  }) {
    return TextTheme(
      displayLarge: displayLarge(color: primaryColor),
      displayMedium: displayMedium(color: primaryColor),
      displaySmall: displaySmall(color: primaryColor),
      headlineLarge: headlineLarge(color: primaryColor),
      headlineMedium: headlineMedium(color: primaryColor),
      headlineSmall: headlineSmall(color: primaryColor),
      titleLarge: titleLarge(color: primaryColor),
      titleMedium: titleMedium(color: primaryColor),
      titleSmall: titleSmall(color: secondaryColor),
      bodyLarge: bodyLarge(color: primaryColor),
      bodyMedium: bodyMedium(color: secondaryColor),
      bodySmall: bodySmall(color: mutedColor),
      labelLarge: labelLarge(color: primaryColor),
      labelMedium: labelMedium(color: secondaryColor),
      labelSmall: labelSmall(color: mutedColor),
    );
  }
}

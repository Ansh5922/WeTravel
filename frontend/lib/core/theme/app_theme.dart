import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Centralized Material 3 Theme Configuration for WeTravel.
///
/// Designed to evoke a modern, premium, editorial travel platform:
/// - Primary Deep Teal (#005F73)
/// - Secondary Teal (#0A9396)
/// - Accent Warm Yellow (#EE9B00)
/// - Warm Cloud Background (#FFF9F4)
class AppTheme {
  AppTheme._();

  // ── Light Theme (Primary Visual Direction) ──────────────────────────────────
  static ThemeData get lightTheme {
    final textTheme = AppTypography.createTextTheme(
      primaryColor: AppColors.textPrimary,
      secondaryColor: AppColors.textSecondary,
      mutedColor: AppColors.textMuted,
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryDeepTeal,
      onPrimary: AppColors.surfaceWhite,
      primaryContainer: Color(0xFFE0F3F5),
      onPrimaryContainer: AppColors.primaryDeepTeal,
      secondary: AppColors.secondaryTeal,
      onSecondary: AppColors.surfaceWhite,
      secondaryContainer: Color(0xFFE2F6F6),
      onSecondaryContainer: Color(0xFF065759),
      tertiary: AppColors.accentWarmYellow,
      onTertiary: AppColors.surfaceWhite,
      tertiaryContainer: AppColors.aiPillBackground,
      onTertiaryContainer: Color(0xFF5C3B00),
      surface: AppColors.surfaceWhite,
      onSurface: AppColors.textPrimary,
      surfaceContainerLowest: AppColors.surfaceWhite,
      surfaceContainerLow: AppColors.surfaceElevated,
      surfaceContainer: AppColors.backgroundWarm,
      surfaceContainerHigh: Color(0xFFF5EFE7),
      surfaceContainerHighest: AppColors.borderWarm,
      error: AppColors.error,
      onError: AppColors.surfaceWhite,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: Color(0xFF410002),
      outline: AppColors.borderWarm,
      outlineVariant: AppColors.borderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundWarm,
      textTheme: textTheme,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundWarm,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.primaryDeepTeal),
        actionsIconTheme: const IconThemeData(color: AppColors.primaryDeepTeal),
        titleTextStyle: AppTypography.displaySmall(color: AppColors.primaryDeepTeal),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.backgroundWarm,
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: const BorderSide(color: AppColors.borderWarm, width: 1),
        ),
      ),

      // ── Elevated / Primary Button ──────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDeepTeal,
          foregroundColor: AppColors.surfaceWhite,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.labelLarge(color: AppColors.surfaceWhite),
        ),
      ),

      // ── Outlined / Secondary Button ────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDeepTeal,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: AppColors.primaryDeepTeal, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.labelLarge(color: AppColors.primaryDeepTeal),
        ),
      ),

      // ── Text Button ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondaryTeal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.roundedMd,
          ),
          textStyle: AppTypography.labelLarge(color: AppColors.secondaryTeal),
        ),
      ),

      // ── Input Fields ───────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: AppTypography.bodyMedium(color: AppColors.textMuted),
        labelStyle: AppTypography.bodyMedium(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.borderWarm, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.borderWarm, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.primaryDeepTeal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      // ── Chips ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundWarm,
        disabledColor: AppColors.borderSubtle,
        selectedColor: const Color(0xFFE2F6F6),
        secondarySelectedColor: AppColors.aiPillBackground,
        labelStyle: AppTypography.labelMedium(color: AppColors.textPrimary),
        secondaryLabelStyle: AppTypography.labelMedium(color: AppColors.primaryDeepTeal),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.borderWarm, width: 1),
        ),
        side: const BorderSide(color: AppColors.borderWarm, width: 1),
        elevation: 0,
        pressElevation: 0,
      ),

      // ── Dividers ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.borderWarm,
        thickness: 1,
        space: 1,
      ),

      // ── Navigation Bar ─────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceWhite,
        indicatorColor: const Color(0xFFE0F3F5),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall(color: AppColors.primaryDeepTeal);
          }
          return AppTypography.labelSmall(color: AppColors.textMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryDeepTeal);
          }
          return const IconThemeData(color: AppColors.textMuted);
        }),
      ),
    );
  }

  // ── Dark Theme (Night Travel Direction) ─────────────────────────────────────
  static ThemeData get darkTheme {
    final textTheme = AppTypography.createTextTheme(
      primaryColor: AppColors.darkTextPrimary,
      secondaryColor: AppColors.darkTextSecondary,
      mutedColor: AppColors.darkTextMuted,
    );

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.secondaryTeal,
      onPrimary: AppColors.darkBackground,
      primaryContainer: Color(0xFF0F3B44),
      onPrimaryContainer: Color(0xFFBBEBED),
      secondary: Color(0xFF22B7BA),
      onSecondary: AppColors.darkBackground,
      secondaryContainer: Color(0xFF0B2B33),
      onSecondaryContainer: Color(0xFFC0F4F5),
      tertiary: AppColors.accentWarmYellow,
      onTertiary: AppColors.darkBackground,
      tertiaryContainer: Color(0xFF472D00),
      onTertiaryContainer: Color(0xFFFFDF9E),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerLowest: AppColors.darkBackground,
      surfaceContainerLow: Color(0xFF06161B),
      surfaceContainer: AppColors.darkSurface,
      surfaceContainerHigh: AppColors.darkSurfaceElevated,
      surfaceContainerHighest: AppColors.darkBorder,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      outline: AppColors.darkBorder,
      outlineVariant: Color(0xFF10272F),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.secondaryTeal),
        actionsIconTheme: const IconThemeData(color: AppColors.secondaryTeal),
        titleTextStyle: AppTypography.displaySmall(color: AppColors.darkTextPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: AppColors.darkBackground,
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),

      // ── Elevated / Primary Button ──────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryTeal,
          foregroundColor: AppColors.darkBackground,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.labelLarge(color: AppColors.darkBackground),
        ),
      ),

      // ── Outlined / Secondary Button ────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondaryTeal,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: const BorderSide(color: AppColors.secondaryTeal, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.labelLarge(color: AppColors.secondaryTeal),
        ),
      ),

      // ── Text Button ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondaryTeal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.roundedMd,
          ),
          textStyle: AppTypography.labelLarge(color: AppColors.secondaryTeal),
        ),
      ),

      // ── Input Fields ───────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: AppTypography.bodyMedium(color: AppColors.darkTextMuted),
        labelStyle: AppTypography.bodyMedium(color: AppColors.darkTextSecondary),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.secondaryTeal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      // ── Chips ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        disabledColor: AppColors.darkBorder,
        selectedColor: const Color(0xFF0F3B44),
        secondarySelectedColor: const Color(0xFF472D00),
        labelStyle: AppTypography.labelMedium(color: AppColors.darkTextPrimary),
        secondaryLabelStyle: AppTypography.labelMedium(color: AppColors.secondaryTeal),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
        elevation: 0,
        pressElevation: 0,
      ),

      // ── Dividers ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),

      // ── Navigation Bar ─────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: const Color(0xFF0F3B44),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall(color: AppColors.secondaryTeal);
          }
          return AppTypography.labelSmall(color: AppColors.darkTextMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.secondaryTeal);
          }
          return const IconThemeData(color: AppColors.darkTextMuted);
        }),
      ),
    );
  }
}

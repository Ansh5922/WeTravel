import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'auth_scenic_decorations.dart';

/// Reusable editorial header for authentication screens (Login / Signup / Forgot Password).
/// Matches the branding and typography tokens established on the Home Screen.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Identity Badge using the official logo
        const WeTravelLogo(
          iconSize: 22,
          fontSize: 18,
        ),

        const SizedBox(height: AppSpacing.lg),

        // Editorial Heading (Playfair Display)
        Text(
          title,
          style: AppTypography.displayMedium(
            color: AppColors.textPrimary,
          ).copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.25,
          ),
        ),

        const SizedBox(height: AppSpacing.xs + 2),

        // Supporting Subtitle (Inter)
        Text(
          subtitle,
          style: AppTypography.bodyMedium(
            color: AppColors.textSecondary,
          ).copyWith(
            fontSize: 14.5,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

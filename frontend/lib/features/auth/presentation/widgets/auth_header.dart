import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Reusable editorial header for authentication screens (Login / Signup).
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
        // Subtle Brand Accent Waypoint Dot
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.accentWarmYellow,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'WeTravel',
              style: AppTypography.labelSmall(
                color: AppColors.primaryDeepTeal,
              ).copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Editorial Heading (Playfair Display)
        Text(
          title,
          style: AppTypography.displayMedium(
            color: AppColors.primaryDeepTeal,
          ).copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: AppSpacing.xs + 2),

        // Supporting Subtitle (Inter)
        Text(
          subtitle,
          style: AppTypography.bodyMedium(
            color: AppColors.textSecondary,
          ).copyWith(
            fontSize: 15,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

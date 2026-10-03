import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Visual for Onboarding Step 3: "More exploring. Less planning."
/// Illustrates an orchestrated trip workspace: live itinerary, smart expense ledger, polls, and memories.
class OnboardingVisualThree extends StatelessWidget {
  const OnboardingVisualThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundWarm,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.borderWarm, width: 1.0),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Main Itinerary Card ─────────────────────────────────────────────
          Positioned(
            top: 14,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.borderWarm, width: 1.2),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDeepTeal.withValues(alpha: 0.08),
                      borderRadius: AppRadius.roundedMd,
                    ),
                    child: const Icon(
                      Icons.schedule_outlined,
                      color: AppColors.primaryDeepTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Day 2 · Bamboo Grove Walk',
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.titleMedium(
                                  color: AppColors.primaryDeepTeal,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '07:30 AM',
                              style: AppTypography.bodySmall(
                                color: AppColors.textSecondary,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Confirmed for all 4 travelers',
                          style: AppTypography.bodySmall(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Floating Smart Ledger Pill ──────────────────────────────────────
          Positioned(
            top: 94,
            left: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: AppRadius.chip,
                border: Border.all(color: AppColors.borderWarm, width: 1.0),
                boxShadow: AppShadows.subtle,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    color: AppColors.secondaryTeal,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ledger · Fair 4-way split',
                    style: AppTypography.labelSmall(
                      color: AppColors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.secondaryTeal,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),

          // ── Floating Live Group Poll Card ───────────────────────────────────
          Positioned(
            bottom: 14,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.borderWarm, width: 1.0),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.accentWarmYellow,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Group Poll Decided',
                        style: AppTypography.labelSmall(
                          color: AppColors.primaryDeepTeal,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Night Train over Bus (4/4 votes)',
                        style: AppTypography.bodySmall(
                          color: AppColors.textSecondary,
                        ).copyWith(fontSize: 10.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

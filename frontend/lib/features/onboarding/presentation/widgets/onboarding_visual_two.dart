import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Visual for Onboarding Step 2: "Your trip. Your way."
/// Represents WeTravel's AI group consensus engine harmonizing constraints into balance.
class OnboardingVisualTwo extends StatelessWidget {
  const OnboardingVisualTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.borderWarm, width: 1.0),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Header & AI Consensus Badge ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                    'AI Group Consensus',
                    style: AppTypography.labelSmall(
                      color: AppColors.primaryDeepTeal,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.aiPillBackground,
                  borderRadius: AppRadius.chip,
                  border: Border.all(color: AppColors.aiCardBorder, width: 0.8),
                ),
                child: Text(
                  '100% Agreement',
                  style: AppTypography.labelSmall(
                    color: const Color(0xFF6B4500),
                  ).copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          // ── Metric 1: Budget Harmony ────────────────────────────────────────
          _ConsensusMetricRow(
            label: 'Budget Harmony',
            valueText: '₹4,500/day avg',
            barColor: AppColors.primaryDeepTeal,
            percentage: 0.82,
          ),

          // ── Metric 2: Pace Equilibrium ──────────────────────────────────────
          _ConsensusMetricRow(
            label: 'Pace Equilibrium',
            valueText: 'Balanced (Morning + free evening)',
            barColor: AppColors.secondaryTeal,
            percentage: 0.70,
          ),

          // ── Metric 3: Harmonized Tags ───────────────────────────────────────
          const Wrap(
            spacing: AppSpacing.sm,
            runSpacing: 4,
            children: [
              _ConsensusTag(label: 'Vegetarian friendly', isWarm: true),
              _ConsensusTag(label: 'AC Transit', isWarm: false),
              _ConsensusTag(label: 'Scenic stays', isWarm: false),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConsensusMetricRow extends StatelessWidget {
  final String label;
  final String valueText;
  final Color barColor;
  final double percentage;

  const _ConsensusMetricRow({
    required this.label,
    required this.valueText,
    required this.barColor,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall(color: AppColors.textPrimary).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                valueText,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall(color: AppColors.textSecondary).copyWith(
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.backgroundWarm,
            borderRadius: AppRadius.roundedPill,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: AppRadius.roundedPill,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConsensusTag extends StatelessWidget {
  final String label;
  final bool isWarm;

  const _ConsensusTag({
    required this.label,
    required this.isWarm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isWarm ? AppColors.aiPillBackground : AppColors.backgroundWarm,
        borderRadius: AppRadius.chip,
        border: Border.all(
          color: isWarm ? AppColors.aiCardBorder : AppColors.borderWarm,
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall(
          color: isWarm ? const Color(0xFF6B4500) : AppColors.textSecondary,
        ).copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

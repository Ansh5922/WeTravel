import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Visual for Onboarding Step 1: "Plan together."
/// Represents multiple travelers' diverse styles converging into one unified journey.
class OnboardingVisualOne extends StatelessWidget {
  const OnboardingVisualOne({super.key});

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
          // ── Background Meridian Lines ───────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _ConvergenceLinePainter(),
            ),
          ),

          // ── Traveler 1: Alex (Adventure) ────────────────────────────────────
          Positioned(
            top: 22,
            left: 20,
            child: _TravelerBubble(
              initials: 'AR',
              label: 'Alex · High Pace',
              sublabel: 'Mountain Treks',
              accentColor: AppColors.primaryDeepTeal,
            ),
          ),

          // ── Traveler 2: Sarah (Chill / Culture) ─────────────────────────────
          Positioned(
            top: 22,
            right: 20,
            child: _TravelerBubble(
              initials: 'SK',
              label: 'Sarah · Relaxed',
              sublabel: 'Art & Sunsets',
              accentColor: AppColors.secondaryTeal,
            ),
          ),

          // ── Traveler 3: Maya (Foodie) ───────────────────────────────────────
          Positioned(
            top: 92,
            left: 36,
            child: _TravelerBubble(
              initials: 'MD',
              label: 'Maya · Foodie',
              sublabel: 'Local Dining',
              accentColor: AppColors.accentWarmYellow,
            ),
          ),

          // ── Central Converged Journey Card ──────────────────────────────────
          Positioned(
            bottom: 22,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.borderWarm, width: 1.2),
                boxShadow: AppShadows.card,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDeepTeal.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.primaryDeepTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Shared Trip · Kyoto 2026',
                        style: AppTypography.titleMedium(
                          color: AppColors.primaryDeepTeal,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.accentWarmYellow,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '3 traveler preferences harmonized',
                            style: AppTypography.bodySmall(
                              color: AppColors.textSecondary,
                            ).copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
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

class _TravelerBubble extends StatelessWidget {
  final String initials;
  final String label;
  final String sublabel;
  final Color accentColor;

  const _TravelerBubble({
    required this.initials,
    required this.label,
    required this.sublabel,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppRadius.roundedPill,
        border: Border.all(color: AppColors.borderWarm, width: 1.0),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: accentColor.withValues(alpha: 0.15),
            child: Text(
              initials,
              style: AppTypography.labelSmall(color: accentColor).copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall(color: AppColors.textPrimary).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
              Text(
                sublabel,
                style: AppTypography.bodySmall(color: AppColors.textMuted).copyWith(
                  fontSize: 9.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConvergenceLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderWarm
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Path 1 (Top Left -> Center Bottom)
    final p1 = Path()
      ..moveTo(size.width * 0.25, 45)
      ..cubicTo(size.width * 0.25, 120, size.width * 0.40, 160, size.width * 0.50, 195);
    canvas.drawPath(p1, paint);

    // Path 2 (Top Right -> Center Bottom)
    final p2 = Path()
      ..moveTo(size.width * 0.75, 45)
      ..cubicTo(size.width * 0.75, 120, size.width * 0.60, 160, size.width * 0.50, 195);
    canvas.drawPath(p2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

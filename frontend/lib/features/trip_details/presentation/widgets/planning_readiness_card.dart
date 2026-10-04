import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card displaying trip dates, member count, Controller role badge,
/// planning readiness percentage bar, and Group Insight AI summary.
class PlanningReadinessCard extends StatelessWidget {
  final String dateRange;
  final int memberCount;
  final double readinessProgress; // 0.0 to 1.0 (e.g. 0.75)
  final String insightTitle;
  final String insightText;
  final VoidCallback? onInsightTap;

  const PlanningReadinessCard({
    super.key,
    this.dateRange = 'Oct 12–15',
    this.memberCount = 4,
    this.readinessProgress = 0.75,
    this.insightTitle = 'Group Insight',
    this.insightText = 'Everyone likes food; early starts are a concern.',
    this.onInsightTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentageText = '${(readinessProgress * 100).toInt()}%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row: Dates / Members & Controller Pill ─────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$dateRange  ·  $memberCount members',
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF004E64),
                ),
              ),
              // Controller Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'C',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Controller',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Planning Readiness Progress ────────────────────────────
          Text(
            'Planning readiness',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF007791),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: readinessProgress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF007791),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                percentageText,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF007791),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Group Insight Banner ───────────────────────────────────
          InkWell(
            onTap: onInsightTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFDEF2F1), // Soft mint / ice blue
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF67B5C6).withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  // Lightbulb Icon in white/teal circle
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Color(0xFF0D9488),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Insight Title & Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insightTitle,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF004E64),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          insightText,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF007791),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chevron
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF004E64),
                    size: 20,
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

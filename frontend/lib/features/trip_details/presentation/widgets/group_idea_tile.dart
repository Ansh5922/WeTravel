import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/trip_suggestion.dart';

/// Interactive list tile for a group suggestion idea (e.g. Sunset cruise, Beach shack dinner).
/// Features a scenic photo thumbnail, title, price, approvals count, comments badge,
/// an interactive thumbs-up upvote button, and circular chevron.
class GroupIdeaTile extends StatelessWidget {
  final TripSuggestion suggestion;
  final VoidCallback? onToggleApproval;
  final VoidCallback? onTap;

  const GroupIdeaTile({
    super.key,
    required this.suggestion,
    this.onToggleApproval,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFF004E64).withValues(alpha: 0.04),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // ── Photo Thumbnail ──────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 62,
                height: 62,
                child: Image.asset(
                  suggestion.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFDEF2F1),
                    child: const Icon(
                      Icons.landscape_rounded,
                      color: Color(0xFF004E64),
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ── Details (Title, Specs, Comments) ──────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    suggestion.title,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF004E64),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '₹${suggestion.estimatedCost}  ·  ${suggestion.approvalsCount}/${suggestion.totalMembers} approvals',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF007791),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 13.5,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${suggestion.commentsCount}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Right Actions (Thumbs Up & Circular Chevron) ──────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thumbs up toggle button
                GestureDetector(
                  onTap: onToggleApproval,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    color: Colors.transparent,
                    child: Icon(
                      Icons.thumb_up_rounded,
                      size: 19,
                      color: suggestion.isApprovedByMe
                          ? const Color(0xFF0284C7)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Circular Chevron
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF67B5C6).withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Color(0xFF007791),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/friend_entity.dart';

/// Reusable card displaying an outgoing friend request with dynamic status badge:
/// - [Pending]: Waiting for the user to accept.
/// - [Accepted]: Request has been accepted and user is now a travel buddy.
/// - [Declined]: Request was declined.
class SentFriendRequestCard extends StatelessWidget {
  final SentFriendRequestEntity request;

  const SentFriendRequestCard({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    final status = request.status.toLowerCase();
    final isAccepted = status == 'accepted';
    final isPending = status == 'pending';

    final Color badgeBg;
    final Color badgeBorder;
    final Color badgeText;
    final IconData badgeIcon;
    final String badgeLabel;
    final String statusNote;

    if (isAccepted) {
      badgeBg = const Color(0xFFDCFCE7);
      badgeBorder = const Color(0xFF86EFAC);
      badgeText = const Color(0xFF166534);
      badgeIcon = Icons.check_circle_rounded;
      badgeLabel = 'Accepted';
      statusNote = 'You are now travel buddies';
    } else if (isPending) {
      badgeBg = const Color(0xFFFEF3C7);
      badgeBorder = const Color(0xFFFDE68A);
      badgeText = const Color(0xFFB45309);
      badgeIcon = Icons.schedule_rounded;
      badgeLabel = 'Pending';
      statusNote = 'Waiting for their response';
    } else {
      badgeBg = const Color(0xFFF1F5F9);
      badgeBorder = const Color(0xFFCBD5E1);
      badgeText = const Color(0xFF475569);
      badgeIcon = Icons.cancel_outlined;
      badgeLabel = 'Declined';
      statusNote = 'Request was declined';
    }

    final initial = request.receiverFullName.trim().isNotEmpty
        ? request.receiverFullName.trim()[0].toUpperCase()
        : 'U';

    final dateStr = request.createdAt != null
        ? DateFormat('MMM d, yyyy').format(request.createdAt!)
        : 'Recently';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Avatar / Fallback ──────────────────────────────────────────
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFDEF2F1),
            backgroundImage: (request.receiverAvatarUrl != null &&
                    request.receiverAvatarUrl!.isNotEmpty &&
                    !request.receiverAvatarUrl!.startsWith('data:'))
                ? NetworkImage(request.receiverAvatarUrl!)
                : null,
            child: (request.receiverAvatarUrl == null || request.receiverAvatarUrl!.isEmpty)
                ? Text(
                    initial,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDeepTeal,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // ── Receiver Info & Sent Date ──────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.receiverFullName,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '@${request.receiverUsername} • Sent $dateStr',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  statusNote,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: badgeText.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Status Pill Badge ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: badgeBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badgeIcon, size: 14, color: badgeText),
                const SizedBox(width: 5),
                Text(
                  badgeLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: badgeText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


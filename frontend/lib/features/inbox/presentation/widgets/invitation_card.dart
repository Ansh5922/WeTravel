import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/trip_invitation.dart';

/// Card widget matching the WeTravel Inbox invitation design.
class InvitationCard extends StatelessWidget {
  final TripInvitation invitation;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const InvitationCard({
    super.key,
    required this.invitation,
    required this.onTap,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left: Destination Image Thumbnail ─────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 92,
                    height: 96,
                    child: Image.asset(
                      invitation.imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(
                          Icons.landscape_rounded,
                          color: Color(0xFF94A3B8),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ── Right: Invitation Details ─────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Title + Status Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              invitation.title,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildStatusBadge(invitation.status),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // 2. Destination Pin
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: Color(0xFF004E64),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            invitation.destination,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // 3. Info Grid (Dates & Budget)
                      Row(
                        children: [
                          // Dates
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color: Color(0xFF0A9396),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    invitation.dateRange,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF475569),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Budget
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.currency_rupee_rounded,
                                  size: 13,
                                  color: Color(0xFF0A9396),
                                ),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    invitation.budgetRange,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF475569),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // 4. Travelers info
                      Row(
                        children: [
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.group_outlined,
                                size: 13,
                                color: Color(0xFF0A9396),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${invitation.travelersCount} travelers',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // 5. Member Avatars & Inviter row + Chevron
                      Row(
                        children: [
                          // Avatars stack
                          _buildAvatarStack(invitation.memberAvatars),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),

                      // 6. Inviter byline
                      const SizedBox(height: 4),
                      Text(
                        'Invited by ${invitation.invitedBy}  •  ${invitation.timeAgo}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(InvitationStatus status) {
    Color bg;
    Color textColor;
    String label;

    switch (status) {
      case InvitationStatus.pending:
        bg = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        label = 'Pending';
        break;
      case InvitationStatus.accepted:
        bg = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        label = 'Accepted';
        break;
      case InvitationStatus.declined:
        bg = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        label = 'Declined';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildAvatarStack(List<String> avatars) {
    final displayAvatars = avatars.take(4).toList();
    final remainingCount = avatars.length - displayAvatars.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < displayAvatars.length; i++)
          Align(
            widthFactor: 0.72,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  displayAvatars[i],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFCBD5E1),
                    child: const Icon(
                      Icons.person,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (remainingCount > 0)
          Align(
            widthFactor: 0.75,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '+$remainingCount',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

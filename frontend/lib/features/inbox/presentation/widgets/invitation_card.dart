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
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left: Destination Image Thumbnail ─────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 78,
                    height: 78,
                    child: (invitation.coverImageUrl != null && invitation.coverImageUrl!.isNotEmpty)
                        ? Image.network(
                            invitation.coverImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholderThumbnail(),
                          )
                        : (invitation.imageAsset.startsWith('http')
                            ? Image.network(
                                invitation.imageAsset,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildPlaceholderThumbnail(),
                              )
                            : Image.asset(
                                invitation.imageAsset,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildPlaceholderThumbnail(),
                              )),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
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

                      // 2. Inviter byline
                      Text(
                        'Invited by ${invitation.invitedBy}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // 3. Compact specs row: Dates & Travelers count
                      Row(
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
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF475569),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.group_outlined,
                            size: 13,
                            color: Color(0xFF0A9396),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${invitation.travelersCount} ${invitation.travelersCount == 1 ? 'traveler' : 'travelers'}',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),

                      // 4. Accept & Decline action buttons
                      if (invitation.status == InvitationStatus.pending &&
                          (onAccept != null || onDecline != null)) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (onAccept != null)
                              Expanded(
                                child: SizedBox(
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: onAccept,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF004E64),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Accept',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (onAccept != null && onDecline != null)
                              const SizedBox(width: 8),
                            if (onDecline != null)
                              Expanded(
                                child: SizedBox(
                                  height: 32,
                                  child: OutlinedButton(
                                    onPressed: onDecline,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF64748B),
                                      side: const BorderSide(
                                        color: Color(0xFFCBD5E1),
                                      ),
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Decline',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
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

  Widget _buildPlaceholderThumbnail() {
    return Container(
      color: const Color(0xFFDEF2F1),
      child: const Center(
        child: Icon(
          Icons.landscape_rounded,
          color: Color(0xFF004E64),
          size: 28,
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
}

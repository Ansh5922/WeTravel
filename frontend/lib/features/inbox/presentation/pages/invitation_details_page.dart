import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../domain/entities/trip_invitation.dart';

/// Full-screen Invitation Details matching the WeTravel design screenshot.
/// Features scenic hero image, organizer controller badge, 2x2 trip specs grid,
/// member list, group preferences AI match badge, and Accept/Decline action buttons.
class InvitationDetailsPage extends StatefulWidget {
  final TripInvitation invitation;
  final ValueChanged<InvitationStatus>? onStatusChanged;

  const InvitationDetailsPage({
    super.key,
    required this.invitation,
    this.onStatusChanged,
  });

  @override
  State<InvitationDetailsPage> createState() => _InvitationDetailsPageState();
}

class _InvitationDetailsPageState extends State<InvitationDetailsPage> {
  late InvitationStatus _status;
  bool _isPreferencesExpanded = true;

  @override
  void initState() {
    super.initState();
    _status = widget.invitation.status;
  }

  void _accept() {
    setState(() {
      _status = InvitationStatus.accepted;
    });
    widget.onStatusChanged?.call(InvitationStatus.accepted);

    context.push(
      RouteNames.invitationSuccess,
      extra: widget.invitation.copyWith(status: InvitationStatus.accepted),
    );
  }

  void _decline() {
    setState(() {
      _status = InvitationStatus.declined;
    });
    widget.onStatusChanged?.call(InvitationStatus.declined);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Declined invitation to "${widget.invitation.title}".',
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF475569),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: const Color(0xFFF59E0B),
          onPressed: () {
            setState(() {
              _status = InvitationStatus.pending;
            });
            widget.onStatusChanged?.call(InvitationStatus.pending);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invitation;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Stack(
        children: [
          // ── Scrollable Body ──────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Image & Header Overlay
                _buildHeroHeader(inv),

                // 2. Main Details Content Sheet
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Organizer Controller Card
                      _buildOrganizerCard(inv),

                      const SizedBox(height: 20),

                      // 2x2 Specs Grid
                      _buildSpecsGrid(inv),

                      const SizedBox(height: 24),

                      // Who's Going Section
                      _buildWhosGoingSection(inv),

                      const SizedBox(height: 20),

                      // Group Preferences Section
                      _buildGroupPreferencesCard(inv),

                      const SizedBox(height: 22),

                      // Trip Expectations Section
                      _buildExpectationsSection(inv),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed Top App Bar ────────────────────────────────────────
          _buildTopAppBar(context),

          // ── Fixed Bottom Actions Bar ─────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomActions(),
          ),
        ],
      ),
    );
  }

  // ── Top Navigation Bar ─────────────────────────────────────────────────────
  Widget _buildTopAppBar(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: topPadding + 6,
          left: 12,
          right: 12,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.55),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            Text(
              'Invitation Details',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                _showOverflowMenu(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero Header ────────────────────────────────────────────────────────────
  Widget _buildHeroHeader(TripInvitation inv) {
    return SizedBox(
      height: 270,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background scenic photo
          Image.asset(
            inv.imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF004E64),
            ),
          ),

          // Gradient overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.25),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.70),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Title & Subtitle at bottom of hero
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        inv.title,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${inv.dateRange}  •  ${inv.tripDuration}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildHeroStatusBadge(_status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatusBadge(InvitationStatus status) {
    Color bg;
    Color textColor;
    String text;

    switch (status) {
      case InvitationStatus.pending:
        bg = const Color(0xFFFDE68A);
        textColor = const Color(0xFF92400E);
        text = 'Pending';
        break;
      case InvitationStatus.accepted:
        bg = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        text = 'Accepted';
        break;
      case InvitationStatus.declined:
        bg = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        text = 'Declined';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  // ── Organizer Card ─────────────────────────────────────────────────────────
  Widget _buildOrganizerCard(TripInvitation inv) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Organizer Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF59E0B), width: 1.8),
            ),
            child: ClipOval(
              child: Image.asset(
                inv.organizerAvatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFCBD5E1),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name and role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inv.invitedBy,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Trip Organizer',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Invited you to join this trip',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF005F73),
                  ),
                ),
              ],
            ),
          ),

          // Controller Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              inv.organizerRole,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD97706),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2x2 Specs Grid ─────────────────────────────────────────────────────────
  Widget _buildSpecsGrid(TripInvitation inv) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSpecCard(
                icon: Icons.location_on_rounded,
                label: 'Destination',
                value: inv.destination,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSpecCard(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Budget',
                value: inv.budgetRange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSpecCard(
                icon: Icons.flight_takeoff_rounded,
                label: 'Trip Type',
                value: inv.tripType,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSpecCard(
                icon: Icons.people_alt_rounded,
                label: 'Members',
                value: '${inv.travelersCount} travelers',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF004E64).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 19,
              color: const Color(0xFF004E64),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Who's Going Section ────────────────────────────────────────────────────
  Widget _buildWhosGoingSection(TripInvitation inv) {
    final displayAvatars = inv.memberAvatars.take(4).toList();
    final remainingCount = inv.memberAvatars.length - displayAvatars.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Who's Going",
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF004E64),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final avatar in displayAvatars)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFCBD5E1),
                        child: const Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ),

            // Plus N circle
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF0A9396),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '+${remainingCount > 0 ? remainingCount : 1}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Group Preferences Card ─────────────────────────────────────────────────
  Widget _buildGroupPreferencesCard(TripInvitation inv) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with toggle
          InkWell(
            onTap: () {
              setState(() {
                _isPreferencesExpanded = !_isPreferencesExpanded;
              });
            },
            child: Row(
              children: [
                Text(
                  'Group Preferences',
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF004E64),
                  ),
                ),
                const Spacer(),
                Icon(
                  _isPreferencesExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF004E64),
                  size: 22,
                ),
              ],
            ),
          ),

          if (_isPreferencesExpanded) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Left Match Badge Box
                Container(
                  width: 78,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF005F73),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.travel_explore_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Match',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF059669),
                        ),
                      ),
                      Text(
                        '${inv.matchPercentage}%',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // 2. Center checklist
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Group (${inv.matchPercentage}%)',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      for (final pref in inv.matchedPreferences)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Color(0xFF10B981),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  pref,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // 3. Right Gear / AI button
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF9F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: Color(0xFF004E64),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Trip Expectations ──────────────────────────────────────────────────────
  Widget _buildExpectationsSection(TripInvitation inv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Expectations',
          style: GoogleFonts.inter(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF004E64),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '“${inv.tripExpectations}”',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF64748B),
            height: 1.45,
          ),
        ),
      ],
    );
  }

  // ── Fixed Bottom Actions ───────────────────────────────────────────────────
  Widget _buildBottomActions() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: bottomPadding > 0 ? bottomPadding : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: _status == InvitationStatus.pending
          ? Row(
              children: [
                // Accept Invitation Button (Primary Golden Amber)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _accept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Accept Invitation',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Decline Button (Outlined)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _decline,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF004E64), width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Decline',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF004E64),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _status == InvitationStatus.accepted
                      ? const Color(0xFF004E64)
                      : const Color(0xFF64748B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _status == InvitationStatus.accepted
                      ? 'Joined! View Trip Details ➔'
                      : 'Invitation Declined',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
    );
  }

  void _showOverflowMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined, color: Color(0xFF004E64)),
              title: Text('Share Invite Link', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invite link copied to clipboard!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem_outlined, color: Colors.red),
              title: Text('Report Trip', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';
import '../../../trips/domain/entities/trip_entity.dart';
import '../../../trips/presentation/bloc/trip_bloc.dart';
import '../../../trips/presentation/bloc/trip_event.dart';
import '../../../trips/presentation/bloc/trip_state.dart';
import '../bloc/inbox_bloc.dart';
import '../bloc/inbox_event.dart';
import '../bloc/inbox_state.dart';
import '../../domain/entities/trip_invitation.dart';

/// Full-screen Invitation Details matching the WeTravel design:
/// - Scenic hero image with gradient overlay & dynamic status badge
/// - Organizer controller card with avatar & role pill
/// - 2x2 trip specs grid (Destination, Budget, Dates/Duration, Members)
/// - "Who's Going" section dynamically displaying real trip participants
/// - Group preferences & AI match score card with expand/collapse toggle
/// - Trip expectations quote
/// - Floating / sticky Accept & Decline actions connected to InboxBloc & TripBloc
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
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _status = widget.invitation.status;

    // Fetch live trip details from TripBloc if tripId is present
    if (widget.invitation.tripId.isNotEmpty) {
      context.read<TripBloc>().add(TripDetailsRequested(widget.invitation.tripId));
    }
  }

  void _accept() {
    if (_isActionInProgress) return;
    setState(() {
      _isActionInProgress = true;
      _status = InvitationStatus.accepted;
    });
    widget.onStatusChanged?.call(InvitationStatus.accepted);

    // Dispatch acceptance to InboxBloc & sync Trips in background
    context.read<InboxBloc>().add(InboxInviteAccepted(widget.invitation.id));
    context.read<TripBloc>().add(const TripsFetchRequested());

    // Navigate to InvitationSuccessPage
    context.push(
      RouteNames.invitationSuccess,
      extra: widget.invitation.copyWith(status: InvitationStatus.accepted),
    );
  }

  void _decline() {
    if (_isActionInProgress) return;
    setState(() {
      _status = InvitationStatus.declined;
    });
    widget.onStatusChanged?.call(InvitationStatus.declined);

    context.read<InboxBloc>().add(InboxInviteDeclined(widget.invitation.id));

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

  void _navigateToWorkspace() {
    context.go(RouteNames.trips);
    context.push(RouteNames.tripDetailsPath(widget.invitation.tripId));
  }

  String _formatTripDates(TripEntity? trip, String fallback) {
    if (trip == null || trip.tripStartDate == null) return fallback;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final s = trip.tripStartDate!;
    final e = trip.tripEndDate;
    if (e == null || s.isAtSameMomentAs(e)) {
      return '${s.day} ${months[s.month - 1]} ${s.year}';
    }
    return '${s.day} ${months[s.month - 1]} – ${e.day} ${months[e.month - 1]}';
  }

  String _formatTripDuration(TripEntity? trip, String fallback) {
    if (trip == null || trip.tripStartDate == null || trip.tripEndDate == null) return fallback;
    final diff = trip.tripEndDate!.difference(trip.tripStartDate!).inDays;
    final nights = diff > 0 ? diff : 1;
    return '${nights + 1} days';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InboxBloc, InboxState>(
      listener: (context, state) {
        if (state is InboxLoadedState && state.isActionLoading == false) {
          setState(() {
            _isActionInProgress = false;
          });
        }
      },
      child: BlocBuilder<TripBloc, TripState>(
        builder: (context, tripState) {
          TripEntity? loadedTrip;
          if (tripState is TripDetailLoadedState && tripState.trip.id == widget.invitation.tripId) {
            loadedTrip = tripState.trip;
          }

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
                      _buildHeroHeader(inv, loadedTrip),

                      // 2. Main Details Content Sheet
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Organizer Controller Card
                            _buildOrganizerCard(inv, loadedTrip),

                            const SizedBox(height: 20),

                            // 2x2 Specs Grid
                            _buildSpecsGrid(inv, loadedTrip),

                            const SizedBox(height: 24),

                            // Who's Going Section (Live Members)
                            _buildWhosGoingSection(inv, loadedTrip),

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
        },
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
              onPressed: () => _showOverflowMenu(context),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero Header ────────────────────────────────────────────────────────────
  Widget _buildHeroHeader(TripInvitation inv, TripEntity? trip) {
    final title = trip?.name.isNotEmpty == true ? trip!.name : inv.title;
    final datesText = _formatTripDates(trip, inv.dateRange);
    final durationText = _formatTripDuration(trip, inv.tripDuration);
    final coverUrl = trip?.coverImageUrl ?? inv.coverImageUrl;

    return SizedBox(
      height: 270,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background scenic photo (Remote URL with asset fallback)
          if (coverUrl != null && coverUrl.isNotEmpty)
            Image.network(
              coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallbackHeroImage(inv.imageAsset),
            )
          else
            _buildFallbackHeroImage(inv.imageAsset),

          // Gradient overlay for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
                stops: const [0.0, 0.40, 1.0],
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
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$datesText  •  $durationText',
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

  Widget _buildFallbackHeroImage(String assetPath) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFF004E64),
        child: const Center(
          child: Icon(Icons.terrain_rounded, size: 48, color: Colors.white54),
        ),
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
  Widget _buildOrganizerCard(TripInvitation inv, TripEntity? trip) {
    final organizerName = inv.invitedBy.isNotEmpty ? inv.invitedBy : 'Trip Organizer';

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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF59E0B), width: 1.8),
            ),
            child: ClipOval(
              child: inv.inviterAvatarUrl != null && inv.inviterAvatarUrl!.isNotEmpty
                  ? Image.network(
                      inv.inviterAvatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildAvatarInitial(organizerName),
                    )
                  : _buildAvatarInitial(organizerName),
            ),
          ),
          const SizedBox(width: 14),

          // Name and role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  organizerName,
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

          // Role Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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

  Widget _buildAvatarInitial(String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'O';
    return Container(
      color: const Color(0xFF005F73),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // ── 2x2 Specs Grid ─────────────────────────────────────────────────────────
  Widget _buildSpecsGrid(TripInvitation inv, TripEntity? trip) {
    final destination = trip?.name ?? inv.destination;
    final membersCount = trip?.members.isNotEmpty == true ? '${trip!.members.length} travelers' : '${inv.travelersCount} travelers';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSpecCard(
                icon: Icons.location_on_rounded,
                label: 'Destination',
                value: destination,
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
                value: membersCount,
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

  // ── Who's Going Section (Real Trip Members) ─────────────────────────────────
  Widget _buildWhosGoingSection(TripInvitation inv, TripEntity? trip) {
    final List<Widget> memberWidgets = [];

    if (trip != null && trip.members.isNotEmpty) {
      final membersToShow = trip.members.take(4).toList();
      for (final m in membersToShow) {
        memberWidgets.add(
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
                child: _buildAvatarInitial(m.fullName.isNotEmpty ? m.fullName : m.username),
              ),
            ),
          ),
        );
      }

      if (trip.members.length > 4) {
        memberWidgets.add(
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
                '+${trip.members.length - 4}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      }
    } else {
      // Fallback display
      for (final avatar in inv.memberAvatars.take(3)) {
        memberWidgets.add(
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  avatar,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildAvatarInitial('U'),
                ),
              ),
            ),
          ),
        );
      }
      memberWidgets.add(
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFF0A9396),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '+1',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Who's Going",
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF005F73),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: memberWidgets),
      ],
    );
  }

  // ── Group Preferences Card (AI Match Score) ────────────────────────────────
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
                  'Group Preferences & Alignment',
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF005F73),
                  ),
                ),
                const Spacer(),
                Icon(
                  _isPreferencesExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF005F73),
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
                  width: 82,
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
                        'AI Match',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF059669),
                        ),
                      ),
                      Text(
                        '${inv.matchPercentage}%',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // 2. Checklist of shared tags
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Group Compatibility (${inv.matchPercentage}%)',
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
            color: const Color(0xFF005F73),
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
                    onPressed: _isActionInProgress ? null : _accept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isActionInProgress
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
                            ),
                          )
                        : Text(
                            'Accept Invitation',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),

                // Decline Button (Outlined)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isActionInProgress ? null : _decline,
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
                onPressed: _status == InvitationStatus.accepted ? _navigateToWorkspace : () => Navigator.pop(context),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _status == InvitationStatus.accepted
                          ? 'Joined! Enter Trip Workspace'
                          : 'Invitation Declined',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (_status == InvitationStatus.accepted) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    ],
                  ],
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
      builder: (bottomSheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const Icon(Icons.share_outlined, color: Color(0xFF004E64)),
                  title: Text('Share Invite Link', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(bottomSheetCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invite link copied to clipboard!')),
                    );
                  },
                ),
              ),
              Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: const Icon(Icons.report_problem_outlined, color: Colors.red),
                  title: Text('Report Trip', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.red)),
                  onTap: () {
                    Navigator.pop(bottomSheetCtx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

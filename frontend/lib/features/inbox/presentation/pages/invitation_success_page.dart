import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';
import '../../../trips/presentation/bloc/trip_bloc.dart';
import '../../../trips/presentation/bloc/trip_event.dart';
import '../../../trips/presentation/widgets/wave_header_clipper.dart';
import '../../domain/entities/trip_invitation.dart';

/// "You're In!" Celebration and Confirmation Screen.
/// Displays when a user accepts a trip invitation:
/// - Hero celebration illustration with big checkmark & wave header
/// - "You're In!" headline and dynamic welcome message
/// - Dynamic trip summary card with real destination, dates, budget, and controller
/// - 4-step "What's Next?" collaboration timeline
/// - Primary CTA: "Enter Trip Workspace ➔" directing the user directly into the joined trip
/// - Secondary CTA: "Personalize Travel Preferences"
class InvitationSuccessPage extends StatelessWidget {
  final TripInvitation invitation;

  const InvitationSuccessPage({
    super.key,
    required this.invitation,
  });

  void _enterTripWorkspace(BuildContext context) {
    // Refresh trips in background and navigate straight to the trip workspace
    context.read<TripBloc>().add(const TripsFetchRequested());
    context.read<TripBloc>().add(TripDetailsRequested(invitation.tripId));

    context.go(RouteNames.trips);
    context.push(RouteNames.tripDetailsPath(invitation.tripId));
  }

  @override
  Widget build(BuildContext context) {
    final title = invitation.title.isNotEmpty ? invitation.title : 'the trip';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Stack(
        children: [
          // ── Scrollable Body ──────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 130),
            child: Column(
              children: [
                // 1. Hero with Checkmark and Wave Clipper
                _buildHeroWithCheckmark(context),

                // 2. Congratulations Headline & Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        "You're In!",
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF004E64),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Welcome to $title',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "You've joined the trip squad.\nYour workspace is ready to collaborate\nwith your fellow travel buddies!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Dynamic Trip Summary Card
                      _buildTripSummaryCard(),

                      const SizedBox(height: 24),

                      // 4. "What's Next?" Timeline
                      _buildWhatsNextTimeline(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed Bottom Actions Bar ─────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomActions(context),
          ),
        ],
      ),
    );
  }

  // ── Hero Header with Big Checkmark Badge ───────────────────────────────────
  Widget _buildHeroWithCheckmark(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final coverUrl = invitation.coverImageUrl;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // 1. Scenic Image clipped with smooth wave at bottom
        ClipPath(
          clipper: WaveHeaderClipper(),
          child: SizedBox(
            height: 230,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (coverUrl != null && coverUrl.isNotEmpty)
                  Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFallbackHeroImage(),
                  )
                else
                  _buildFallbackHeroImage(),

                // Subtle warm sunset gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.transparent,
                        const Color(0xFFF59E0B).withValues(alpha: 0.20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Close Button at Top Right
        Positioned(
          top: topPadding + 10,
          right: 18,
          child: GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.trips);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),

        // 3. Circular Checkmark Badge overlapping the bottom crest
        Positioned(
          bottom: 6,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF005F73),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004E64).withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackHeroImage() {
    return Image.asset(
      invitation.imageAsset,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFF004E64),
      ),
    );
  }

  // ── Trip Summary Card ──────────────────────────────────────────────────────
  Widget _buildTripSummaryCard() {
    final coverUrl = invitation.coverImageUrl;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: thumbnail + title + date + location
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: coverUrl != null && coverUrl.isNotEmpty
                        ? Image.network(
                            coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildFallbackHeroImage(),
                          )
                        : _buildFallbackHeroImage(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.title,
                        style: GoogleFonts.inter(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${invitation.dateRange}  •  ${invitation.tripDuration}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: Color(0xFF004E64),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              invitation.destination,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Bottom specs: Members, Budget, Controller
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Members
                Row(
                  children: [
                    const Icon(
                      Icons.group_outlined,
                      size: 16,
                      color: Color(0xFF004E64),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${invitation.travelersCount}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Members',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // 2. Budget
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: Color(0xFF004E64),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invitation.budgetRange,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Budget',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // 3. Organizer / Controller
                Row(
                  children: [
                    const Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 16,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invitation.invitedBy.isNotEmpty ? invitation.invitedBy : 'Organizer',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          invitation.organizerRole,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── "What's Next?" Timeline ────────────────────────────────────────────────
  Widget _buildWhatsNextTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: Color(0xFF004E64),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "What's Next?",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF004E64),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        _buildTimelineStep(
          stepNumber: '1',
          title: 'Review Trip Workspace',
          subtitle: 'Explore the drafted destination, schedule, and team members.',
          isFirst: true,
        ),
        _buildTimelineStep(
          stepNumber: '2',
          title: 'Vote on Itinerary & Polls',
          subtitle: 'Cast your votes on dates, stays, dining, and daily spots.',
        ),
        _buildTimelineStep(
          stepNumber: '3',
          title: 'Group Chat Collaboration',
          subtitle: 'Coordinate real-time decisions directly with your travel squad.',
        ),
        _buildTimelineStep(
          stepNumber: '4',
          title: 'Track Shared Expenses',
          subtitle: 'Log payments and settle bills transparently with equal splits.',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String stepNumber,
    required String title,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step pill + connecting line
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isFirst ? const Color(0xFF004E64) : const Color(0xFFE8F3F5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFirst ? const Color(0xFF004E64) : const Color(0xFF0A9396),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isFirst ? Colors.white : const Color(0xFF004E64),
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Step content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Fixed Bottom Actions ───────────────────────────────────────────────────
  Widget _buildBottomActions(BuildContext context) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary Button: "Enter Trip Workspace ➔"
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _enterTripWorkspace(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter Trip Workspace',
                    style: GoogleFonts.inter(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF0F172A),
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Secondary Button: "Set My Preferences"
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                context.push(RouteNames.preferences);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF004E64), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Personalize Travel Preferences',
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF004E64),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

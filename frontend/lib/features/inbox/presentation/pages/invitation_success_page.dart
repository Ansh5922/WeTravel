import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../trips/presentation/widgets/wave_header_clipper.dart';
import '../../domain/entities/trip_invitation.dart';

/// "You're In!" Celebration and Onboarding Screen.
/// Displays when a user accepts a trip invitation, showing:
/// - Hero celebration illustration with big checkmark
/// - "You're In!" headline and warm welcome
/// - Trip summary card with dates, destination, budget, and controller
/// - 4-step "What's Next?" collaboration timeline
/// - "Set My Preferences" primary CTA & "Go to Trip Dashboard" secondary CTA
class InvitationSuccessPage extends StatelessWidget {
  final TripInvitation invitation;

  const InvitationSuccessPage({
    super.key,
    required this.invitation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Stack(
        children: [
          // ── Scrollable Body ──────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
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
                        'Welcome to ${invitation.title}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "You've successfully joined the trip.\nGet ready for an amazing journey\nwith your friends!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. Trip Summary Card
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
                Image.asset(
                  invitation.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF004E64),
                  ),
                ),
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
              // Return back to shell or inbox
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.home);
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

  // ── Trip Summary Card ──────────────────────────────────────────────────────
  Widget _buildTripSummaryCard() {
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
                    child: Image.asset(
                      invitation.imageAsset,
                      fit: BoxFit.cover,
                    ),
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
                    Text(
                      invitation.budgetRange,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),

                // 3. Controller
                Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: Image.asset(
                          invitation.organizerAvatar,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invitation.organizerRole,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                        Text(
                          invitation.invitedBy,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
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
    final steps = [
      (
        '1',
        'Set your preferences',
        'Tell us what you like and need',
      ),
      (
        '2',
        'AI analyzes group choices',
        "We'll find the best options for everyone",
      ),
      (
        '3',
        'Generate travel plans',
        'Multiple options to choose from',
      ),
      (
        '4',
        'Vote & finalize itinerary',
        'Decide together as a group',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "What's Next?",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF004E64),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Timeline items
        for (int i = 0; i < steps.length; i++)
          _buildTimelineStep(
            number: steps[i].$1,
            title: steps[i].$2,
            subtitle: steps[i].$3,
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String number,
    required String title,
    required String subtitle,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step circle and vertical connector line
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF004E64),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFF004E64),
                    margin: const EdgeInsets.symmetric(vertical: 3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Step Title & Subtitle
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
          // Primary Button: "Set My Preferences"
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                context.push(RouteNames.preferences);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Set My Preferences',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Secondary Button: "Go to Trip Dashboard"
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                context.push(RouteNames.tripDetailsPath(invitation.tripId));
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF004E64), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Go to Trip Dashboard',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
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

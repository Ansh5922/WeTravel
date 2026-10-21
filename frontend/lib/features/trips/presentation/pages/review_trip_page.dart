import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_names.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';
import '../../domain/entities/trip_member.dart';
import '../../domain/entities/trip_review_draft.dart';
import '../widgets/invite_screen_decorations.dart';
import '../widgets/trip_category_icons.dart';

/// Review Trip screen matching the warm cream & deep teal aesthetic of the app:
/// - Curved deep-teal header with golden accent swoosh
/// - Elegant white trip overview card with dynamic details:
///   Destination, Dates, Duration, Budget, Trip Style, Selected Buddies & Channels
/// - Primary golden CTA "Create Trip ➔" triggering TripCreateRequested and automated invites
/// - Secondary outlined button "Edit Details"
/// - Bottom tropical leaves and dotted trail decorations
class ReviewTripPage extends StatefulWidget {
  final TripReviewDraft? draft;

  const ReviewTripPage({
    super.key,
    this.draft,
  });

  @override
  State<ReviewTripPage> createState() => _ReviewTripPageState();
}

class _ReviewTripPageState extends State<ReviewTripPage> {
  late final TripReviewDraft _draft;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ?? TripReviewDraft.initial();
  }

  void _onCreateTrip() {
    FocusScope.of(context).unfocus();
    if (_isCreating) return;

    if (_draft.destination.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Destination cannot be empty.'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    context.read<TripBloc>().add(
          TripCreateRequested(
            name: _draft.destination,
            tripStartDate: _draft.startDate,
            tripEndDate: _draft.endDate,
            coverImageUrl: _draft.coverImageUrl,
          ),
        );
  }

  void _handleTripCreated(BuildContext context, TripCreatedState state) {
    setState(() {
      _isCreating = false;
    });

    final createdTrip = state.trip;
    final tripId = createdTrip.id;

    // Send invitations dynamically to backend through BLoC for all selected friends
    for (final member in _draft.selectedMembers) {
      if (member.id.isNotEmpty && !member.id.startsWith('mock-')) {
        context.read<TripBloc>().add(
              TripInviteMemberRequested(
                tripId: tripId,
                type: 'friend',
                friendId: member.id,
              ),
            );
      }
    }

    // Send invitations dynamically for invited emails
    for (final email in _draft.invitedEmails) {
      if (email.isNotEmpty) {
        context.read<TripBloc>().add(
              TripInviteMemberRequested(
                tripId: tripId,
                type: 'email',
                email: email,
              ),
            );
      }
    }

    // Send invitations dynamically for invited phones
    for (final phone in _draft.invitedPhones) {
      if (phone.isNotEmpty) {
        context.read<TripBloc>().add(
              TripInviteMemberRequested(
                tripId: tripId,
                type: 'phone',
                phone: phone,
              ),
            );
      }
    }

    // Refresh trips list so Trips tab has the latest data
    context.read<TripBloc>().add(const TripsFetchRequested());

    // Schedule navigation and confirmation safely post-frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      final totalInvited = _draft.selectedMembers.length +
          _draft.invitedEmails.length +
          _draft.invitedPhones.length;

      final message = totalInvited > 0
          ? 'Trip "${createdTrip.name}" created! $totalInvited buddies invited.'
          : 'Trip "${createdTrip.name}" created successfully!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF004E64),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );

      // Pop wizard modals back to the main app, switch to Trips tab, and open the new trip
      context.go(RouteNames.trips);
      if (tripId.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final navContext = rootNavigatorKey.currentContext;
          if (navContext != null && navContext.mounted) {
            GoRouter.of(navContext).push(RouteNames.tripDetailsPath(tripId));
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        if (state is TripCreatedState) {
          _handleTripCreated(context, state);
        } else if (state is TripErrorState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            setState(() {
              _isCreating = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        body: RepaintBoundary(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // ── Top Teal Curved Header with Golden Accent ─────────────────
              CustomPaint(
                painter: InviteHeaderPainter(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: statusBarHeight + 10,
                    left: 16,
                    right: 16,
                    bottom: 42,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 14),

                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Review Trip',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Confirm your trip details before creating.',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.90),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Main Review Content Area ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Step Indicator Pill: "03 Review Trip" ────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F3F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFBCE3E8),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF004E64),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '03',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Review Trip',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF004E64),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Trip Overview Card ──────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF000000).withValues(alpha: 0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Destination Block
                          _buildDetailRow(
                            iconBgColor: const Color(0xFFFEF3C7),
                            icon: const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            label: 'DESTINATION',
                            value: _draft.destination.isNotEmpty
                                ? _draft.destination
                                : 'Not specified',
                            isProminent: true,
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(color: Color(0xFFF1F5F9), height: 1),
                          ),

                          // Dates Block
                          _buildDetailRow(
                            iconBgColor: const Color(0xFFE0F2FE),
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                              color: Color(0xFF0284C7),
                              size: 19,
                            ),
                            label: 'DATES',
                            value: _draft.formattedDates,
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(color: Color(0xFFF1F5F9), height: 1),
                          ),

                          // Duration Block
                          _buildDetailRow(
                            iconBgColor: const Color(0xFFF3E8FF),
                            icon: const Icon(
                              Icons.schedule_rounded,
                              color: Color(0xFF9333EA),
                              size: 19,
                            ),
                            label: 'DURATION',
                            value: _draft.formattedDuration,
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(color: Color(0xFFF1F5F9), height: 1),
                          ),

                          // Budget Block
                          _buildDetailRow(
                            iconBgColor: const Color(0xFFDCFCE7),
                            icon: const Icon(
                              Icons.currency_rupee_rounded,
                              color: Color(0xFF16A34A),
                              size: 19,
                            ),
                            label: 'BUDGET',
                            value: '${_draft.budget} (per person)',
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(color: Color(0xFFF1F5F9), height: 1),
                          ),

                          // Trip Style Block
                          _buildDetailRow(
                            iconBgColor: const Color(0xFFFFF7ED),
                            icon: _buildCategoryIcon(),
                            label: 'TRIP STYLE',
                            value: _draft.tripStyle,
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(color: Color(0xFFF1F5F9), height: 1),
                          ),

                          // Invited Travel Buddies & Channels Block
                          _buildMembersSection(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ── "Edit Details" Button (Secondary Outlined) ───────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _isCreating ? null : () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFF004E64),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Color(0xFF004E64),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Edit Details',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF004E64),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── "Create Trip" Button (Primary CTA) ───────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _onCreateTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isCreating
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF0F172A),
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Create Trip',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 19,
                                    color: Color(0xFF0F172A),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    // ── Bottom Decorative Leaves and Dotted Trail ─────────────
                    const InviteBottomDecorator(),

                    const SizedBox(height: 16),
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

  Widget _buildDetailRow({
    required Color iconBgColor,
    required Widget icon,
    required String label,
    required String value,
    bool isProminent = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: icon),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: isProminent ? 18 : 15,
                  fontWeight: isProminent ? FontWeight.w700 : FontWeight.w600,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryIcon() {
    final style = _draft.tripStyle.toLowerCase();
    if (style.contains('adventure') || style.contains('trek')) {
      return const AdventureMountainIcon(
        color: Color(0xFFEA580C),
        size: 20,
      );
    } else if (style.contains('food') || style.contains('dining')) {
      return const DiningForkKnifeIcon(
        color: Color(0xFFEA580C),
        size: 20,
      );
    } else if (style.contains('cultural') || style.contains('heritage')) {
      return const TempleIcon(
        color: Color(0xFFEA580C),
        size: 20,
      );
    }
    return const PalmTreeIcon(
      color: Color(0xFFEA580C),
      size: 20,
    );
  }

  Widget _buildMembersSection() {
    final members = _draft.selectedMembers;
    final emails = _draft.invitedEmails;
    final phones = _draft.invitedPhones;

    final totalInvites = members.length + emails.length + phones.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.group_rounded,
            color: Color(0xFF475569),
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MEMBERS & INVITES',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              if (totalInvites == 0)
                Text(
                  'Solo Trip (You are the admin)',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (members.isNotEmpty)
                      Row(
                        children: [
                          for (int i = 0; i < members.length && i < 3; i++)
                            Transform.translate(
                              offset: Offset(-8.0 * i, 0),
                              child: _buildAvatarOverlap(members[i]),
                            ),
                          if (members.length > 3)
                            Transform.translate(
                              offset: const Offset(-24, 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  '+${members.length - 3} buddies',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: EdgeInsets.only(left: members.length > 1 ? 4 : 8),
                              child: Text(
                                '${members.length} friend${members.length > 1 ? 's' : ''} selected',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                        ],
                      ),
                    if (emails.isNotEmpty || phones.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (emails.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${emails.length} email invite${emails.length > 1 ? 's' : ''}',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0284C7),
                                ),
                              ),
                            ),
                          if (phones.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${phones.length} WhatsApp invite${phones.length > 1 ? 's' : ''}',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF16A34A),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarOverlap(TripMember member) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
            ? Image.network(
                member.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallbackInitial(member.name),
              )
            : _buildFallbackInitial(member.name),
      ),
    );
  }

  Widget _buildFallbackInitial(String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
    return Container(
      color: const Color(0xFF004E64),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

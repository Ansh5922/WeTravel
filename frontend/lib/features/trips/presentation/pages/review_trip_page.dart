import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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

    // Schedule navigation post-frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      // Navigate to Invite Members with the newly created real TripEntity
      context.pushReplacement(
        RouteNames.inviteMembers,
        extra: createdTrip,
      );
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
            physics: const BouncingScrollPhysics(),
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
                      bottom: 38,
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
                                  color: Colors.white.withValues(alpha: 0.92),
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
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                          padding: EdgeInsets.symmetric(vertical: 8),
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
                          padding: EdgeInsets.symmetric(vertical: 8),
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
                          padding: EdgeInsets.symmetric(vertical: 8),
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
                          padding: EdgeInsets.symmetric(vertical: 8),
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
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Color(0xFFF1F5F9), height: 1),
                        ),

                        // Invited Travel Buddies & Channels Block
                        _buildMembersSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, -3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Edit button: shows only "Edit" with compact width
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: _isCreating ? null : () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                      color: Color(0xFF004E64),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 17,
                        color: Color(0xFF004E64),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Edit',
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF004E64),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Create Trip button: covers all remaining space
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _onCreateTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Color(0xFF0F172A),
                              ),
                            ],
                          ),
                  ),
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

              // Admin Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF005F73).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF005F73).withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined, size: 13, color: Color(0xFF005F73)),
                    const SizedBox(width: 4),
                    Text(
                      'You (Admin)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF005F73),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Dynamic pending requests for friends
              if (members.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.hourglass_top_rounded,
                        size: 13,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Request pending for ${members.length} friend${members.length > 1 ? 's' : ''}',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (int i = 0; i < members.length && i < 4; i++)
                      Transform.translate(
                        offset: Offset(-8.0 * i, 0),
                        child: _buildAvatarOverlap(members[i]),
                      ),
                    if (members.length > 4)
                      Transform.translate(
                        offset: const Offset(-28, 0),
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
                            '+${members.length - 4} more',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ] else if (emails.isEmpty && phones.isEmpty) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.person_add_alt_1_outlined,
                      size: 15,
                      color: Color(0xFF005F73),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Invite buddies & share link right after creation',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF005F73),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Pending channels invites (email / whatsapp)
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
                          '${emails.length} email invite${emails.length > 1 ? 's' : ''} pending',
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
                          '${phones.length} WhatsApp invite${phones.length > 1 ? 's' : ''} pending',
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

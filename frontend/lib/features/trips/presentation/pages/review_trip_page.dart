import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';
import '../../domain/entities/trip_member.dart';
import '../../domain/entities/trip_review_draft.dart';
import '../widgets/invite_screen_decorations.dart';
import '../widgets/trip_category_icons.dart';

/// Review Trip screen matching the warm cream & deep teal aesthetic of the app:
/// - Curved deep-teal header with golden accent swoosh
/// - Elegant white trip overview card with all details (Destination, Dates, Duration, Budget, Trip Style, Members)
/// - Primary golden CTA "Create Trip ➔"
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
    _draft = widget.draft ?? TripReviewDraft.mockDefault();
  }

  Future<void> _onCreateTrip() async {
    if (_isCreating) return;

    setState(() {
      _isCreating = true;
    });

    // Realistic frontend creation simulation
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Trip to ${_draft.destination} created successfully!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF004E64),
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate to Trip Details screen
    context.go(RouteNames.tripDetailsPath('goa-getaway'));
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Teal Curved Header with Golden Accent ───────────────────
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
                    Column(
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
                  ],
                ),
              ),
            ),

            // ── Main Review Content Area ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
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
                          value: _draft.destination,
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

                        // Invited Travel Buddies Block
                        _buildMembersSection(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

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

                  const SizedBox(height: 14),

                  // ── "Edit Details" Button (Secondary Outlined) ───────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
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

                  // ── Bottom Decorative Leaves and Dotted Trail ─────────────
                  const InviteBottomDecorator(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
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
    if (style.contains('adventure')) {
      return const AdventureMountainIcon(
        color: Color(0xFFEA580C),
        size: 20,
      );
    } else if (style.contains('food')) {
      return const DiningForkKnifeIcon(
        color: Color(0xFFEA580C),
        size: 20,
      );
    } else if (style.contains('cultural')) {
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
    final members = _draft.selectedMembers.isNotEmpty
        ? _draft.selectedMembers
        : TripMember.initialSuggestedFriends.where((f) => f.isSelected).toList();

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
                'MEMBERS',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              if (members.isEmpty)
                Text(
                  'Solo Trip (No buddies invited yet)',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                )
              else
                Row(
                  children: [
                    for (int i = 0; i < members.length && i < 2; i++)
                      Transform.translate(
                        offset: Offset(-8.0 * i, 0),
                        child: _buildAvatarOverlap(
                          members[i].avatarAsset,
                          members[i].name,
                        ),
                      ),
                    if (members.length > 2)
                      Transform.translate(
                        offset: const Offset(-16, 0),
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
                            '+${members.length - 2} buddies',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      )
                    else if (members.length == 1)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          members.first.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          '2 buddies',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarOverlap(String assetPath, String fallbackInitial) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFF004E64),
            child: Center(
              child: Text(
                fallbackInitial[0],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

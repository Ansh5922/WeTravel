import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';
import '../../domain/entities/trip_member.dart';
import '../../domain/entities/trip_review_draft.dart';
import '../widgets/invite_screen_decorations.dart';

/// Invite Members screen matching the design screenshot:
/// - Curved deep teal header with golden accent swoosh
/// - Search bar for buddies
/// - Suggested friends list with interactive checkmarks and "Select all" toggle
/// - Share invitation link card with copy-to-clipboard action
/// - "Next ➔" action button navigating to the Review Trip screen
/// - Bottom tropical leaves and map trail decorations
class InviteMembersPage extends StatefulWidget {
  final TripReviewDraft? draft;

  const InviteMembersPage({
    super.key,
    this.draft,
  });

  @override
  State<InviteMembersPage> createState() => _InviteMembersPageState();
}

class _InviteMembersPageState extends State<InviteMembersPage> {
  final TextEditingController _searchController = TextEditingController();
  late List<TripMember> _friends;
  late final TripReviewDraft _draft;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _friends = TripMember.initialSuggestedFriends;
    _draft = widget.draft ?? TripReviewDraft.mockDefault();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TripMember> get _filteredFriends {
    if (_searchQuery.trim().isEmpty) return _friends;
    final q = _searchQuery.toLowerCase();
    return _friends
        .where((f) =>
            f.name.toLowerCase().contains(q) ||
            f.email.toLowerCase().contains(q))
        .toList();
  }

  bool get _isAllSelected =>
      _friends.isNotEmpty && _friends.every((f) => f.isSelected);

  void _toggleSelectAll() {
    final nextState = !_isAllSelected;
    setState(() {
      for (final f in _friends) {
        f.isSelected = nextState;
      }
    });
  }

  void _toggleMember(String id) {
    setState(() {
      final index = _friends.indexWhere((f) => f.id == id);
      if (index != -1) {
        _friends[index].isSelected = !_friends[index].isSelected;
      }
    });
  }

  void _copyInviteLink() {
    const inviteUrl = 'https://wetravel.app/invite/7h3k9x2';
    Clipboard.setData(const ClipboardData(text: inviteUrl));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Invite link copied to clipboard!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D9488),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onNext() {
    final selectedMembers = _friends.where((f) => f.isSelected).toList();
    final updatedDraft = _draft.copyWith(
      selectedMembers: selectedMembers,
    );
    // Navigate to Review Trip screen passing the draft
    context.push(RouteNames.reviewTrip, extra: updatedDraft);
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final friendsToShow = _filteredFriends;

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
                          'Invite Members',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Add your travel buddies to plan together.',
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

            // ── Main Content Area ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),

                  // ── Search Field ─────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF005F73),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              color: const Color(0xFF1E293B),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search name and email',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF94A3B8),
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Section Header: Suggested friends & Select all ─────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Suggested friends',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF005F73),
                          letterSpacing: -0.2,
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleSelectAll,
                        child: Text(
                          _isAllSelected ? 'Deselect all' : 'Select all',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF005F73),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Suggested Friends List Card ───────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: List.generate(friendsToShow.length, (index) {
                        final friend = friendsToShow[index];
                        final isLast = index == friendsToShow.length - 1;

                        return Column(
                          children: [
                            InkWell(
                              onTap: () => _toggleMember(friend.id),
                              borderRadius: BorderRadius.vertical(
                                top: index == 0
                                    ? const Radius.circular(16)
                                    : Radius.zero,
                                bottom: isLast
                                    ? const Radius.circular(16)
                                    : Radius.zero,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: const Color(0xFFE2E8F0),
                                      backgroundImage:
                                          AssetImage(friend.avatarAsset),
                                    ),
                                    const SizedBox(width: 14),

                                    // Name & Email
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            friend.name,
                                            style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF005F73),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            friend.email,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Custom Rounded Checkbox
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: friend.isSelected
                                            ? const Color(0xFF005F73)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: friend.isSelected
                                              ? const Color(0xFF005F73)
                                              : const Color(0xFFCBD5E1),
                                          width: 1.6,
                                        ),
                                      ),
                                      child: friend.isSelected
                                          ? const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!isLast)
                              const Divider(
                                height: 1,
                                thickness: 0.8,
                                color: Color(0xFFF1F5F9),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Share Invitation Link Card ───────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7).withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFDE68A),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const OrigamiAirplaneIcon(size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Share invitation link',
                                    style: GoogleFonts.inter(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF92400E),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Let others join using this link',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _copyInviteLink,
                              icon: const Icon(
                                Icons.share_rounded,
                                color: Color(0xFF005F73),
                                size: 21,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Link Container with Copy Button
                        GestureDetector(
                          onTap: _copyInviteLink,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFCD34D),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'https://wetravel.app/invite/7h3k...',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF005F73),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.copy_rounded,
                                  color: Color(0xFFF59E0B),
                                  size: 19,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ── "Next ➔" Button ──────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next',
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

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

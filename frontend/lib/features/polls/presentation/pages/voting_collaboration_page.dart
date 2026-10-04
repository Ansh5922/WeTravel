import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../trips/presentation/widgets/invite_screen_decorations.dart';

/// "Voting & Collaboration" screen matching the WeTravel design screenshot.
/// Features:
/// - Group Vote header & filter tabs: "Open (5)", "Voted (2)", "Comments (3)"
/// - Live Poll widget: "Which beach do you prefer?" with animated vote percentage bars and avatars
/// - Activity suggestion card: Dudhsagar Waterfalls with reactions and "Vote" action
/// - Bottom interactive comment bar with send button
class VotingCollaborationPage extends StatefulWidget {
  final String tripId;

  const VotingCollaborationPage({
    super.key,
    required this.tripId,
  });

  @override
  State<VotingCollaborationPage> createState() => _VotingCollaborationPageState();
}

class _VotingCollaborationPageState extends State<VotingCollaborationPage> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = const ['Open (5)', 'Voted (2)', 'Comments (3)'];

  // Poll state
  int _calanguteVotes = 9;
  int _bagaVotes = 7;
  int _anjunaVotes = 4;
  String? _userVotedOption;

  // Waterfall activity vote
  int _activityLikes = 8;
  bool _hasLikedActivity = false;

  final TextEditingController _commentController = TextEditingController();

  int get _totalPollVotes => _calanguteVotes + _bagaVotes + _anjunaVotes;

  void _voteBeach(String option) {
    if (_userVotedOption != null) return;
    setState(() {
      _userVotedOption = option;
      if (option == 'Calangute') _calanguteVotes++;
      if (option == 'Baga') _bagaVotes++;
      if (option == 'Anjuna') _anjunaVotes++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voted for $option Beach!'),
        backgroundColor: const Color(0xFF004E64),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final calangutePercent = (_calanguteVotes / _totalPollVotes * 100).round();
    final bagaPercent = (_bagaVotes / _totalPollVotes * 100).round();
    final anjunaPercent = (100 - calangutePercent - bagaPercent).clamp(0, 100);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Stack(
        children: [
          // ── Scrollable Body ──────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: topPadding + 68,
              bottom: bottomPadding + 80,
              left: 18,
              right: 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── 1. Group Vote Header ──────────────────────────────
                Text(
                  'Group Vote',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF004E64),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Help us decide on the best activities and places.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF007791),
                  ),
                ),
                const SizedBox(height: 16),

                // ── 2. Filter Pills ────────────────────────────────────
                Row(
                  children: List.generate(_tabs.length, (index) {
                    final isSelected = _selectedTabIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF004E64) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF004E64) : const Color(0xFFCBD5E1),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            _tabs[index],
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF004E64),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 18),

                // ── 3. Active Poll Card ────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Which beach do you prefer?',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF004E64),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tag: Poll • Ends in 2 days
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFDEF2F1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.poll_rounded,
                              color: Color(0xFF004E64),
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Poll',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF004E64),
                            ),
                          ),
                          Text(
                            ' • Ends in 2 days',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Option 1: Calangute Beach
                      _buildVoteBarItem(
                        title: 'Calangute Beach',
                        percent: calangutePercent,
                        votes: _calanguteVotes,
                        isSelected: _userVotedOption == 'Calangute',
                        onTap: () => _voteBeach('Calangute'),
                      ),
                      const SizedBox(height: 14),

                      // Option 2: Baga Beach
                      _buildVoteBarItem(
                        title: 'Baga Beach',
                        percent: bagaPercent,
                        votes: _bagaVotes,
                        isSelected: _userVotedOption == 'Baga',
                        onTap: () => _voteBeach('Baga'),
                      ),
                      const SizedBox(height: 14),

                      // Option 3: Anjuna Beach
                      _buildVoteBarItem(
                        title: 'Anjuna Beach',
                        percent: anjunaPercent,
                        votes: _anjunaVotes,
                        isSelected: _userVotedOption == 'Anjuna',
                        onTap: () => _voteBeach('Anjuna'),
                      ),
                      const SizedBox(height: 18),

                      // Avatars and Total Votes count
                      Row(
                        children: [
                          SizedBox(
                            width: 72,
                            height: 26,
                            child: Stack(
                              children: [
                                _buildAvatarCircle(0, 'A', const Color(0xFF004E64)),
                                _buildAvatarCircle(16, 'R', const Color(0xFF007791)),
                                _buildAvatarCircle(32, 'S', const Color(0xFFF59E0B)),
                                Positioned(
                                  left: 48,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDEF2F1),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '+2',
                                        style: GoogleFonts.inter(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF004E64),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$_totalPollVotes votes',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── 4. Activity Suggestion Card ───────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFFDEF2F1),
                            child: Text(
                              'A',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF004E64),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add this activity?',
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF004E64),
                                ),
                              ),
                              Text(
                                'Suggestion by Ananya • 1 day ago',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Image & Details snippet
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 80,
                              height: 60,
                              child: Image.asset(
                                'assets/images/waterfall.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: const Color(0xFFDEF2F1),
                                  child: const Icon(Icons.terrain, color: Color(0xFF004E64)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dudhsagar Waterfalls',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF004E64),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '₹1,500 per person • 4h',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF007791),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Reactions & Vote CTA
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _hasLikedActivity = !_hasLikedActivity;
                                _activityLikes += _hasLikedActivity ? 1 : -1;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  _hasLikedActivity ? Icons.favorite : Icons.favorite_border,
                                  size: 18,
                                  color: _hasLikedActivity ? const Color(0xFFEF4444) : const Color(0xFF004E64),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$_activityLikes',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF004E64),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 16,
                                color: Color(0xFF007791),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '3',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF007791),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Voted to include Dudhsagar Waterfalls!'),
                                  backgroundColor: Color(0xFF004E64),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF004E64),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Vote',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
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

          // ── Fixed Top Header ─────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, topPadding + 60),
                  painter: InviteHeaderPainter(),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: topPadding + 4,
                    left: 10,
                    right: 12,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Voting & Collaboration',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed Bottom Comment Bar ─────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 10,
                bottom: bottomPadding > 0 ? bottomPadding : 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.sentiment_satisfied_alt_rounded,
                            color: Color(0xFF007791),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  color: const Color(0xFF94A3B8),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (_commentController.text.trim().isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Comment posted!'),
                            backgroundColor: Color(0xFF004E64),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        _commentController.clear();
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF004E64),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
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

  Widget _buildVoteBarItem({
    required String title,
    required int percent,
    required int votes,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF004E64) : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                      color: isSelected ? const Color(0xFF004E64) : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(Icons.circle, size: 6, color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: const Color(0xFF004E64),
                    ),
                  ),
                ],
              ),
              Text(
                '$percent% ($votes)',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF004E64),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 7,
              child: LinearProgressIndicator(
                value: percent / 100,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isSelected ? const Color(0xFF004E64) : const Color(0xFF007791),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCircle(double left, String initial, Color bg) {
    return Positioned(
      left: left,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Center(
          child: Text(
            initial,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../trips/presentation/widgets/invite_screen_decorations.dart';

/// Model representing a poll option with image, votes, and selection state.
class PollOption {
  final String id;
  final String label;
  final String imageUrl;
  final int votes;
  final bool isSelected;

  const PollOption({
    required this.id,
    required this.label,
    required this.imageUrl,
    this.votes = 0,
    this.isSelected = false,
  });

  PollOption copyWith({
    String? id,
    String? label,
    String? imageUrl,
    int? votes,
    bool? isSelected,
  }) {
    return PollOption(
      id: id ?? this.id,
      label: label ?? this.label,
      imageUrl: imageUrl ?? this.imageUrl,
      votes: votes ?? this.votes,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// "Poll" screen matching the WeTravel design screenshot.
/// Shows a group poll question with image options, a live countdown timer,
/// interactive radio selection, and a "Vote" CTA.
class PollsPage extends StatefulWidget {
  final String tripId;

  const PollsPage({
    super.key,
    required this.tripId,
  });

  @override
  State<PollsPage> createState() => _PollsPageState();
}

class _PollsPageState extends State<PollsPage> {
  // ── Poll State ──────────────────────────────────────────────────────────────
  String? _selectedOptionId;
  bool _hasVoted = false;

  final List<PollOption> _initialOptions = const [
    PollOption(
      id: 'palolem',
      label: 'Palolem',
      imageUrl: 'assets/images/palolem_beach.jpg',
      votes: 3,
    ),
    PollOption(
      id: 'baga',
      label: 'Baga',
      imageUrl: 'assets/images/baga_beach.jpg',
      votes: 1,
    ),
    PollOption(
      id: 'agonda',
      label: 'Agonda',
      imageUrl: 'assets/images/agonda_beach.jpg',
      votes: 2,
    ),
    PollOption(
      id: 'candolim',
      label: 'Candolim',
      imageUrl: 'assets/images/candolim_beach.jpg',
      votes: 0,
    ),
  ];

  late List<PollOption> _options;

  // ── Countdown Timer State ───────────────────────────────────────────────────
  late Timer _timer;
  int _remainingSeconds = 103972; // 1d 4h 32m in seconds

  @override
  void initState() {
    super.initState();
    _options = List.from(_initialOptions);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedCountdown {
    final days = _remainingSeconds ~/ 86400;
    final hours = (_remainingSeconds % 86400) ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final parts = <String>[];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    parts.add('${minutes}m');
    return parts.join(' ');
  }

  void _selectOption(String id) {
    if (_hasVoted) return;
    setState(() {
      _selectedOptionId = id;
    });
  }

  void _submitVote() {
    if (_selectedOptionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select an option before voting.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF004E64),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _options = _options.map((o) {
        if (o.id == _selectedOptionId) {
          return o.copyWith(votes: o.votes + 1, isSelected: true);
        }
        return o.copyWith(isSelected: false);
      }).toList();
      _hasVoted = true;
    });

    final selected = _options.firstWhere((o) => o.id == _selectedOptionId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Vote submitted for ${selected.label}!',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF004E64),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Stack(
        children: [
          // ── Scrollable Body ──────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: topPadding + 68,
              bottom: bottomPadding + 90,
              left: 18,
              right: 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── 1. Poll Question Card ──────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.025),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Teal circle icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFF004E64),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.how_to_vote_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Which beach should we visit?',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF004E64),
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Help us decide on the best beach for our group.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF007791),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── 2. Poll Options ────────────────────────────────────
                ...List.generate(_options.length, (index) {
                  final option = _options[index];
                  final isSelected = _selectedOptionId == option.id;
                  final isWinner = _hasVoted && option.id == _selectedOptionId;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => _selectOption(option.id),
                      borderRadius: BorderRadius.circular(18),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFDEF2F1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF67B5C6)
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1.0,
                          ),
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
                            // Option Image Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 68,
                                height: 54,
                                child: Image.asset(
                                  option.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFFDEF2F1),
                                    child: const Icon(
                                      Icons.beach_access,
                                      color: Color(0xFF004E64),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Option Title & Votes
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.label,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF004E64),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    option.votes == 1
                                        ? '${option.votes} vote'
                                        : '${option.votes} votes',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF007791),
                                    ),
                                  ),
                                  if (_hasVoted && isWinner) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF004E64),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Your vote',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Radio Button
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? const Color(0xFF004E64) : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF004E64)
                                      : const Color(0xFFCBD5E1),
                                  width: 1.8,
                                ),
                              ),
                              child: isSelected
                                  ? const Center(
                                      child: Icon(
                                        Icons.circle,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),

                // ── 3. Poll Countdown Footer ───────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDEF2F1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.timer_rounded,
                            color: Color(0xFF004E64),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Poll closes in',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF007791),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEF2F1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _formattedCountdown,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF004E64),
                          ),
                        ),
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
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Poll',
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
                          size: 22,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed Bottom "Vote" CTA ──────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: bottomPadding > 0 ? bottomPadding : 16,
              ),
              color: const Color(0xFFFAF9F6),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _hasVoted ? null : _submitVote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004E64),
                    disabledBackgroundColor: const Color(0xFF004E64).withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    _hasVoted ? 'Vote Submitted ✓' : 'Vote',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

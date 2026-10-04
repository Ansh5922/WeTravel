import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../trips/presentation/widgets/invite_screen_decorations.dart';
import '../../domain/entities/trip_suggestion.dart';

/// Model representing a group discussion comment on a suggestion idea.
class SuggestionComment {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String timeAgo;
  final String message;
  final int likesCount;
  final bool isLikedByMe;

  const SuggestionComment({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.timeAgo,
    required this.message,
    required this.likesCount,
    this.isLikedByMe = false,
  });

  SuggestionComment copyWith({
    String? id,
    String? authorName,
    String? authorAvatar,
    String? timeAgo,
    String? message,
    int? likesCount,
    bool? isLikedByMe,
  }) {
    return SuggestionComment(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      timeAgo: timeAgo ?? this.timeAgo,
      message: message ?? this.message,
      likesCount: likesCount ?? this.likesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}

/// "Suggestion Detail" screen matching the WeTravel design screenshot.
/// Displays high-res scenic hero photo, activity specs, timings, rating, interested members,
/// real-time comment thread with reactions, and a primary "Vote / React" CTA.
class SuggestionDetailPage extends StatefulWidget {
  final String tripId;
  final TripSuggestion? suggestion;

  const SuggestionDetailPage({
    super.key,
    required this.tripId,
    this.suggestion,
  });

  @override
  State<SuggestionDetailPage> createState() => _SuggestionDetailPageState();
}

class _SuggestionDetailPageState extends State<SuggestionDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  late List<SuggestionComment> _comments;
  bool _isVoted = false;

  @override
  void initState() {
    super.initState();
    _isVoted = widget.suggestion?.isApprovedByMe ?? true;
    _comments = [
      const SuggestionComment(
        id: 'c1',
        authorName: 'Shifa',
        authorAvatar: 'assets/images/avatar_1.jpg',
        timeAgo: '2h ago',
        message: "Looks amazing! I'm in 💙",
        likesCount: 2,
        isLikedByMe: true,
      ),
      const SuggestionComment(
        id: 'c2',
        authorName: 'Aakansha',
        authorAvatar: 'assets/images/avatar_2.jpg',
        timeAgo: '1h ago',
        message: 'This is a must! 👏',
        likesCount: 1,
        isLikedByMe: false,
      ),
    ];
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.insert(
        0,
        SuggestionComment(
          id: 'c_${DateTime.now().millisecondsSinceEpoch}',
          authorName: 'You',
          authorAvatar: 'assets/images/avatar_user.jpg',
          timeAgo: 'Just now',
          message: text,
          likesCount: 0,
        ),
      );
      _commentController.clear();
    });
  }

  void _toggleCommentLike(int index) {
    setState(() {
      final c = _comments[index];
      final newLiked = !c.isLikedByMe;
      final newCount = newLiked ? c.likesCount + 1 : (c.likesCount > 0 ? c.likesCount - 1 : 0);
      _comments[index] = c.copyWith(isLikedByMe: newLiked, likesCount: newCount);
    });
  }

  void _showVoteReactModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Cast Your Vote',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF004E64),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'How does this activity fit your schedule and travel vibe?',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildReactionOption(ctx, '👍', "I'm In!"),
                  _buildReactionOption(ctx, '⭐', 'Top Pick'),
                  _buildReactionOption(ctx, '🤔', 'Maybe'),
                  _buildReactionOption(ctx, '👎', 'Pass'),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReactionOption(BuildContext ctx, String emoji, String label) {
    return InkWell(
      onTap: () {
        setState(() {
          _isVoted = true;
        });
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Vote recorded: $emoji $label',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF004E64),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF004E64),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final title = widget.suggestion?.title ?? 'Sunset cruise';
    final cost = widget.suggestion?.estimatedCost ?? 1200;
    final imagePath = widget.suggestion?.imageUrl ?? 'assets/images/sunset_cruise.jpg';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Stack(
        children: [
          // ── Scrollable Body ──────────────────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: bottomPadding + 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Image Container
                Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: topPadding + 220,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF004E64),
                          child: const Center(
                            child: Icon(Icons.beach_access, size: 60, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    // Pagination dots badge on top right of photo
                    Positioned(
                      top: topPadding + 64,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. White Details Card with top curve overlapping hero
                Transform.translate(
                  offset: const Offset(0, -22),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAF9F6),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Category Badge
                          Row(
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.inter(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF004E64),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDEF2F1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  'Activity',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF004E64),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Location
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF007791),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Goa, India',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF007791),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Specs Row (Price & Time)
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                color: Color(0xFF007791),
                                size: 17,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '₹$cost per person',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF004E64),
                                ),
                              ),
                              const SizedBox(width: 18),
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFF007791),
                                size: 17,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '4:30 PM – 6:30 PM',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF007791),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Rating Row
                          Row(
                            children: [
                              const Icon(
                                Icons.star_border_rounded,
                                color: Color(0xFF007791),
                                size: 17,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '4.8 (124 reviews)',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF007791),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Description
                          Text(
                            'Enjoy a relaxing sunset cruise along the Goan coast with music, snacks and beautiful views.',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              height: 1.45,
                              color: const Color(0xFF007791),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Interested Members Card
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
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
                                // Overlapping Avatars
                                SizedBox(
                                  width: 68,
                                  height: 32,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 0,
                                        child: _buildAvatar('assets/images/avatar_devansh.jpg'),
                                      ),
                                      Positioned(
                                        left: 18,
                                        child: _buildAvatar('assets/images/avatar_1.jpg'),
                                      ),
                                      Positioned(
                                        left: 36,
                                        child: _buildAvatar('assets/images/avatar_2.jpg'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '3 members interested',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF007791),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF004E64),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Comments Section ───────────────────────
                          Text(
                            'Comments (${_comments.length})',
                            style: GoogleFonts.inter(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF004E64),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Add Comment Input Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentController,
                                    style: GoogleFonts.inter(fontSize: 13.5),
                                    decoration: InputDecoration(
                                      hintText: 'Add a comment...',
                                      hintStyle: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      isDense: true,
                                    ),
                                    onSubmitted: (_) => _addComment(),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    color: Color(0xFF004E64),
                                    size: 20,
                                  ),
                                  onPressed: _addComment,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Comments List
                          ...List.generate(_comments.length, (index) {
                            final c = _comments[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 17,
                                    backgroundImage: AssetImage(c.authorAvatar),
                                    backgroundColor: const Color(0xFFDEF2F1),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              c.authorName,
                                              style: GoogleFonts.inter(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF004E64),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              c.timeAgo,
                                              style: GoogleFonts.inter(
                                                fontSize: 11.5,
                                                color: const Color(0xFF94A3B8),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          c.message,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: const Color(0xFF007791),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Like reaction button
                                  InkWell(
                                    onTap: () => _toggleCommentLike(index),
                                    child: Row(
                                      children: [
                                        Icon(
                                          c.isLikedByMe
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                          size: 15,
                                          color: c.isLikedByMe
                                              ? const Color(0xFF0284C7)
                                              : const Color(0xFF94A3B8),
                                        ),
                                        if (c.likesCount > 0) ...[
                                          const SizedBox(width: 4),
                                          Text(
                                            '${c.likesCount}',
                                            style: GoogleFonts.inter(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
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
                  size: Size(MediaQuery.of(context).size.width, topPadding + 56),
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
                        'Suggestion Detail',
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Options for $title',
                                style: GoogleFonts.inter(),
                              ),
                              backgroundColor: const Color(0xFF004E64),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed Bottom "Vote / React" CTA Button ───────────────────
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
                  onPressed: _showVoteReactModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004E64),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    _isVoted ? 'Vote / React (Voted)' : 'Vote / React',
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

  Widget _buildAvatar(String assetPath) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: CircleAvatar(
        radius: 14,
        backgroundImage: AssetImage(assetPath),
        backgroundColor: const Color(0xFFDEF2F1),
      ),
    );
  }
}

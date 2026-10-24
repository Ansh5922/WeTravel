import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../trips/domain/entities/trip_entity.dart';
import '../../../polls/domain/entities/poll_entity.dart';
import '../../../auth/presentation/widgets/auth_scenic_decorations.dart';

/// Custom painter for the dual-color circular progress ring:
/// - Main arc in Brand Deep Teal (#005F73)
/// - Top accent arc in Brand Warm Amber (#EE9B00)
/// - Unfilled background track in soft cool grey/teal (#E8EFF2)
class DualColorProgressRingPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0 (e.g. 0.85)
  final Color primaryColor;
  final Color accentColor;
  final Color trackColor;
  final double strokeWidth;

  const DualColorProgressRingPainter({
    required this.progress,
    this.primaryColor = AppColors.primaryDeepTeal,
    this.accentColor = AppColors.accentWarmYellow,
    this.trackColor = const Color(0xFFE8EFF2),
    this.strokeWidth = 9.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Draw Background Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.0) return;

    // 2. Draw Progress Arc with Rounded Caps
    // Total sweep angle based on progress (up to 2 * pi)
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    const startAngle = -math.pi / 2; // Start from top 12 o'clock

    // Accent proportion (top arc takes first ~28% of progress)
    final accentSweep = math.min(sweepAngle, 2 * math.pi * 0.28);
    final primarySweep = sweepAngle - accentSweep;

    // Accent arc (Warm Amber at top)
    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      accentSweep,
      false,
      accentPaint,
    );

    // Primary arc (Deep Teal for remaining progress)
    if (primarySweep > 0) {
      final primaryPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + accentSweep,
        primarySweep,
        false,
        primaryPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DualColorProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor;
  }
}

/// ── 1. AI Group Consensus Card ──────────────────────────────────────────────
class WorkspaceConsensusCard extends StatelessWidget {
  final double readinessProgress;
  final String dominantTravelStyle;
  final String majorityPace;
  final String budgetDisplay;
  final VoidCallback onViewInsights;

  const WorkspaceConsensusCard({
    super.key,
    required this.readinessProgress,
    required this.dominantTravelStyle,
    required this.majorityPace,
    required this.budgetDisplay,
    required this.onViewInsights,
  });

  @override
  Widget build(BuildContext context) {
    final percentInt = (readinessProgress * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEAE2D8)),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.accentWarmYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Group Consensus',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDeepTeal,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onViewInsights,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'View insights',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryTeal,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.secondaryTeal,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Body Row: Donut Chart + Details Column
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dual-color Circular Ring Meter
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(96, 96),
                      painter: DualColorProgressRingPainter(
                        progress: readinessProgress,
                        primaryColor: AppColors.primaryDeepTeal,
                        accentColor: AppColors.accentWarmYellow,
                        strokeWidth: 9,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$percentInt%',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDeepTeal,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Ready',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),

              // Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dominant Style & Pace Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6F4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.landscape_rounded,
                            size: 16,
                            color: AppColors.secondaryTeal,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '$dominantTravelStyle  ·  $majorityPace pace',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDeepTeal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Budget Row
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDEF2F1),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.paid_outlined,
                              color: AppColors.primaryDeepTeal,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Budget',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  final isFlexible = budgetDisplay.toLowerCase().contains('flex') ||
                                      budgetDisplay.toLowerCase().contains('not set') ||
                                      budgetDisplay.toLowerCase().contains('null');
                                  final cleanText = isFlexible ? 'Flexible' : budgetDisplay;
                                  final showPerPerson = !isFlexible && !cleanText.contains('/');

                                  return Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: cleanText,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryDeepTeal,
                                          ),
                                        ),
                                        if (showPerPerson)
                                          TextSpan(
                                            text: ' / person',
                                            style: GoogleFonts.inter(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ── 2. Trip Buddies Roster Card ─────────────────────────────────────────────
class WorkspaceBuddiesCard extends StatelessWidget {
  final List<TripGroupMemberEntity> members;
  final VoidCallback onInvite;

  const WorkspaceBuddiesCard({
    super.key,
    required this.members,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEAE2D8)),
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
          // Header Row
          Row(
            children: [
              const Icon(
                Icons.people_outline_rounded,
                color: AppColors.primaryDeepTeal,
                size: 21,
              ),
              const SizedBox(width: 8),
              Text(
                'Trip buddies',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDeepTeal,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Buddies Row + Invite Button
          Row(
            children: [
              // Horizontal avatar row
              Expanded(
                child: members.isEmpty
                    ? Text(
                        'No buddies added yet',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      )
                    : Row(
                        children: members.take(4).map((member) {
                          final initial = member.fullName.isNotEmpty
                              ? member.fullName[0].toUpperCase()
                              : '?';

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: ClipOval(
                                child: _buildInitialAvatar(initial),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),

              // Golden Amber '+ Invite' Pill Button
              ElevatedButton.icon(
                onPressed: onInvite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentWarmYellow,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  minimumSize: const Size(0, 36),
                ),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: Text(
                  'Invite',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInitialAvatar(String initial) {
    return Container(
      color: const Color(0xFFE8F6F4),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDeepTeal,
          ),
        ),
      ),
    );
  }
}

/// ── 3. Group Chat Preview Card ──────────────────────────────────────────────
class WorkspaceChatCard extends StatelessWidget {
  final String senderName;
  final String messageSnippet;
  final String timeAgo;
  final bool hasMessages;
  final int unreadCount;
  final String? senderAvatarUrl;
  final VoidCallback onViewChat;

  const WorkspaceChatCard({
    super.key,
    this.hasMessages = true,
    required this.senderName,
    required this.messageSnippet,
    required this.timeAgo,
    this.unreadCount = 0,
    this.senderAvatarUrl,
    required this.onViewChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEAE2D8)),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.primaryDeepTeal,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Group chat',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDeepTeal,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onViewChat,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Text(
                        'View all',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryTeal,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.secondaryTeal,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Message Preview Row
          if (!hasMessages)
            InkWell(
              onTap: onViewChat,
              borderRadius: BorderRadius.circular(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE8F6F4),
                      border: Border.all(color: const Color(0xFFC7EAE6), width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.mark_chat_unread_outlined,
                        size: 20,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No messages yet',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap here to start planning with the group!',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            )
          else
            InkWell(
              onTap: onViewChat,
              borderRadius: BorderRadius.circular(14),
              child: Row(
                children: [
                  // Sender Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    ),
                    child: ClipOval(
                      child: (senderAvatarUrl != null && senderAvatarUrl!.startsWith('http'))
                          ? Image.network(
                              senderAvatarUrl!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(),
                            )
                          : _buildAvatarPlaceholder(),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Text snippet + time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '$senderName: ',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDeepTeal,
                                ),
                              ),
                              TextSpan(
                                text: messageSnippet,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          timeAgo,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Unread Count Badge
                  if (unreadCount > 0)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDeepTeal,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$unreadCount',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    final initial = senderName.isNotEmpty ? senderName[0].toUpperCase() : 'R';
    return Container(
      color: const Color(0xFFE8F6F4),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDeepTeal,
          ),
        ),
      ),
    );
  }
}

/// ── 4. Group Polls Card with Dynamic Options & Real Votes ───────────────────
class WorkspacePollCard extends StatelessWidget {
  final PollEntity? poll;
  final String currentUserId;
  final ValueChanged<String> onVote;
  final VoidCallback onCreatePoll;
  final VoidCallback? onViewAll;

  const WorkspacePollCard({
    super.key,
    required this.poll,
    required this.currentUserId,
    required this.onVote,
    required this.onCreatePoll,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final activePoll = poll;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEAE2D8)),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bar_chart_rounded,
                    color: AppColors.primaryDeepTeal,
                    size: 21,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Group polls',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDeepTeal,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onViewAll != null) ...[
                    InkWell(
                      onTap: onViewAll,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              'View all',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryTeal,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: AppColors.secondaryTeal,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  InkWell(
                    onTap: onCreatePoll,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            size: 16,
                            color: AppColors.secondaryTeal,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Create',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondaryTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Inner Content: No polls yet VS Active Poll
          if (activePoll == null)
            InkWell(
              onTap: onCreatePoll,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEAE2D8)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F6F4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.poll_outlined,
                        size: 24,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No polls yet',
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to create a poll and vote with your trip buddies!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEAE2D8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Badge + Status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDeepTeal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activePoll.isClosed ? 'Closed' : 'Active',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        activePoll.isClosed ? 'Voting ended' : 'Open for voting',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Question Title
                  Text(
                    activePoll.question,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDeepTeal,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Options Rows
                  ...activePoll.options.map((option) {
                    final totalVotes = activePoll.totalVotes;
                    final hasVoted = activePoll.getUserVotedOptionId(currentUserId) == option.id;
                    final percent = totalVotes > 0
                        ? (option.voteCount / totalVotes)
                        : 0.0;
                    final percentInt = activePoll.percentageFor(option).toInt();

                    // Contextual icon based on text
                    final optLower = option.optionText.toLowerCase();
                    IconData icon = Icons.check_circle_outline_rounded;
                    if (optLower.contains('bike') || optLower.contains('cycle')) {
                      icon = Icons.directions_bike_rounded;
                    } else if (optLower.contains('cab') || optLower.contains('car') || optLower.contains('taxi')) {
                      icon = Icons.directions_car_rounded;
                    } else if (optLower.contains('flight') || optLower.contains('plane')) {
                      icon = Icons.flight_takeoff_rounded;
                    } else if (optLower.contains('food') || optLower.contains('dinner') || optLower.contains('lunch')) {
                      icon = Icons.restaurant_rounded;
                    } else if (optLower.contains('hotel') || optLower.contains('resort') || optLower.contains('stay')) {
                      icon = Icons.hotel_rounded;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => onVote(option.id),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: hasVoted
                                ? const Color(0xFFDEF2F1).withValues(alpha: 0.45)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: hasVoted ? AppColors.primaryDeepTeal : const Color(0xFFE2E8F0),
                              width: hasVoted ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Soft teal circular icon
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: hasVoted
                                      ? AppColors.primaryDeepTeal.withValues(alpha: 0.12)
                                      : const Color(0xFFE8F6F4),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  icon,
                                  color: AppColors.primaryDeepTeal,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Option Text + Progress Bar
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            option.optionText,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: hasVoted ? FontWeight.w700 : FontWeight.w600,
                                              color: hasVoted ? AppColors.primaryDeepTeal : const Color(0xFF1E293B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '$percentInt% (${option.voteCount})',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: hasVoted ? FontWeight.w700 : FontWeight.w600,
                                            color: hasVoted ? AppColors.primaryDeepTeal : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percent,
                                        minHeight: 6,
                                        backgroundColor: const Color(0xFFE2E8F0),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          hasVoted ? const Color(0xFFF59E0B) : AppColors.primaryDeepTeal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Generous 26x26 Radio Circle Indicator
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: hasVoted ? AppColors.primaryDeepTeal : Colors.white,
                                  border: Border.all(
                                    color: hasVoted
                                        ? AppColors.primaryDeepTeal
                                        : const Color(0xFF94A3B8),
                                    width: 2,
                                  ),
                                ),
                                child: hasVoted
                                    ? const Center(
                                        child: Icon(
                                          Icons.check_rounded,
                                          size: 16,
                                          color: Colors.white,
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
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// ── 5. Scenic Botanical Leaves & Dotted Flight Trail Footer ─────────────────
class WorkspaceScenicFooter extends StatelessWidget {
  const WorkspaceScenicFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dotted flight trail with destination pin spanning entire screen width
          Positioned(
            left: -15,
            right: -15,
            bottom: 8,
            child: SizedBox(
              height: 65,
              child: CustomPaint(
                painter: _WorkspaceTrailPainter(),
              ),
            ),
          ),

          // Botanical leaf cluster shifted down and left to the very screen edge
          const Positioned(
            left: -24,
            bottom: -18,
            child: BotanicalLeavesCluster(
              size: Size(130, 95),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceTrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentWarmYellow
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final p0 = Offset(size.width * 0.05, size.height * 0.90);
    final p1 = Offset(size.width * 0.38, size.height * 0.86);
    final p2 = Offset(size.width * 0.70, size.height * 0.65);
    final p3 = Offset(size.width * 0.96, size.height * 0.36);

    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      const dashLength = 5.0;
      const dashSpace = 4.0;
      while (distance < metric.length) {
        final extractPath = metric.extractPath(
          distance,
          math.min(distance + dashLength, metric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance += dashLength + dashSpace;
      }
    }

    // Destination Pin marker at the end
    final pinCenter = Offset(p3.dx, p3.dy - 6);
    const pinRadius = 6.0;

    final pinPaint = Paint()
      ..color = AppColors.primaryDeepTeal
      ..style = PaintingStyle.fill;

    // Pin circle head
    canvas.drawCircle(pinCenter, pinRadius, pinPaint);

    // Pin pointer triangle
    final tipPath = Path()
      ..moveTo(pinCenter.dx - pinRadius * 0.8, pinCenter.dy + 1)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(pinCenter.dx + pinRadius * 0.8, pinCenter.dy + 1)
      ..close();
    canvas.drawPath(tipPath, pinPaint);

    // Inner white dot
    final innerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pinCenter, 2.2, innerDotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

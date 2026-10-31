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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onViewInsights,
          child: Padding(
            padding: const EdgeInsets.all(18),
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
                    Row(
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
    ),
  ),
),
);
  }
}

/// ── 2. Trip Buddies Roster Card ─────────────────────────────────────────────
class WorkspaceBuddiesCard extends StatelessWidget {
  final List<TripGroupMemberEntity> members;
  final VoidCallback onInvite;
  final ValueChanged<TripGroupMemberEntity>? onTapBuddy;

  const WorkspaceBuddiesCard({
    super.key,
    required this.members,
    required this.onInvite,
    this.onTapBuddy,
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
                'Trip buddies (${members.length})',
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
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: members.map((member) {
                            final initial = member.fullName.isNotEmpty
                                ? member.fullName[0].toUpperCase()
                                : (member.username.isNotEmpty ? member.username[0].toUpperCase() : '?');

                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Tooltip(
                                message: '${member.fullName} (@${member.username})',
                                child: Material(
                                  color: Colors.transparent,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    onTap: onTapBuddy != null ? () => onTapBuddy!(member) : null,
                                    customBorder: const CircleBorder(),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: member.role == 'admin'
                                              ? AppColors.primaryDeepTeal
                                              : const Color(0xFFE2E8F0),
                                          width: member.role == 'admin' ? 2.0 : 1.5,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: (member.avatarUrl != null && member.avatarUrl!.isNotEmpty)
                                            ? Image.network(
                                                member.avatarUrl!,
                                                width: 44,
                                                height: 44,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    _buildInitialAvatar(initial),
                                              )
                                            : _buildInitialAvatar(initial),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
              const SizedBox(width: 8),

              // Golden Amber '+ Invite' Pill Button
              ElevatedButton.icon(
                onPressed: onInvite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentWarmYellow,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onViewChat,
          child: Padding(
            padding: const EdgeInsets.all(18),
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
                    Row(
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
    ),
  ),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onViewAll ?? onCreatePoll,
          child: Padding(
            padding: const EdgeInsets.all(18),
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
    ),
  ),
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

/// ── 6. Buddy Profile Bottom Sheet ──────────────────────────────────────────
class BuddyProfileSheet extends StatelessWidget {
  final TripGroupMemberEntity member;
  final TripEntity trip;
  final String currentUserId;
  final bool isFriend;
  final VoidCallback onAddFriend;
  final VoidCallback? onRemoveMember;
  final ValueChanged<String>? onAssignRole;

  const BuddyProfileSheet({
    super.key,
    required this.member,
    required this.trip,
    required this.currentUserId,
    required this.isFriend,
    required this.onAddFriend,
    this.onRemoveMember,
    this.onAssignRole,
  });

  bool get isSelf => member.userId == currentUserId;
  bool get isCreator => member.userId == trip.createdBy;
  bool get isAdmin => member.role == 'admin' || isCreator;

  @override
  Widget build(BuildContext context) {
    final initial = member.fullName.isNotEmpty
        ? member.fullName[0].toUpperCase()
        : (member.username.isNotEmpty ? member.username[0].toUpperCase() : '?');

    // Extract constraints if available
    List<String> constraints = [];
    if (member.healthConstraints is List) {
      constraints.addAll((member.healthConstraints as List).map((e) => e.toString()));
    } else if (member.healthConstraints != null) {
      constraints.add(member.healthConstraints.toString());
    }
    if (member.climateSensitivities is List) {
      constraints.addAll((member.climateSensitivities as List).map((e) => e.toString()));
    } else if (member.climateSensitivities != null) {
      constraints.add(member.climateSensitivities.toString());
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 2. Avatar & Identity Header
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isAdmin ? AppColors.accentWarmYellow : const Color(0xFFE2E8F0),
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        child: (member.avatarUrl != null && member.avatarUrl!.isNotEmpty)
                            ? Image.network(
                                member.avatarUrl!,
                                width: 76,
                                height: 76,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(initial),
                              )
                            : _buildAvatarFallback(initial),
                      ),
                    ),
                    if (isCreator)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accentWarmYellow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.star_rounded, size: 16, color: Colors.white),
                      )
                    else if (isAdmin)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryDeepTeal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_rounded, size: 16, color: Colors.white),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                member.fullName.isNotEmpty ? member.fullName : 'Traveler',
                style: GoogleFonts.inter(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDeepTeal,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '@${member.username.isNotEmpty ? member.username : 'traveler'}',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isCreator
                      ? AppColors.accentWarmYellow.withValues(alpha: 0.15)
                      : (isAdmin
                          ? AppColors.primaryDeepTeal.withValues(alpha: 0.1)
                          : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCreator
                          ? Icons.stars_rounded
                          : (isAdmin ? Icons.shield_outlined : Icons.person_outline_rounded),
                      size: 14,
                      color: isCreator
                          ? const Color(0xFFB45309)
                          : (isAdmin ? AppColors.primaryDeepTeal : const Color(0xFF475569)),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isCreator
                          ? 'Trip Organizer'
                          : (isAdmin ? 'Trip Admin' : 'Trip Buddy'),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isCreator
                            ? const Color(0xFFB45309)
                            : (isAdmin ? AppColors.primaryDeepTeal : const Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Travel Persona 2x2 Grid
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.explore_outlined,
                      label: 'Travel Style',
                      value: member.travelStyle ?? 'Relaxed',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.speed_rounded,
                      label: 'Pace',
                      value: member.pacePreference ?? 'Moderate',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.restaurant_outlined,
                      label: 'Dietary',
                      value: member.dietaryPreference ?? 'Flexible',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Budget Tier',
                      value: member.budgetTier ?? 'Flexible',
                    ),
                  ),
                ],
              ),

              // 4. Constraints / Health Sensitivities
              if (constraints.isNotEmpty) ...[
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Health & Sensitivities',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: constraints.map((c) {
                    final clean = c.replaceAll('_', ' ').trim();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF92400E)),
                          const SizedBox(width: 5),
                          Text(
                            clean,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 24),

              // 5. Actions: Add Friend & Remove Member
              if (!isSelf) ...[
                Row(
                  children: [
                    // Friend Action Button
                    Expanded(
                      child: isFriend
                          ? Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFDEF2F1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primaryDeepTeal.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: AppColors.primaryDeepTeal, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Already Friends',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDeepTeal,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: onAddFriend,
                              icon: const Icon(Icons.person_add_rounded, size: 18, color: Colors.white),
                              label: Text(
                                'Add Friend',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryDeepTeal,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                    ),

                    // Admin Remove Button
                    if (onRemoveMember != null) ...[
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => _confirmRemove(context),
                        icon: const Icon(Icons.person_remove_rounded, size: 18, color: Colors.redAccent),
                        label: Text(
                          'Remove',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.redAccent,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent, width: 1.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ],
                ),
                // Make / Dismiss Admin Button
                if (onAssignRole != null && !isCreator) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmAssignRole(
                        context,
                        member.role == 'admin' ? 'member' : 'admin',
                      ),
                      icon: Icon(
                        member.role == 'admin' ? Icons.shield_outlined : Icons.shield_rounded,
                        size: 18,
                        color: AppColors.primaryDeepTeal,
                      ),
                      label: Text(
                        member.role == 'admin' ? 'Dismiss as Admin' : 'Make Trip Admin',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDeepTeal,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryDeepTeal, width: 1.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String initial) {
    return Container(
      color: const Color(0xFFE8F6F4),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDeepTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.secondaryTeal),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDeepTeal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _confirmAssignRole(BuildContext context, String newRole) {
    final isPromote = newRole == 'admin';
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isPromote ? 'Make Trip Admin?' : 'Dismiss as Admin?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.primaryDeepTeal),
        ),
        content: Text(
          isPromote
              ? 'Make ${member.fullName} a Trip Admin? They will be able to edit trip plans, invite buddies, and manage group preferences.'
              : 'Dismiss ${member.fullName} from Admin? They will return to regular trip buddy permissions.',
          style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              onAssignRole?.call(newRole);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isPromote ? AppColors.primaryDeepTeal : Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isPromote ? 'Make Admin' : 'Dismiss',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remove from Trip?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppColors.primaryDeepTeal),
        ),
        content: Text(
          'Are you sure you want to remove ${member.fullName} from "${trip.name}"? They will lose access to this trip workspace.',
          style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              onRemoveMember?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Remove',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../trips/presentation/bloc/trip_bloc.dart';
import '../../../trips/presentation/bloc/trip_state.dart';
import '../../domain/entities/poll_entity.dart';
import '../bloc/poll_bloc.dart';
import '../bloc/poll_event.dart';
import '../bloc/poll_state.dart';

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
  @override
  void initState() {
    super.initState();
    final isTestEnv = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTestEnv) {
      context.read<PollBloc>().add(PollsFetchRequested(tripId: widget.tripId));
    }
  }

  void _showCreatePollModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreatePollModal(tripId: widget.tripId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticatedState ? authState.user.id : null;

    final tripState = context.watch<TripBloc>().state;
    String tripTitle = 'Trip Polls';
    if (tripState is TripDetailLoadedState && tripState.trip.id == widget.tripId) {
      tripTitle = tripState.trip.name;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.8,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF004E64), size: 20),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Polls & Voting',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF004E64),
              ),
            ),
            Text(
              tripTitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Trip Chat',
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF004E64), size: 22),
            onPressed: () => context.push(RouteNames.chatPath(widget.tripId)),
          ),
          IconButton(
            tooltip: 'Refresh Polls',
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF004E64), size: 22),
            onPressed: () {
              context.read<PollBloc>().add(PollsFetchRequested(tripId: widget.tripId));
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePollModal(context),
        backgroundColor: const Color(0xFF004E64),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'New Poll',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
            color: Colors.white,
          ),
        ),
      ),
      body: BlocConsumer<PollBloc, PollState>(
        listener: (context, state) {
          if (state is PollsLoadedState && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.successMessage!,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                backgroundColor: const Color(0xFF004E64),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is PollErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PollLoadingState) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF004E64)),
            );
          }

          if (state is PollsLoadedState) {
            final polls = state.polls;

            if (polls.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDEF2F1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.how_to_vote_outlined,
                          size: 48,
                          color: Color(0xFF004E64),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'No Polls Yet',
                        style: GoogleFonts.inter(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF004E64),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a poll to decide destinations, activities, restaurants, or budget preferences collaboratively!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _showCreatePollModal(context),
                        icon: const Icon(Icons.add, color: Colors.white, size: 20),
                        label: Text(
                          'Create First Poll',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004E64),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: const Color(0xFF004E64),
              onRefresh: () async {
                context.read<PollBloc>().add(PollsFetchRequested(tripId: widget.tripId));
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: polls.length,
                itemBuilder: (context, index) {
                  final poll = polls[index];
                  return _buildPollCard(poll, currentUserId);
                },
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load polls.',
                  style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    context.read<PollBloc>().add(PollsFetchRequested(tripId: widget.tripId));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPollCard(PollEntity poll, String? currentUserId) {
    final userVotedOptionId = poll.getUserVotedOptionId(currentUserId);
    final isClosed = poll.isClosed;
    final totalVotes = poll.totalVotes;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Total Votes Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isClosed
                        ? const Color(0xFF64748B).withValues(alpha: 0.12)
                        : const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isClosed ? const Color(0xFF64748B) : const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isClosed ? 'CLOSED' : 'LIVE VOTE',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isClosed ? const Color(0xFF64748B) : const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$totalVotes ${totalVotes == 1 ? "vote" : "votes"}',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                if (!isClosed && (currentUserId == poll.creatorId)) ...[
                  const SizedBox(width: 6),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20, color: Color(0xFF64748B)),
                    onSelected: (val) {
                      if (val == 'close') {
                        context.read<PollBloc>().add(
                              PollCloseRequested(
                                tripId: widget.tripId,
                                pollId: poll.id,
                              ),
                            );
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'close',
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline_rounded, size: 18, color: Colors.redAccent),
                            SizedBox(width: 8),
                            Text('Close Poll'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Question
            Text(
              poll.question,
              style: GoogleFonts.inter(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF004E64),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),

            // Options List
            Column(
              children: poll.options.map((option) {
                final isSelected = userVotedOptionId == option.id;
                final percentage = poll.percentageFor(option);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: isClosed
                        ? null
                        : () {
                            context.read<PollBloc>().add(
                                  PollVoteRequested(
                                    tripId: widget.tripId,
                                    pollId: poll.id,
                                    optionId: option.id,
                                  ),
                                );
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFDEF2F1).withValues(alpha: 0.35)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF004E64)
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Animated Progress bar
                          Positioned.fill(
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (percentage / 100.0).clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF004E64).withValues(alpha: 0.12)
                                      : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: isSelected
                                      ? const Color(0xFF004E64)
                                      : const Color(0xFF94A3B8),
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    option.optionText,
                                    style: GoogleFonts.inter(
                                      fontSize: 14.5,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                Text(
                                  '${percentage.round()}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? const Color(0xFF004E64)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '(${option.voteCount})',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            if (userVotedOptionId != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_rounded, size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 4),
                    Text(
                      'You voted in this poll',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Create Poll Modal Bottom Sheet
class _CreatePollModal extends StatefulWidget {
  final String tripId;

  const _CreatePollModal({required this.tripId});

  @override
  State<_CreatePollModal> createState() => _CreatePollModalState();
}

class _CreatePollModalState extends State<_CreatePollModal> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length < 6) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        final c = _optionControllers.removeAt(index);
        c.dispose();
      });
    }
  }

  void _submit() {
    final question = _questionController.text.trim();
    final options = _optionControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a poll question.')),
      );
      return;
    }

    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide at least 2 options.')),
      );
      return;
    }

    context.read<PollBloc>().add(
          PollCreateRequested(
            tripId: widget.tripId,
            question: question,
            options: options,
          ),
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 16),
            Text(
              'Create a Group Poll',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF004E64),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Decide activities, locations, or dates together.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 18),
            // Question Input
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: 'Poll Question',
                hintText: 'e.g. Which beach should we visit?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Options',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(_optionControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _optionControllers[index],
                        decoration: InputDecoration(
                          hintText: 'Option ${index + 1}',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    if (_optionControllers.length > 2)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => _removeOption(index),
                      ),
                  ],
                ),
              );
            }),
            if (_optionControllers.length < 6)
              TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add, size: 18, color: Color(0xFF004E64)),
                label: Text(
                  'Add another option',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF004E64),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004E64),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Publish Poll',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

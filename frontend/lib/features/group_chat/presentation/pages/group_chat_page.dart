import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../trips/presentation/bloc/trip_bloc.dart';
import '../../../trips/presentation/bloc/trip_state.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class GroupChatPage extends StatefulWidget {
  final String tripId;

  const GroupChatPage({
    super.key,
    required this.tripId,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isConnectingWs = false;

  @override
  void initState() {
    super.initState();
    final isTestEnv = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTestEnv) {
      _initializeChat();
    }
  }

  Future<void> _initializeChat() async {
    // 1. Fetch existing message history
    context.read<ChatBloc>().add(ChatMessagesFetchRequested(tripId: widget.tripId));

    // 2. Connect WebSocket with current JWT
    setState(() => _isConnectingWs = true);
    final token = await ServiceLocator.authLocalDataSource.getToken();
    if (token != null && mounted) {
      context.read<ChatBloc>().add(
            ChatConnectWebSocketRequested(
              tripId: widget.tripId,
              token: token,
            ),
          );
    }
    if (mounted) {
      setState(() => _isConnectingWs = false);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    context.read<ChatBloc>().add(ChatSendTextMessageRequested(content: text));

    // Scroll to bottom smoothly
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticatedState ? authState.user.id : null;

    final tripState = context.watch<TripBloc>().state;
    String tripTitle = 'Trip Chat';
    if (tripState is TripDetailLoadedState && tripState.trip.id == widget.tripId) {
      tripTitle = tripState.trip.name;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.8,
        scrolledUnderElevation: 1.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF004E64), size: 20),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF004E64).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.groups_rounded, color: Color(0xFF004E64), size: 22),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tripTitle,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF004E64),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      final isConnected = state is ChatLoadedState && state.isWsConnected;
                      return Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isConnected ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isConnected
                                ? 'Live'
                                : (_isConnectingWs ? 'Connecting...' : 'Active'),
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Live Polls',
            icon: const Icon(Icons.how_to_vote_outlined, color: Color(0xFF004E64), size: 22),
            onPressed: () => context.push(RouteNames.pollsPath(widget.tripId)),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
        ),
        child: Column(
          children: [
            // ── Messages Feed ──────────────────────────────────────────────────
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ChatErrorState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (state is ChatLoadedState) {
                    // Auto-update & scroll like WhatsApp on new messages!
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent + 80,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    });
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoadingState) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF004E64)),
                    );
                  }

                  if (state is ChatLoadedState) {
                    final messages = state.messages;

                    if (messages.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDEF2F1).withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 48,
                                  color: Color(0xFF004E64),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Start the Conversation',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF004E64),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Coordinate activities, share ideas, and chat in real-time with your travel buddies.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  color: const Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              OutlinedButton.icon(
                                onPressed: () => context.push(RouteNames.pollsPath(widget.tripId)),
                                icon: const Icon(Icons.poll_rounded, size: 18, color: Color(0xFF004E64)),
                                label: Text(
                                  'View Live Polls',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF004E64),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF004E64)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = (currentUserId != null && msg.senderId == currentUserId) ||
                            msg.senderId == 'me' ||
                            msg.id.startsWith('temp_');
                        return _buildMessageBubble(msg, isMe);
                      },
                    );
                  }

                  return Center(
                    child: Text(
                      'Unable to load messages.',
                      style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                    ),
                  );
                },
              ),
            ),

            // ── Single-Layer Clean WhatsApp-Style Input Bar ──────────────────
            Container(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 8,
                bottom: MediaQuery.of(context).padding.bottom + 8,
              ),
              color: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Single Clean Input Capsule
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Quick actions / attachment button
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF004E64), size: 22),
                            tooltip: 'Chat Actions & Polls',
                            onPressed: () => _showChatActionsSheet(context),
                          ),
                          // Message input
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              textCapitalization: TextCapitalization.sentences,
                              maxLines: 4,
                              minLines: 1,
                              style: GoogleFonts.inter(fontSize: 14.5, color: const Color(0xFF1E293B)),
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          // Quick Poll shortcut
                          IconButton(
                            icon: const Icon(Icons.how_to_vote_outlined, color: Color(0xFF64748B), size: 21),
                            tooltip: 'Live Polls',
                            onPressed: () => context.push(RouteNames.pollsPath(widget.tripId)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Floating Circular Send Button
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFF004E64),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33004E64),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _sendMessage,
                        child: const Center(
                          child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
    );
  }

  void _showChatActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Trip Collaboration Hub',
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF004E64)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quick in-chat actions to collaborate with your buddies:',
                  style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildChatActionItem(
                      ctx,
                      icon: Icons.poll_rounded,
                      bgColor: const Color(0xFFDEF2F1),
                      iconColor: const Color(0xFF004E64),
                      label: 'Create Poll',
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push(RouteNames.pollsPath(widget.tripId));
                      },
                    ),
                    _buildChatActionItem(
                      ctx,
                      icon: Icons.receipt_long_rounded,
                      bgColor: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF16A34A),
                      label: 'Split Expense',
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push(RouteNames.expensesPath(widget.tripId));
                      },
                    ),
                    _buildChatActionItem(
                      ctx,
                      icon: Icons.map_rounded,
                      bgColor: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0284C7),
                      label: 'Itinerary',
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push(RouteNames.itineraryPath(widget.tripId));
                      },
                    ),
                    _buildChatActionItem(
                      ctx,
                      icon: Icons.info_outline_rounded,
                      bgColor: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      label: 'Workspace',
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push(RouteNames.tripDetailsPath(widget.tripId));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatActionItem(
    BuildContext context, {
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageEntity msg, bool isMe) {
    final senderName = msg.sender?.fullName ?? msg.sender?.username ?? (isMe ? 'You' : 'Traveler');
    final initial = senderName.isNotEmpty ? senderName[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFFDEF2F1),
              child: Text(
                initial,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF004E64),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      senderName,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF004E64),
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF004E64) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (msg.imageUrl != null && msg.imageUrl!.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            msg.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.broken_image_rounded,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        msg.content,
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                          color: isMe ? Colors.white : const Color(0xFF1E293B),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(msg.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: isMe ? Colors.white.withValues(alpha: 0.75) : const Color(0xFF94A3B8),
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              msg.id.startsWith('temp_') ? Icons.done_rounded : Icons.done_all_rounded,
                              size: 13,
                              color: msg.id.startsWith('temp_') ? Colors.white60 : const Color(0xFFF59E0B),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

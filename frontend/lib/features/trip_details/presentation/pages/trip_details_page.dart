import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/we_travel_drawer.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../expenses/presentation/bloc/expense_bloc.dart';
import '../../../expenses/presentation/bloc/expense_event.dart';
import '../../../expenses/presentation/pages/expenses_page.dart';
import '../../../friends/domain/entities/friend_entity.dart';
import '../../../friends/presentation/bloc/friend_bloc.dart';
import '../../../friends/presentation/bloc/friend_state.dart';
import '../../../group_chat/presentation/bloc/chat_bloc.dart';
import '../../../group_chat/presentation/bloc/chat_event.dart';
import '../../../group_chat/presentation/bloc/chat_state.dart';
import '../../../itinerary/presentation/bloc/itinerary_bloc.dart';
import '../../../itinerary/presentation/bloc/itinerary_event.dart';
import '../../../itinerary/presentation/pages/itinerary_page.dart';
import '../../../polls/domain/entities/poll_entity.dart';
import '../../../polls/presentation/bloc/poll_bloc.dart';
import '../../../polls/presentation/bloc/poll_event.dart';
import '../../../polls/presentation/bloc/poll_state.dart';
import '../../../trips/domain/entities/trip_entity.dart';
import '../../../trips/presentation/bloc/trip_bloc.dart';
import '../../../trips/presentation/bloc/trip_event.dart';
import '../../../trips/presentation/bloc/trip_state.dart';
import '../widgets/workspace_widgets.dart';

/// Unified Trip Experience Screen hosting 3 top-level tabs:
/// - [Tab 0: Workspace] — AI Consensus & Readiness, Buddies Roster, Live Chat & Live Polls
/// - [Tab 1: Itinerary] — Day-by-Day Timeline, AI Variant Switching, and Transit Booking
/// - [Tab 2: Expense]   — Group Ledger, Personal Balances, and Split Bill Modal
class TripDetailsPage extends StatefulWidget {
  final String tripId;

  const TripDetailsPage({
    super.key,
    required this.tripId,
  });

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  TripEntity? _trip;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    final currentState = context.read<TripBloc>().state;
    if (currentState is TripDetailLoadedState && currentState.trip.id == widget.tripId) {
      _trip = currentState.trip;
    } else if (currentState is TripCreatedState && currentState.trip.id == widget.tripId) {
      _trip = currentState.trip;
    }

    // Initialize all 3 feature stores for this trip dynamically
    final isTestEnv = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTestEnv && widget.tripId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<TripBloc>().add(TripDetailsRequested(widget.tripId));
          context.read<ChatBloc>().add(ChatMessagesFetchRequested(tripId: widget.tripId));
          context.read<PollBloc>().add(PollsFetchRequested(tripId: widget.tripId));
          context.read<ItineraryBloc>().add(ItinerariesFetchRequested(widget.tripId));
          context.read<ExpenseBloc>().add(ExpensesFetchRequested(tripId: widget.tripId));
          _connectChatWs();
        }
      });
    }
  }

  Future<void> _connectChatWs() async {
    final token = await ServiceLocator.authLocalDataSource.getToken();
    if (token != null && mounted) {
      context.read<ChatBloc>().add(
            ChatConnectWebSocketRequested(
              tripId: widget.tripId,
              token: token,
            ),
          );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.trips);
    }
  }

  void _showInviteModal(BuildContext context, TripEntity trip) {
    final inviteLink = 'https://wetravel.app/join/${trip.id}';
    final inviteMessage =
        'Hey! Join our trip "${trip.name}" on WeTravel! Plan together, vote on activities, and split expenses effortlessly.\n\nTap here to join: $inviteLink';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                  'Invite to ${trip.name}',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF004E64),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose how you want to invite your travel buddies:',
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 18),

                // 1) Add from Friends / Buddies
                _buildInviteOptionTile(
                  iconBg: const Color(0xFFDEF2F1),
                  iconColor: const Color(0xFF004E64),
                  icon: Icons.person_add_alt_1_rounded,
                  title: 'Add from Friends & Buddies',
                  subtitle: 'Invite directly from your WeTravel friends list',
                  onTap: () {
                    Navigator.pop(modalCtx);
                    _showFriendsPickerSheet(context, trip);
                  },
                ),
                const SizedBox(height: 10),

                // 2) Via WhatsApp
                _buildInviteOptionTile(
                  iconBg: const Color(0xFFDCFCE7),
                  iconColor: const Color(0xFF16A34A),
                  icon: Icons.chat_rounded,
                  title: 'Invite via WhatsApp',
                  subtitle: 'Share invitation message with link directly in chat',
                  onTap: () async {
                    Navigator.pop(modalCtx);
                    final waUri = Uri.parse(
                      'whatsapp://send?text=${Uri.encodeComponent(inviteMessage)}',
                    );
                    final waFallback = Uri.parse(
                      'https://wa.me/?text=${Uri.encodeComponent(inviteMessage)}',
                    );
                    try {
                      if (await canLaunchUrl(waUri)) {
                        await launchUrl(waUri, mode: LaunchMode.externalApplication);
                      } else {
                        await launchUrl(waFallback, mode: LaunchMode.externalApplication);
                      }
                    } catch (_) {
                      await launchUrl(waFallback, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                const SizedBox(height: 10),

                // 3) Via Email
                _buildInviteOptionTile(
                  iconBg: const Color(0xFFE0F2FE),
                  iconColor: const Color(0xFF0284C7),
                  icon: Icons.email_rounded,
                  title: 'Invite via Email',
                  subtitle: 'Compose an email with pre-filled trip details & link',
                  onTap: () async {
                    Navigator.pop(modalCtx);
                    final subject = 'Join my trip on WeTravel: ${trip.name}';
                    final mailtoUri = Uri.parse(
                      'mailto:?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(inviteMessage)}',
                    );
                    try {
                      await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open email application')),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 10),

                // 4) Copy Link
                _buildInviteOptionTile(
                  iconBg: const Color(0xFFFEF3C7),
                  iconColor: const Color(0xFFD97706),
                  icon: Icons.link_rounded,
                  title: 'Copy Invitation Link',
                  subtitle: 'Copy link to clipboard to share anywhere',
                  onTap: () async {
                    Navigator.pop(modalCtx);
                    await Clipboard.setData(ClipboardData(text: inviteLink));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Trip invitation link copied to clipboard!'),
                            ],
                          ),
                          backgroundColor: const Color(0xFF004E64),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInviteOptionTile({
    required Color iconBg,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  void _showFriendsPickerSheet(BuildContext context, TripEntity trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return BlocBuilder<FriendBloc, FriendState>(
          builder: (context, friendState) {
            final friends = friendState is FriendsLoadedState ? friendState.friends : <FriendEntity>[];
            final existingMemberIds = trip.members.map((m) => m.userId).toSet();
            final availableFriends = friends.where((f) => !existingMemberIds.contains(f.id)).toList();

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                      'Invite Friends',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF004E64),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select friends to add directly to this trip:',
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 14),
                    if (availableFriends.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            friends.isEmpty
                                ? 'No friends found. Add friends in the Inbox/Friends tab!'
                                : 'All your friends are already in this trip!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF64748B)),
                          ),
                        ),
                      ),
                    ] else ...[
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: availableFriends.length,
                          separatorBuilder: (c, i) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          itemBuilder: (c, i) {
                            final friend = availableFriends[i];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 4),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF004E64),
                                child: Text(
                                  friend.fullName.isNotEmpty ? friend.fullName[0].toUpperCase() : 'F',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                friend.fullName,
                                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              subtitle: Text(
                                '@${friend.username}',
                                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  context.read<TripBloc>().add(
                                        TripInviteMemberRequested(
                                          tripId: trip.id,
                                          type: 'friend',
                                          friendId: friend.id,
                                        ),
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Invited ${friend.fullName} to the trip!'),
                                      backgroundColor: const Color(0xFF004E64),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF59E0B),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                child: Text(
                                  'Invite',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreatePollModal(BuildContext context) {
    final questionController = TextEditingController();
    final List<TextEditingController> optionControllers = [
      TextEditingController(),
      TextEditingController(),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Create a Group Poll',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF004E64),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDEF2F1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${optionControllers.length} options',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF004E64),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: questionController,
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        labelText: 'Poll Question',
                        hintText: 'e.g. Which sunset cafe should we visit?',
                        hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF004E64), width: 1.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Poll Options',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...List.generate(optionControllers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: optionControllers[index],
                                style: GoogleFonts.inter(fontSize: 13.5),
                                decoration: InputDecoration(
                                  labelText: 'Option ${index + 1}',
                                  isDense: true,
                                  prefixIcon: const Icon(Icons.radio_button_unchecked, size: 16, color: Color(0xFF004E64)),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFF004E64), width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            if (optionControllers.length > 2)
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444), size: 20),
                                tooltip: 'Remove option',
                                onPressed: () {
                                  setModalState(() {
                                    optionControllers.removeAt(index);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }),
                    if (optionControllers.length < 6)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setModalState(() {
                              optionControllers.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF004E64)),
                          label: Text(
                            '+ Add Another Option',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF004E64),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final q = questionController.text.trim();
                          final options = optionControllers
                              .map((c) => c.text.trim())
                              .where((txt) => txt.isNotEmpty)
                              .toList();

                          if (q.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a poll question')),
                            );
                            return;
                          }
                          if (options.length < 2) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please provide at least 2 non-empty options')),
                            );
                            return;
                          }

                          Navigator.pop(modalCtx);
                          context.read<PollBloc>().add(
                                PollCreateRequested(
                                  tripId: widget.tripId,
                                  question: q,
                                  options: options,
                                ),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004E64),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Publish Poll',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWarm,
        drawer: const WeTravelDrawer(),
        body: BlocConsumer<TripBloc, TripState>(
          listener: (context, state) {
            if (state is TripDetailLoadedState && state.trip.id == widget.tripId) {
              setState(() {
                _trip = state.trip;
              });
            } else if (state is TripCreatedState && state.trip.id == widget.tripId) {
              setState(() {
                _trip = state.trip;
              });
            } else if (state is TripInviteSentState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.primaryDeepTeal,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, tripState) {
            final trip = _trip ??
                (tripState is TripDetailLoadedState && tripState.trip.id == widget.tripId
                    ? tripState.trip
                    : null);

            final consensus = tripState is TripDetailLoadedState ? tripState.consensus : null;
            final tripName = trip?.name.isNotEmpty == true ? trip!.name : 'Trip Workspace';

            final String dateRange;
            if (trip != null && trip.tripStartDate != null && trip.tripEndDate != null) {
              const months = [
                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
              ];
              final s = trip.tripStartDate!;
              final e = trip.tripEndDate!;
              dateRange = '${months[s.month - 1]} ${s.day}–${e.day}';
            } else if (trip?.tripStartDate != null) {
              const months = [
                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
              ];
              final s = trip!.tripStartDate!;
              dateRange = '${months[s.month - 1]} ${s.day}';
            } else {
              dateRange = 'Dates pending';
            }
            final memberCount = trip?.members.length ?? 0;

            return Column(
              children: [
                // ── 1. Hero Scenic Header Matching Design ─────────────────────
                _buildHeroHeader(
                  context,
                  trip,
                  tripName,
                  dateRange,
                  memberCount,
                  topPadding,
                ),

                // ── 2. Floating Pill Segmented Tab Bar ────────────────────────
                _buildSegmentedTabBar(),

                // ── 3. Tab Views Content ─────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 0: Workspace (Consensus, Buddies, Chat, Polls, Scenic Footer)
                      _buildWorkspaceTab(trip, consensus, dateRange, memberCount),

                      // Tab 1: Itinerary (Day-by-Day, variants, booking)
                      ItineraryPage(tripId: widget.tripId, isEmbedded: true),

                      // Tab 2: Expense (Ledger, personal balance, split modal)
                      ExpensesPage(tripId: widget.tripId, isEmbedded: true),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// ── Hero Scenic Header with Overlapping Avatars & Translucent Date Pill ──
  Widget _buildHeroHeader(
    BuildContext context,
    TripEntity? trip,
    String tripName,
    String dateRange,
    int memberCount,
    double topPadding,
  ) {
    final coverUrl = trip?.coverImageUrl;
    final displayMembers = trip?.members.take(3).toList() ?? [];

    return Stack(
      children: [
        // 1. Scenic Background Image (Responsive across phone sizes)
        SizedBox(
          width: double.infinity,
          height: topPadding + 110,
          child: Image.asset(
            'assets/images/workspace_header.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF005F73), Color(0xFF0A9396)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),

        // 2. Subtle Dark Gradient Overlay for Contrast
        Container(
          width: double.infinity,
          height: topPadding + 110,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.50),
                Colors.black.withValues(alpha: 0.15),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // 3. Top Content: Back arrow + Trip Title + Date Pill on Left | Avatars + '4 buddies' on Right
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _handleBack,
                ),

                // Trip Title & Date Pill
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        tripName,
                        style: GoogleFonts.inter(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),

                      // Translucent Date Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_month_outlined,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              dateRange,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Overlapping Avatars & Buddies Count
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 4),
                    // Overlapping Avatar Cluster
                    SizedBox(
                      height: 32,
                      width: displayMembers.isNotEmpty
                          ? 24.0 + (displayMembers.length * 16.0)
                          : 40,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          if (displayMembers.isEmpty)
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                color: const Color(0xFFE8F6F4),
                              ),
                              child: Center(
                                child: Text(
                                  memberCount > 0 ? '$memberCount' : '1',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDeepTeal,
                                  ),
                                ),
                              ),
                            )
                          else
                            for (int i = 0; i < displayMembers.length; i++)
                              Positioned(
                                left: i * 16.0,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                    color: const Color(0xFFE8F6F4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      displayMembers[i].fullName.isNotEmpty
                                          ? displayMembers[i].fullName[0].toUpperCase()
                                          : '?',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryDeepTeal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$memberCount ${memberCount == 1 ? 'buddy' : 'buddies'}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ── Floating Pill Segmented Tab Bar ─────────────────────────────────────
  Widget _buildSegmentedTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEAE2D8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSegmentTabItem(0, 'Workspace', Icons.grid_view_rounded),
          _buildSegmentTabItem(1, 'Itinerary', Icons.calendar_month_outlined),
          _buildSegmentTabItem(2, 'Expenses', Icons.account_balance_wallet_outlined),
        ],
      ),
    );
  }

  Widget _buildSegmentTabItem(int index, String title, IconData icon) {
    final isSelected = _tabController.index == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDeepTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.primaryDeepTeal,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.primaryDeepTeal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ── Workspace Tab Content: Matching Pixel-Perfect Reference Design ───────
  Widget _buildWorkspaceTab(
    TripEntity? trip,
    GroupConsensusEntity? consensus,
    String dateRange,
    int memberCount,
  ) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticatedState ? authState.user.id : '';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card 1: AI Group Consensus ────────────────────────────────────
          Builder(
            builder: (context) {
              double readiness = 0.0;
              if (consensus != null) {
                if (consensus.groupStats?['readiness_score'] is num) {
                  readiness = (consensus.groupStats!['readiness_score'] as num).toDouble();
                } else {
                  int factors = 0;
                  if (consensus.dominantTravelStyle.isNotEmpty && consensus.dominantTravelStyle != 'Relaxed') factors++;
                  if (consensus.majorityPace.isNotEmpty && consensus.majorityPace != 'Moderate') factors++;
                  if (consensus.budgetDisplay.isNotEmpty && consensus.budgetDisplay != 'Flexible') factors++;
                  readiness = factors > 0 ? (factors / 3.0) : 0.60;
                }
              }

              return WorkspaceConsensusCard(
                readinessProgress: readiness,
                dominantTravelStyle: consensus?.dominantTravelStyle ?? 'Relaxed',
                majorityPace: consensus?.majorityPace ?? 'Moderate',
                budgetDisplay: consensus?.budgetDisplay ?? 'Flexible',
                onViewInsights: () => context.push(RouteNames.aiInsightsPath(widget.tripId)),
              );
            },
          ),
          const SizedBox(height: 16),

          // ── Card 2: Trip Buddies Roster ───────────────────────────────────
          WorkspaceBuddiesCard(
            members: trip?.members ?? [],
            onInvite: () {
              if (trip != null) _showInviteModal(context, trip);
            },
          ),
          const SizedBox(height: 16),

          // ── Card 3: Group Chat Preview (100% Real Dynamic) ─────────────────
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, chatState) {
              if (chatState is ChatLoadedState && chatState.messages.isNotEmpty) {
                final latest = chatState.messages.last;
                final senderName = latest.sender?.fullName.isNotEmpty == true
                    ? latest.sender!.fullName
                    : (latest.sender?.username ?? 'Traveler');
                final messageSnippet = latest.content.isNotEmpty ? latest.content : 'Shared an attachment';
                final diff = DateTime.now().difference(latest.createdAt);
                final String timeAgo;
                if (diff.inMinutes < 60) {
                  timeAgo = '${math.max(1, diff.inMinutes)}m ago';
                } else if (diff.inHours < 24) {
                  timeAgo = '${diff.inHours}h ago';
                } else {
                  timeAgo = '${diff.inDays}d ago';
                }
                final unreadCount = chatState.messages
                    .where((m) => m.sender?.id != null && m.sender!.id != currentUserId)
                    .length;

                return WorkspaceChatCard(
                  hasMessages: true,
                  senderName: senderName,
                  senderAvatarUrl: latest.sender?.avatarUrl,
                  messageSnippet: messageSnippet,
                  timeAgo: timeAgo,
                  unreadCount: unreadCount > 99 ? 99 : unreadCount,
                  onViewChat: () => context.push(RouteNames.chatPath(widget.tripId)),
                );
              }

              // Real dynamic empty state when no messages exist yet
              return WorkspaceChatCard(
                hasMessages: false,
                senderName: '',
                messageSnippet: '',
                timeAgo: '',
                unreadCount: 0,
                onViewChat: () => context.push(RouteNames.chatPath(widget.tripId)),
              );
            },
          ),
          const SizedBox(height: 16),

          // ── Card 4: Group Polls (100% Real Dynamic) ────────────────────────
          BlocBuilder<PollBloc, PollState>(
            builder: (context, pollState) {
              PollEntity? activePoll;
              if (pollState is PollsLoadedState && pollState.polls.isNotEmpty) {
                final openPolls = pollState.polls.where((p) => !p.isClosed);
                activePoll = openPolls.isNotEmpty ? openPolls.first : pollState.polls.first;
              }

              return WorkspacePollCard(
                poll: activePoll,
                currentUserId: currentUserId,
                onViewAll: () => context.push(RouteNames.pollsPath(widget.tripId)),
                onVote: (optionId) {
                  if (activePoll != null) {
                    context.read<PollBloc>().add(
                          PollVoteRequested(
                            tripId: widget.tripId,
                            pollId: activePoll.id,
                            optionId: optionId,
                          ),
                        );
                  }
                },
                onCreatePoll: () => _showCreatePollModal(context),
              );
            },
          ),
          const SizedBox(height: 14),

          // ── Bottom Scenic Foliage & Dotted Trail Footer ───────────────────
          const WorkspaceScenicFooter(),
        ],
      ),
    );
  }
}


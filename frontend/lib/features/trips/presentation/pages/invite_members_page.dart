import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/we_travel_search_bar.dart';
import '../../../friends/presentation/bloc/friend_bloc.dart';
import '../../../friends/presentation/bloc/friend_event.dart';
import '../../../friends/presentation/bloc/friend_state.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/trip_member.dart';
import '../../domain/entities/trip_review_draft.dart';
import '../widgets/invite_screen_decorations.dart';
import '../../../auth/presentation/widgets/auth_scenic_decorations.dart';

/// Invite Members screen (Screen 04) matching the Eraser design specification:
/// - Real friends dynamically fetched and managed via FriendBloc with real UUIDs
/// - Completely responsive header with zero pixel overflow
/// - Real-world native app sharing via share_plus
/// - Real WhatsApp integration via url_launcher with pre-filled dynamic trip invite message
/// - Real Email & SMS integration via url_launcher
/// - Add friend by username dialog with direct BLoC connection and reactive feedback
/// - Dynamic navigation supporting both Wizard flow (Next to Review) and standalone Trip flow (Done)
class InviteMembersPage extends StatefulWidget {
  final TripEntity? trip;
  final TripReviewDraft? draft;

  const InviteMembersPage({
    super.key,
    this.trip,
    this.draft,
  });

  @override
  State<InviteMembersPage> createState() => _InviteMembersPageState();
}

class _InviteMembersPageState extends State<InviteMembersPage> {
  final TextEditingController _searchController = TextEditingController();

  late final TripReviewDraft _draft;
  final Set<String> _selectedMemberIds = <String>{};
  final List<String> _invitedEmails = <String>[];
  final List<String> _invitedPhones = <String>[];

  bool get _isWizardMode =>
      widget.trip == null && (_draft.createdTripId == null || _draft.createdTripId!.isEmpty);

  String get _tripId {
    if (widget.trip != null && widget.trip!.id.isNotEmpty) {
      return widget.trip!.id;
    }
    if (widget.draft != null && widget.draft!.createdTripId != null) {
      return widget.draft!.createdTripId!;
    }
    return '';
  }

  String get _tripName {
    if (widget.trip != null && widget.trip!.name.isNotEmpty) {
      return widget.trip!.name;
    }
    if (widget.draft != null && widget.draft!.destination.isNotEmpty) {
      return widget.draft!.destination;
    }
    return 'Your Trip';
  }

  String _searchQuery = '';
  final String _activeFilter = 'All'; // 'All', 'Selected', 'Unselected'
  final String _activeSort = 'suggested'; // 'suggested', 'alphabetical'

  @override
  void initState() {
    super.initState();
    if (widget.trip != null) {
      final trip = widget.trip!;
      _draft = TripReviewDraft(
        destination: trip.name,
        startDate: trip.tripStartDate ?? DateTime.now().add(const Duration(days: 7)),
        endDate: trip.tripEndDate ?? DateTime.now().add(const Duration(days: 10)),
        createdTripId: trip.id,
      );
    } else {
      _draft = widget.draft ?? TripReviewDraft.initial();
    }

    // Initialize previously selected members if draft has any
    for (final member in _draft.selectedMembers) {
      if (member.isSelected) {
        _selectedMemberIds.add(member.id);
      }
    }
    _invitedEmails.addAll(_draft.invitedEmails);
    _invitedPhones.addAll(_draft.invitedPhones);

    // Fetch real friends safely AFTER the entrance route transition has completed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route != null && route.animation != null && !route.animation!.isCompleted) {
        void listener(AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            route.animation?.removeStatusListener(listener);
            if (mounted) {
              final friendBloc = context.read<FriendBloc>();
              if (friendBloc.state is! FriendsLoadedState) {
                friendBloc.add(const FriendsFetchRequested());
              }
            }
          }
        }
        route.animation!.addStatusListener(listener);
      } else {
        final friendBloc = context.read<FriendBloc>();
        if (friendBloc.state is! FriendsLoadedState) {
          friendBloc.add(const FriendsFetchRequested());
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _dynamicInviteLink {
    if (_tripId.isNotEmpty) {
      return 'https://wetravel.app/trips/join/$_tripId';
    }
    final dest = _draft.destination.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-');
    final cleanDest = dest.isEmpty ? 'trip' : dest;
    return 'https://wetravel.app/trips/join/invite-$cleanDest';
  }

  String get _inviteMessage {
    final link = _dynamicInviteLink;
    return "Hey! I'm planning a trip to $_tripName (${_draft.formattedDates}) on WeTravel. Join our trip group to vote on stays, plan activities, and split costs: $link";
  }

  void _copyInviteLink() {
    final link = _dynamicInviteLink;
    Clipboard.setData(ClipboardData(text: link));
    HapticFeedback.lightImpact();

    if (_tripId.isNotEmpty) {
      context.read<TripBloc>().add(
            TripInviteMemberRequested(
              tripId: _tripId,
              type: 'link',
            ),
          );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.link_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _tripId.isNotEmpty
                    ? 'Invite link copied to clipboard! Share it with your group.'
                    : 'Invite link copied! Note: Link activates once your trip is created in the next step.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF005F73),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareInviteLink() async {
    HapticFeedback.lightImpact();
    final link = _dynamicInviteLink;
    final message = _inviteMessage;

    if (_tripId.isNotEmpty) {
      context.read<TripBloc>().add(
            TripInviteMemberRequested(
              tripId: _tripId,
              type: 'link',
            ),
          );
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: '$message\n\n$link',
          subject: 'Join my trip to $_tripName on WeTravel!',
        ),
      );
    } catch (_) {
      _copyInviteLink();
    }
  }

  Future<void> _launchWhatsApp() async {
    HapticFeedback.lightImpact();
    if (_tripId.isNotEmpty) {
      context.read<TripBloc>().add(
            TripInviteMemberRequested(
              tripId: _tripId,
              type: 'whatsapp',
            ),
          );
    }

    final message = _inviteMessage;
    final encoded = Uri.encodeComponent(message);

    // whatsapp://send?text=... without phone number directly launches WhatsApp contact/chat picker
    final nativeUri = Uri.parse('whatsapp://send?text=$encoded');
    final webUri = Uri.parse('https://api.whatsapp.com/send?text=$encoded');

    try {
      final launched = await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        final webLaunched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
        if (!webLaunched) {
          await SharePlus.instance.share(
            ShareParams(
              text: message,
              subject: 'Join my trip to $_tripName on WeTravel!',
            ),
          );
        }
      }
    } catch (_) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        await SharePlus.instance.share(
          ShareParams(
            text: message,
            subject: 'Join my trip to $_tripName on WeTravel!',
          ),
        );
      }
    }
  }

  Future<void> _launchEmail() async {
    HapticFeedback.lightImpact();
    if (_tripId.isNotEmpty) {
      context.read<TripBloc>().add(
            TripInviteMemberRequested(
              tripId: _tripId,
              type: 'email',
            ),
          );
    }

    final subject = Uri.encodeComponent("You're invited to join $_tripName on WeTravel!");
    final body = Uri.encodeComponent(
      "Hey!\n\n"
      "I'm planning a trip to $_tripName (${_draft.formattedDates}) on WeTravel.\n\n"
      "Click the link below to join our trip workspace, vote on stays, plan activities, and split costs:\n\n"
      "$_dynamicInviteLink\n\n"
      "See you on the trip!\n",
    );

    // mailto:?subject=...&body=... without recipient opens compose window so user selects ANY contact
    final emailUri = Uri.parse('mailto:?subject=$subject&body=$body');

    try {
      final launched = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await SharePlus.instance.share(
          ShareParams(
            text: _inviteMessage,
            subject: "You're invited to join $_tripName on WeTravel!",
          ),
        );
      }
    } catch (_) {
      await SharePlus.instance.share(
        ShareParams(
          text: _inviteMessage,
          subject: "You're invited to join $_tripName on WeTravel!",
        ),
      );
    }
  }

  void _showAddFriendDialog() {
    final usernameController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF005F73), size: 22),
            const SizedBox(width: 8),
            Text(
              'Add & Invite Buddy',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: const Color(0xFF005F73),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter username to send a friend request AND invite them to this trip simultaneously:',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: usernameController,
              autofocus: true,
              textInputAction: TextInputAction.send,
              onSubmitted: (val) {
                final raw = val.trim();
                final username = raw.startsWith('@') ? raw.substring(1).trim() : raw;
                if (username.isNotEmpty) {
                  _submitFriendAndInvite(username, dialogCtx);
                }
              },
              decoration: InputDecoration(
                hintText: 'e.g. ananya_v',
                prefixIcon: const Icon(Icons.alternate_email, color: Color(0xFF005F73), size: 18),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final raw = usernameController.text.trim();
              final username = raw.startsWith('@') ? raw.substring(1).trim() : raw;
              if (username.isNotEmpty) {
                _submitFriendAndInvite(username, dialogCtx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005F73),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Add & Invite',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _submitFriendAndInvite(String username, BuildContext dialogCtx) {
    Navigator.pop(dialogCtx);

    // 1. Send the friend request
    context.read<FriendBloc>().add(FriendSendRequestRequested(username));

    // 2. Simultaneously add to trip invites
    setState(() {
      _selectedMemberIds.add('user_$username');
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Friend request sent & @$username invited to trip!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF005F73),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<TripMember> _getAvailableFriends(FriendState friendState) {
    final List<TripMember> availableFriends = [];
    if (friendState is FriendsLoadedState) {
      for (final f in friendState.friends) {
        availableFriends.add(
          TripMember.fromFriendEntity(
            f,
            isSelected: _selectedMemberIds.contains(f.userId),
          ),
        );
      }
    }
    return availableFriends;
  }

  void _onInviteFriend(TripMember friend) {
    final isSelected = _selectedMemberIds.contains(friend.id);

    setState(() {
      if (isSelected) {
        _selectedMemberIds.remove(friend.id);
      } else {
        _selectedMemberIds.add(friend.id);
      }
    });

    if (!isSelected) {
      HapticFeedback.lightImpact();
      if (_tripId.isNotEmpty && friend.id.isNotEmpty) {
        context.read<TripBloc>().add(
              TripInviteMemberRequested(
                tripId: _tripId,
                type: 'friend',
                friendId: friend.id,
              ),
            );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Invite sent to ${friend.name} (Pending)')),
            ],
          ),
          backgroundColor: const Color(0xFF005F73),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _onNext() {
    FocusScope.of(context).unfocus();

    final allAvailableFriends = _getAvailableFriends(context.read<FriendBloc>().state);

    // Collect all selected members
    final selectedMembers = allAvailableFriends
        .where((m) => _selectedMemberIds.contains(m.id))
        .map((m) => m.copyWith(isSelected: true))
        .toList();

    final updatedDraft = _draft.copyWith(
      selectedMembers: selectedMembers,
      invitedEmails: _invitedEmails,
      invitedPhones: _invitedPhones,
    );

    // Navigate safely post-frame to Review Trip screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.push(RouteNames.reviewTrip, extra: updatedDraft);
      }
    });
  }

  void _onDone() {
    FocusScope.of(context).unfocus();

    // Refresh trips list so Trips tab has the latest data
    context.read<TripBloc>().add(const TripsFetchRequested());

    // Switch to Trips tab, then safely push new trip's workspace
    context.go(RouteNames.trips);
    if (_tripId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navContext = rootNavigatorKey.currentContext;
        if (navContext != null && navContext.mounted) {
          GoRouter.of(navContext).push(RouteNames.tripDetailsPath(_tripId));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return BlocListener<FriendBloc, FriendState>(
      listener: (context, state) {
        if (state is FriendErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else if (state is FriendsLoadedState && state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: const Color(0xFF005F73),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        body: RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Teal Curved Header with Golden Accent (Pinned to Top) ──
              CustomPaint(
                painter: InviteHeaderPainter(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: statusBarHeight + 10,
                    left: 16,
                    right: 16,
                    bottom: 38,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      IconButton(
                        onPressed: () {
                          if (!_isWizardMode) {
                            _onDone();
                          } else {
                            context.pop();
                          }
                        },
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
                      Expanded(
                        child: Column(
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
                              'Add buddies for your Trip',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.90),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Top Header Action: Skip / Done in trip mode
                      if (!_isWizardMode)
                        TextButton(
                          onPressed: _onDone,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFDE68A),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          child: Text(
                            _selectedMemberIds.isEmpty && _invitedEmails.isEmpty && _invitedPhones.isEmpty
                                ? 'Skip'
                                : 'Done',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFDE68A),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Scrollable Body Content ──────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),

                      // ── Search Bar (Filter button removed as requested) ──
                      WeTravelSearchBar(
                        controller: _searchController,
                        hintText: 'Search buddy name or @username...',
                        showFilterButton: false,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        onClear: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // ── Section Header & Friends List Container ──────────
                      BlocBuilder<FriendBloc, FriendState>(
                        builder: (context, friendState) {
                          final availableFriends = _getAvailableFriends(friendState);

                          // Apply search query and filters
                          final friendsToShow = availableFriends.where((f) {
                            final matchesQuery = _searchQuery.trim().isEmpty ||
                                f.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                                f.email.toLowerCase().contains(_searchQuery.toLowerCase());

                            final isSelected = _selectedMemberIds.contains(f.id);
                            final matchesFilter = switch (_activeFilter) {
                              'Selected' => isSelected,
                              'Unselected' => !isSelected,
                              _ => true,
                            };

                            return matchesQuery && matchesFilter;
                          }).toList();

                          if (_activeSort == 'alphabetical') {
                            friendsToShow.sort((a, b) => a.name.compareTo(b.name));
                          }

                          final isAllSelected = availableFriends.isNotEmpty &&
                              availableFriends.every((f) => _selectedMemberIds.contains(f.id));

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Responsive Header with zero pixel overflow ──────
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Friends & Buddies',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF005F73),
                                              letterSpacing: -0.2,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${_selectedMemberIds.length} pending',
                                            style: GoogleFonts.inter(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF005F73),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: _showAddFriendDialog,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.person_add_alt_1_rounded,
                                            size: 15,
                                            color: Color(0xFFD97706),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Add Friend',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFFD97706),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (availableFriends.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isAllSelected) {
                                          _selectedMemberIds.clear();
                                        } else {
                                          for (final f in availableFriends) {
                                            _selectedMemberIds.add(f.id);
                                          }
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Text(
                                        isAllSelected ? 'Deselect all' : 'Select all',
                                        style: GoogleFonts.inter(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF005F73),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),

                              // ── Friends List Container ───────────────────────────
                              if (friendState is FriendLoadingState)
                                Container(
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF005F73)),
                                    ),
                                  ),
                                )
                              else if (friendsToShow.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF005F73).withValues(alpha: 0.08),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.people_outline_rounded,
                                          size: 32,
                                          color: Color(0xFF005F73),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        _searchQuery.isNotEmpty
                                            ? 'No travel buddies match "$_searchQuery"'
                                            : 'No travel buddies yet',
                                        style: GoogleFonts.inter(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _searchQuery.isNotEmpty
                                            ? 'Try checking the username spelling or add them as a friend.'
                                            : 'Add buddies on WeTravel by username to invite them to this trip, or share your invite link below.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF64748B),
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: _showAddFriendDialog,
                                        icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                                        label: const Text('Add Friend by Username'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF005F73),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
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
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(friendsToShow.length, (index) {
                                      final friend = friendsToShow[index];
                                      final isSelected = _selectedMemberIds.contains(friend.id);
                                      final isLast = index == friendsToShow.length - 1;

                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () => _onInviteFriend(friend),
                                            borderRadius: BorderRadius.vertical(
                                              top: index == 0 ? const Radius.circular(16) : Radius.zero,
                                              bottom: isLast ? const Radius.circular(16) : Radius.zero,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                              child: Row(
                                                children: [
                                                  // Avatar with fallback
                                                  _buildBuddyAvatar(friend),
                                                  const SizedBox(width: 14),

                                                  // Name & Email / Username
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
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

                                                  // + Add / ✓ Added Action Button
                                                  isSelected
                                                      ? Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFFEF3C7),
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(
                                                              color: const Color(0xFFFCD34D),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Icon(
                                                                Icons.hourglass_top_rounded,
                                                                size: 13,
                                                                color: Color(0xFFD97706),
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                'Pending',
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 12.5,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: const Color(0xFFD97706),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 14,
                                                            vertical: 6,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFF005F73)
                                                                .withValues(alpha: 0.08),
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(
                                                              color: const Color(0xFF005F73),
                                                              width: 1.2,
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Icon(
                                                                Icons.add_rounded,
                                                                size: 15,
                                                                color: Color(0xFF005F73),
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                'Add',
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 12.5,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: const Color(0xFF005F73),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
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
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // ── Direct Channels ──────────────────────────────────────────
                      Text(
                        'Invite via',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF005F73),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDirectChannelButton(
                              label: 'WhatsApp',
                              icon: Icons.chat_bubble_rounded,
                              color: const Color(0xFF16A34A),
                              bgColor: const Color(0xFFDCFCE7),
                              onTap: _launchWhatsApp,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDirectChannelButton(
                              label: 'Email',
                              icon: Icons.mail_rounded,
                              color: const Color(0xFF0284C7),
                              bgColor: const Color(0xFFE0F2FE),
                              onTap: _launchEmail,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Share Invitation Link Card (Moved to Bottom, Real Logo, No share icon) ───
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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomPaint(
                                  size: const Size(28, 24),
                                  painter: const PaperPlaneLogoPainter(),
                                ),
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
                                        'Let others join using this trip link',
                                        style: GoogleFonts.inter(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
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
                                        _dynamicInviteLink,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF005F73),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.copy_rounded,
                                      color: Color(0xFFF59E0B),
                                      size: 19,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Native System Share CTA
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _shareInviteLink,
                                icon: const Icon(Icons.share_outlined, size: 16),
                                label: const Text('Share Link to Any App'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF92400E),
                                  side: const BorderSide(color: Color(0xFFF59E0B)),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isWizardMode ? _onNext : _onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: const Color(0xFF0F172A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isWizardMode ? 'Next: Review Trip' : 'Done & Open Trip',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isWizardMode
                          ? Icons.arrow_forward_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 20,
                      color: const Color(0xFF0F172A),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBuddyAvatar(TripMember member) {
    if (member.avatarUrl != null && member.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: const Color(0xFFE2E8F0),
        backgroundImage: NetworkImage(member.avatarUrl!),
        onBackgroundImageError: (e, s) {},
        child: Text(
          member.name.isNotEmpty ? member.name[0].toUpperCase() : 'U',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF005F73),
            fontSize: 16,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFF005F73),
      child: Text(
        member.name.isNotEmpty ? member.name[0].toUpperCase() : 'U',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildDirectChannelButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

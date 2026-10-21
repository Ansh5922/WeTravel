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
import '../widgets/join_trip_dialog.dart';

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
  String _activeFilter = 'All'; // 'All', 'Selected', 'Unselected'
  String _activeSort = 'suggested'; // 'suggested', 'alphabetical'

  @override
  void initState() {
    super.initState();
    _draft = widget.draft ?? TripReviewDraft.initial();

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
                'Invite link copied to clipboard! Share it with your group.',
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
              'Add Friend',
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
              'Enter username to send an instant friend request on WeTravel:',
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
                final username = val.trim();
                if (username.isNotEmpty) {
                  context.read<FriendBloc>().add(FriendSendRequestRequested(username));
                  Navigator.pop(dialogCtx);
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
              final username = usernameController.text.trim();
              if (username.isNotEmpty) {
                context.read<FriendBloc>().add(FriendSendRequestRequested(username));
                Navigator.pop(dialogCtx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005F73),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Send Request',
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
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
              Expanded(child: Text('${friend.name} added to $_tripName!')),
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
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top Teal Curved Header with Golden Accent ───────────────
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
                                _tripName.isNotEmpty
                                    ? 'Add buddies for your trip to $_tripName'
                                    : 'Add your travel buddies to plan together.',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white.withValues(alpha: 0.90),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Top Header Action: Next (in wizard mode) or Done (standalone)
                        TextButton(
                          onPressed: _isWizardMode ? _onNext : _onDone,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFDE68A),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                          child: Text(
                            _isWizardMode ? 'Next' : 'Done',
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

                // ── Main Content Area ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      if (_isWizardMode) ...[
                        // ── Step Indicator Pill: "02 Add Buddies" ───────────────
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F3F5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFBCE3E8),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF004E64),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '02',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add Buddies',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF004E64),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ── Search & Filter Input Bar ────────────────────────
                      WeTravelSearchBar(
                        controller: _searchController,
                        hintText: 'Search buddy name or @username...',
                        hasActiveFilter: _activeFilter != 'All' || _activeSort != 'suggested',
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
                        onFilterTap: () => _showFilterSheet(context),
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
                                            color: const Color(0xFFE8F3F5),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${_selectedMemberIds.length} selected',
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
                                                            color: const Color(0xFFDCFCE7),
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(
                                                              color: const Color(0xFF86EFAC),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Icon(
                                                                Icons.check_rounded,
                                                                size: 14,
                                                                color: Color(0xFF16A34A),
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                'Added',
                                                                style: GoogleFonts.inter(
                                                                  fontSize: 12.5,
                                                                  fontWeight: FontWeight.w700,
                                                                  color: const Color(0xFF16A34A),
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

                      // ── Share Invitation Link Card ───────────────────────
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
                                IconButton(
                                  onPressed: _shareInviteLink,
                                  tooltip: 'Share via Apps',
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

                      const SizedBox(height: 18),

                      const SizedBox(height: 12),

                      // Enter Invite Link / Join Trip Row
                      InkWell(
                        onTap: () => showJoinTripDialog(context),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F3F5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFBCE3E8)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF005F73),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.link_rounded, color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Have an invite link?',
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF005F73),
                                      ),
                                    ),
                                    Text(
                                      'Paste link or enter code to join another trip ➔',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: const Color(0xFF005F73).withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── Direct WhatsApp & Email Channels ─────────────────
                      Text(
                        'Direct Channels',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF005F73),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // WhatsApp Direct Action Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDCFCE7),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.chat_bubble_rounded, color: Color(0xFF16A34A), size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Invite via WhatsApp',
                                    style: GoogleFonts.inter(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Opens WhatsApp directly. Choose any friend or group to send the link.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B),
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _launchWhatsApp,
                              icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                              label: const Text('Open'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Email Direct Action Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE0F2FE),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.mail_rounded, color: Color(0xFF0284C7), size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Invite via Email',
                                    style: GoogleFonts.inter(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Opens your mail app with link pre-filled. Select contacts from address book.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B),
                                      height: 1.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: _launchEmail,
                              icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                              label: const Text('Open'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0284C7),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 26),

                      // ── Bottom Action Button ─────────────────────────────
                      SizedBox(
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

                      // ── Bottom Decorative Leaves and Dotted Trail ─────────
                      const InviteBottomDecorator(),

                      const SizedBox(height: 12),
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

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter & Sort Buddies',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (_activeFilter != 'All' || _activeSort != 'suggested')
                          GestureDetector(
                            onTap: () {
                              setModalState(() {
                                _activeFilter = 'All';
                                _activeSort = 'suggested';
                              });
                              setState(() {});
                            },
                            child: Text(
                              'Reset',
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0D9488),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'STATUS',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        {'label': 'All Buddies', 'value': 'All'},
                        {'label': 'Selected Only', 'value': 'Selected'},
                        {'label': 'Not Selected', 'value': 'Unselected'},
                      ].map((item) {
                        final isSelected = _activeFilter == item['value'];
                        return ChoiceChip(
                          label: Text(item['label']!),
                          selected: isSelected,
                          selectedColor: const Color(0xFF005F73),
                          backgroundColor: const Color(0xFFF1F5F9),
                          labelStyle: GoogleFonts.inter(
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF005F73) : Colors.transparent,
                            ),
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              _activeFilter = item['value']!;
                            });
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'SORT BY',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        {'label': 'Suggested', 'value': 'suggested'},
                        {'label': 'Alphabetical (A–Z)', 'value': 'alphabetical'},
                      ].map((sortItem) {
                        final isSelected = _activeSort == sortItem['value'];
                        return ChoiceChip(
                          label: Text(sortItem['label']!),
                          selected: isSelected,
                          selectedColor: const Color(0xFFF59E0B),
                          backgroundColor: const Color(0xFFF1F5F9),
                          labelStyle: GoogleFonts.inter(
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFFF59E0B) : Colors.transparent,
                            ),
                          ),
                          onSelected: (selected) {
                            setModalState(() {
                              _activeSort = sortItem['value']!;
                            });
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005F73),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(
                          'Apply Filters',
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

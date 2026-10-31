import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/we_travel_filter_chips.dart';
import '../../domain/entities/friend_entity.dart';
import '../bloc/friend_bloc.dart';
import '../bloc/friend_event.dart';
import '../bloc/friend_state.dart';
import 'add_friend_sheet.dart';
import 'friend_card.dart';
import 'friend_request_card.dart';
import 'sent_friend_request_card.dart';

enum FriendsFilterTab { all, buddies, requests, sent }

/// The interactive Friends View containing pending requests, search,
/// buddy list, and the "+ Add Friend" action.
class FriendsListView extends StatefulWidget {
  const FriendsListView({super.key});

  @override
  State<FriendsListView> createState() => _FriendsListViewState();
}

class _FriendsListViewState extends State<FriendsListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  FriendsFilterTab _activeFilter = FriendsFilterTab.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FriendBloc>().add(const FriendsFetchRequested());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FriendEntity> _filterFriends(List<FriendEntity> friends) {
    if (_searchQuery.isEmpty) return friends;
    final q = _searchQuery.toLowerCase();
    return friends.where((f) {
      return f.fullName.toLowerCase().contains(q) ||
          f.username.toLowerCase().contains(q);
    }).toList();
  }

  List<SentFriendRequestEntity> _filterSentRequests(List<SentFriendRequestEntity> requests) {
    if (_searchQuery.isEmpty) return requests;
    final q = _searchQuery.toLowerCase();
    return requests.where((r) {
      return r.receiverFullName.toLowerCase().contains(q) ||
          r.receiverUsername.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FriendBloc, FriendState>(
      listener: (context, state) {
        if (state is FriendsLoadedState && state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.successMessage!,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF004E64),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      builder: (context, state) {
        final friends = state is FriendsLoadedState ? state.friends : <FriendEntity>[];
        final pendingRequests =
            state is FriendsLoadedState ? state.pendingRequests : <FriendRequestEntity>[];
        final sentRequests =
            state is FriendsLoadedState ? state.sentRequests : <SentFriendRequestEntity>[];
        final filteredFriends = _filterFriends(friends);
        final filteredSentRequests = _filterSentRequests(sentRequests);
        final isLoading = state is FriendLoadingState && friends.isEmpty;

        return Column(
          children: [
            // ── 1. Full-Width Search Bar & Filter Chips ─────────────────
            Container(
              color: const Color(0xFFFAF9F6),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search friends by name or @handle...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: Color(0xFF64748B),
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  WeTravelFilterChips<FriendsFilterTab>(
                    selectedValue: _activeFilter,
                    onSelected: (val) {
                      setState(() {
                        _activeFilter = val;
                      });
                    },
                    items: [
                      FilterChipItem(
                        value: FriendsFilterTab.all,
                        label: 'All',
                        count: friends.length + pendingRequests.length + sentRequests.length,
                      ),
                      FilterChipItem(
                        value: FriendsFilterTab.buddies,
                        label: 'Buddies',
                        count: friends.length,
                      ),
                      FilterChipItem(
                        value: FriendsFilterTab.requests,
                        label: 'Requests',
                        count: pendingRequests.length,
                      ),
                      FilterChipItem(
                        value: FriendsFilterTab.sent,
                        label: 'Sent',
                        count: sentRequests.length,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── 2. Content List with Pull-to-Refresh ─────────────────
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF004E64),
                backgroundColor: Colors.white,
                onRefresh: () async {
                  context.read<FriendBloc>().add(const FriendsFetchRequested());
                  await Future.delayed(const Duration(milliseconds: 600));
                },
                child: Builder(
                  builder: (context) {
                    if (isLoading) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 4,
                        itemBuilder: (context, index) => _buildSkeletonCard(),
                      );
                    }

                    if (state is FriendErrorState && friends.isEmpty) {
                      return _buildErrorState(state.message);
                    }

                    final hasNoContent = friends.isEmpty && pendingRequests.isEmpty && sentRequests.isEmpty;
                    if (hasNoContent) {
                      return _buildEmptyNetworkState();
                    }

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 96),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      children: [
                        // ── Pending Requests Section ───────────────────
                        if ((_activeFilter == FriendsFilterTab.all ||
                                _activeFilter == FriendsFilterTab.requests) &&
                            pendingRequests.isNotEmpty) ...[
                          Row(
                            children: [
                              Text(
                                'Pending Requests',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF004E64),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${pendingRequests.length}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...pendingRequests.map(
                            (req) => FriendRequestCard(
                              request: req,
                              onAccept: () {
                                context.read<FriendBloc>().add(
                                      FriendRespondRequestRequested(
                                        friendshipId: req.id,
                                        action: 'accept',
                                      ),
                                    );
                              },
                              onDecline: () {
                                context.read<FriendBloc>().add(
                                      FriendRespondRequestRequested(
                                        friendshipId: req.id,
                                        action: 'reject',
                                      ),
                                    );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ] else if (_activeFilter == FriendsFilterTab.requests &&
                            pendingRequests.isEmpty) ...[
                          _buildNoPendingRequestsNotice(),
                          const SizedBox(height: 16),
                        ],

                        // ── Sent Friend Requests Section ─────────────────
                        if ((_activeFilter == FriendsFilterTab.all ||
                                _activeFilter == FriendsFilterTab.sent) &&
                            filteredSentRequests.isNotEmpty) ...[
                          Row(
                            children: [
                              Text(
                                'Sent Requests',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF004E64),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDEF2F1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${filteredSentRequests.length}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF004E64),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...filteredSentRequests.map(
                            (req) => SentFriendRequestCard(request: req),
                          ),
                          const SizedBox(height: 16),
                        ] else if (_activeFilter == FriendsFilterTab.sent &&
                            filteredSentRequests.isEmpty) ...[
                          _buildNoSentRequestsNotice(),
                          const SizedBox(height: 16),
                        ],

                        // ── Accepted Friends Section ───────────────────
                        if (_activeFilter == FriendsFilterTab.all ||
                            _activeFilter == FriendsFilterTab.buddies) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'My Travel Buddies',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF004E64),
                                ),
                              ),
                              Text(
                                '${filteredFriends.length} ${filteredFriends.length == 1 ? 'friend' : 'friends'}',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                        if (filteredFriends.isEmpty && _searchQuery.isNotEmpty)
                          _buildNoSearchMatch()
                        else if (filteredFriends.isEmpty)
                          _buildNoFriendsNotice()
                        else
                          ...filteredFriends.map(
                            (friend) => FriendCard(
                              friend: friend,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoSentRequestsNotice() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF004E64).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.send_rounded,
              size: 24,
              color: Color(0xFF004E64),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No Sent Requests',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'When you send a friend request to a fellow traveler, its pending or accepted status will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPendingRequestsNotice() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF004E64).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 26,
              color: Color(0xFF004E64),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No Pending Requests',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You are all caught up! When someone sends you a friend request, it will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: const Color(0xFF64748B),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyNetworkState() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFDEF2F1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.people_outline_rounded,
                color: Color(0xFF004E64),
                size: 42,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'No Travel Buddies Yet',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connect with friends using their @username to coordinate trips, collaborate on itineraries, and settle group expenses together.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            color: const Color(0xFF64748B),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => AddFriendSheet.show(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004E64),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.person_add_rounded, size: 20),
            label: Text(
              'Add Your First Buddy',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoSearchMatch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.person_search_rounded, size: 38, color: Color(0xFF94A3B8)),
            const SizedBox(height: 10),
            Text(
              'No friends match "$_searchQuery"',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFriendsNotice() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF004E64), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You have no accepted friends yet. Tap "+ Add" above to connect!',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      children: [
        const Center(
          child: Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFFEF4444)),
        ),
        const SizedBox(height: 14),
        Text(
          'Unable to load friends',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              context.read<FriendBloc>().add(const FriendsFetchRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004E64),
            ),
            child: const Text('Try Again'),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/we_travel_screen_header.dart';
import '../../../inbox/presentation/bloc/inbox_bloc.dart';
import '../../../inbox/presentation/bloc/inbox_state.dart';
import '../../../inbox/presentation/pages/inbox_page.dart';
import '../../../trips/presentation/widgets/join_trip_dialog.dart';
import '../bloc/friend_bloc.dart';
import '../bloc/friend_state.dart';
import '../widgets/add_friend_sheet.dart';
import '../widgets/friends_list_view.dart';

/// The Friends & Social tab inside the main authenticated shell.
/// Features a unified curved header, floating segmented pill tab bar
/// switching between "Trip Invites" (left, default) and "Friends" (right),
/// live request badges, and quick-action bottom-right Floating Action Buttons.
class FriendsPage extends StatefulWidget {
  final int initialTab;

  const FriendsPage({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              heroTag: 'joinTripFabInbox',
              onPressed: () => showJoinTripDialog(context),
              backgroundColor: const Color(0xFF004E64),
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.group_add_rounded, size: 20),
              label: Text(
                'Join a Trip',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            )
          : FloatingActionButton.extended(
              heroTag: 'addFriendFab',
              onPressed: () => AddFriendSheet.show(context),
              backgroundColor: const Color(0xFF004E64),
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.person_add_rounded, size: 20),
              label: Text(
                'Add Friend',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
      body: Column(
        children: [
          // ── 1. Curved Scenic Top Header ──────────────────────────────
          WeTravelScreenHeader(
            title: _tabController.index == 0 ? 'Trip Invites' : 'Travel Buddies',
            showMenuButton: false,
          ),

          // ── 2. Floating Segmented Pill Tab Bar ────────────────────────
          _buildSegmentedTabBar(),

          // ── 3. Tab Views Content ─────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Tab 0 (Left): Trip Invitations & join via token
                InboxPage(isEmbedded: true),

                // Tab 1 (Right): Real Friends network, pending requests, live search
                FriendsListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Floating pill segmented tab bar matching WeTravel's design system
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
      child: BlocBuilder<FriendBloc, FriendState>(
        builder: (context, friendState) {
          final pendingFriendCount = friendState is FriendsLoadedState
              ? friendState.pendingRequests.length
              : 0;

          return BlocBuilder<InboxBloc, InboxState>(
            builder: (context, inboxState) {
              final pendingInviteCount = inboxState is InboxLoadedState
                  ? inboxState.pendingCount
                  : 0;

              return Row(
                children: [
                  _buildSegmentItem(
                    index: 0,
                    title: 'Trip Invites',
                    icon: Icons.mail_outline_rounded,
                    badgeCount: pendingInviteCount,
                  ),
                  _buildSegmentItem(
                    index: 1,
                    title: 'Friends',
                    icon: Icons.people_rounded,
                    badgeCount: pendingFriendCount,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSegmentItem({
    required int index,
    required String title,
    required IconData icon,
    int badgeCount = 0,
  }) {
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
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.primaryDeepTeal,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentWarmYellow : const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/friends/presentation/bloc/friend_bloc.dart';
import '../../features/friends/presentation/bloc/friend_event.dart';
import '../../features/friends/presentation/bloc/friend_state.dart';
import '../../features/inbox/presentation/bloc/inbox_bloc.dart';
import '../../features/inbox/presentation/bloc/inbox_event.dart';
import '../../features/inbox/presentation/bloc/inbox_state.dart';
import '../router/route_names.dart';
import 'we_travel_bottom_nav_bar.dart';
import 'we_travel_drawer.dart';

/// Application shell providing the persistent bottom navigation bar and sidebar drawer
/// across the primary authenticated branches (Home, Trips, Friends, Profile).
class AppShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({
    super.key,
    required this.navigationShell,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InboxBloc>().add(const InboxFetchRequested());
        context.read<FriendBloc>().add(const FriendsFetchRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final inboxState = context.watch<InboxBloc>().state;
    final friendState = context.watch<FriendBloc>().state;

    final int pendingInvites =
        inboxState is InboxLoadedState ? inboxState.pendingCount : 0;
    final int pendingFriends = friendState is FriendsLoadedState
        ? friendState.pendingRequests.length
        : 0;
    final bool hasUnreadOrPending = (pendingInvites + pendingFriends) > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      drawer: const WeTravelDrawer(),
      body: widget.navigationShell,
      bottomNavigationBar: WeTravelBottomNavBar(
        currentIndex: widget.navigationShell.currentIndex,
        hasInboxNotification: hasUnreadOrPending,
        onTabSelected: (int index) {
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        onAddTap: () {
          context.push(RouteNames.createTrip);
        },
      ),
    );
  }
}


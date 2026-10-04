import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/route_names.dart';
import 'we_travel_bottom_nav_bar.dart';

/// Application shell providing the persistent bottom navigation bar
/// across the primary authenticated branches (Home, Trips, Friends, Profile).
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: navigationShell,
      bottomNavigationBar: WeTravelBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTabSelected: (int index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        onAddTap: () {
          context.push(RouteNames.createTrip);
        },
      ),
    );
  }
}

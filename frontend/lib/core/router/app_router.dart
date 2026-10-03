import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'route_names.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/preferences/presentation/pages/preferences_page.dart';
import '../../features/friends/presentation/pages/friends_page.dart';
import '../../features/trips/presentation/pages/trips_page.dart';
import '../../features/trip_details/presentation/pages/trip_details_page.dart';
import '../../features/itinerary/presentation/pages/itinerary_page.dart';
import '../../features/group_chat/presentation/pages/group_chat_page.dart';
import '../../features/polls/presentation/pages/polls_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/memories/presentation/pages/memories_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: RouteNames.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: RouteNames.auth,
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: RouteNames.profile,
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: RouteNames.preferences,
      builder: (context, state) => const PreferencesPage(),
    ),
    GoRoute(
      path: RouteNames.friends,
      builder: (context, state) => const FriendsPage(),
    ),
    GoRoute(
      path: RouteNames.trips,
      builder: (context, state) => const TripsPage(),
    ),
    GoRoute(
      path: RouteNames.tripDetails,
      builder: (context, state) => const TripDetailsPage(),
    ),
    GoRoute(
      path: RouteNames.itinerary,
      builder: (context, state) => const ItineraryPage(),
    ),
    GoRoute(
      path: RouteNames.groupChat,
      builder: (context, state) => const GroupChatPage(),
    ),
    GoRoute(
      path: RouteNames.polls,
      builder: (context, state) => const PollsPage(),
    ),
    GoRoute(
      path: RouteNames.expenses,
      builder: (context, state) => const ExpensesPage(),
    ),
    GoRoute(
      path: RouteNames.memories,
      builder: (context, state) => const MemoriesPage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);

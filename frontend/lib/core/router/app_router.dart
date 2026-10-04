import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'auth_guard.dart';
import 'route_names.dart';
import '../widgets/app_shell.dart';

// Feature Pages
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/trips/presentation/pages/trips_page.dart';
import '../../features/trips/presentation/pages/create_trip_page.dart';
import '../../features/trips/presentation/pages/invite_members_page.dart';
import '../../features/trips/presentation/pages/review_trip_page.dart';
import '../../features/trips/domain/entities/trip_review_draft.dart';
import '../../features/friends/presentation/pages/friends_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/preferences/presentation/pages/preferences_page.dart';
import '../../features/preferences/presentation/pages/my_preferences_page.dart';
import '../../features/trip_details/presentation/pages/trip_details_page.dart';
import '../../features/trip_details/presentation/pages/add_suggestion_page.dart';
import '../../features/trip_details/presentation/pages/suggestion_detail_page.dart';
import '../../features/trip_details/presentation/pages/ai_insights_page.dart';
import '../../features/trip_details/domain/entities/trip_suggestion.dart';
import '../../features/itinerary/presentation/pages/itinerary_page.dart';
import '../../features/itinerary/presentation/pages/plans_alternatives_page.dart';
import '../../features/group_chat/presentation/pages/group_chat_page.dart';
import '../../features/polls/presentation/pages/polls_page.dart';
import '../../features/polls/presentation/pages/voting_collaboration_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/memories/presentation/pages/memories_page.dart';
import '../../features/inbox/presentation/pages/invitation_details_page.dart';
import '../../features/inbox/presentation/pages/invitation_success_page.dart';
import '../../features/inbox/domain/entities/trip_invitation.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> _shellNavigatorTripsKey = GlobalKey<NavigatorState>(debugLabel: 'shellTrips');
final GlobalKey<NavigatorState> _shellNavigatorFriendsKey = GlobalKey<NavigatorState>(debugLabel: 'shellFriends');
final GlobalKey<NavigatorState> _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

/// WeTravel central GoRouter configuration.
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: false,
  refreshListenable: authNotifierListenable,
  redirect: (BuildContext context, GoRouterState state) {
    return AuthGuard.evaluateRedirect(
      state: authNotifierListenable.value,
      location: state.uri.path,
    );
  },
  routes: [
    // ── Redirect Root to Splash ───────────────────────────────────────────────
    GoRoute(
      path: '/',
      redirect: (context, state) => RouteNames.splash,
    ),

    // ── Public & Onboarding Routes ────────────────────────────────────────────
    GoRoute(
      path: RouteNames.splash,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: RouteNames.onboarding,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: RouteNames.login,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.signup,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SignupPage(),
    ),

    // ── Stateful Navigation Shell (Primary Authenticated Tabs) ────────────────
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: RouteNames.home,
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),

        // Tab 2: Trips
        StatefulShellBranch(
          navigatorKey: _shellNavigatorTripsKey,
          routes: [
            GoRoute(
              path: RouteNames.trips,
              builder: (context, state) => const TripsPage(),
            ),
          ],
        ),

        // Tab 3: Friends
        StatefulShellBranch(
          navigatorKey: _shellNavigatorFriendsKey,
          routes: [
            GoRoute(
              path: RouteNames.friends,
              builder: (context, state) => const FriendsPage(),
            ),
          ],
        ),

        // Tab 4: Profile
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: RouteNames.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),

    // ── Preferences Routes ───────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.preferences,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const PreferencesPage(),
    ),
    GoRoute(
      path: RouteNames.myPreferences,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const MyPreferencesPage(),
    ),

    // ── Create Trip Route ─────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.createTrip,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const CreateTripPage(),
    ),

    // ── Invite Members Route ──────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.inviteMembers,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final draft = state.extra as TripReviewDraft?;
        return InviteMembersPage(draft: draft);
      },
    ),

    // ── Review Trip Route ─────────────────────────────────────────────────────
    GoRoute(
      path: RouteNames.reviewTrip,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final draft = state.extra as TripReviewDraft?;
        return ReviewTripPage(draft: draft);
      },
    ),

    // ── Invitation Details Route ──────────────────────────────────────────────
    GoRoute(
      path: RouteNames.invitationDetails,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra;
        final TripInvitation invitation = extra is TripInvitation
            ? extra
            : TripInvitation.initialInvitations.first;
        return InvitationDetailsPage(invitation: invitation);
      },
    ),

    // ── Invitation Success Route ("You're In!") ───────────────────────────────
    GoRoute(
      path: RouteNames.invitationSuccess,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra;
        final TripInvitation invitation = extra is TripInvitation
            ? extra
            : TripInvitation.initialInvitations.first;
        return InvitationSuccessPage(invitation: invitation);
      },
    ),

    // ── Trip Details & Sub-Feature Routes (Pushed to Root Navigator) ──────────
    GoRoute(
      path: RouteNames.tripDetails,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final tripId = state.pathParameters['tripId'] ?? '';
        return TripDetailsPage(tripId: tripId);
      },
      routes: [
        GoRoute(
          path: 'itinerary',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final tripId = state.pathParameters['tripId'] ?? '';
            return ItineraryPage(tripId: tripId);
          },
        ),
        GoRoute(
          path: 'chat',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final tripId = state.pathParameters['tripId'] ?? '';
            return GroupChatPage(tripId: tripId);
          },
        ),
        GoRoute(
          path: 'polls',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final tripId = state.pathParameters['tripId'] ?? '';
            return PollsPage(tripId: tripId);
          },
        ),
        GoRoute(
          path: 'expenses',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final tripId = state.pathParameters['tripId'] ?? '';
            return ExpensesPage(tripId: tripId);
          },
        ),
        GoRoute(
          path: 'memories',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final tripId = state.pathParameters['tripId'] ?? '';
            return MemoriesPage(tripId: tripId);
          },
        ),
        GoRoute(
          path: 'add-suggestion',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final tripId = state.pathParameters['tripId'] ?? '';
            return AddSuggestionPage(tripId: tripId);
          },
        ),
        GoRoute(
          path: 'suggestion-detail',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final tripId = state.pathParameters['tripId'] ?? '';
            final suggestion = state.extra as TripSuggestion?;
            return SuggestionDetailPage(
              tripId: tripId,
              suggestion: suggestion,
            );
          },
        ),
        GoRoute(
          path: 'ai-insights',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final tripId = state.pathParameters['tripId'] ?? '';
            return AiInsightsPage(tripId: tripId);
          },
        ),
        GoRoute(
          path: 'plans-alternatives',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final tripId = state.pathParameters['tripId'] ?? '';
            return PlansAlternativesPage(tripId: tripId);
          },
        ),
        GoRoute(
          path: 'voting-collaboration',
          parentNavigatorKey: rootNavigatorKey,
          builder: (context, state) {
            final tripId = state.pathParameters['tripId'] ?? '';
            return VotingCollaborationPage(tripId: tripId);
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/router/auth_guard.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/core/widgets/app_shell.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:frontend/features/splash/presentation/pages/splash_page.dart';
import 'package:frontend/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/home/presentation/pages/home_page.dart';
import 'package:frontend/features/trips/presentation/pages/trips_page.dart';
import 'package:frontend/features/friends/presentation/pages/friends_page.dart';
import 'package:frontend/features/profile/presentation/pages/profile_page.dart';
import 'package:frontend/features/trip_details/presentation/pages/trip_details_page.dart';
import 'package:frontend/features/itinerary/presentation/pages/itinerary_page.dart';
import 'package:frontend/features/group_chat/presentation/pages/group_chat_page.dart';
import 'package:frontend/features/polls/presentation/pages/polls_page.dart';
import 'package:frontend/features/expenses/presentation/pages/expenses_page.dart';
import 'package:frontend/features/memories/presentation/pages/memories_page.dart';

class RouterTestAuthController extends AuthController {
  final AuthState initial;
  RouterTestAuthController([this.initial = const AuthInitial()]);

  @override
  AuthState build() => initial;

  @override
  Future<void> initialize() async {}
}

void main() {
  Widget createTestWidget({AuthState authState = const AuthUnauthenticated()}) {
    authNotifierListenable.value = authState;
    return ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(
          () => RouterTestAuthController(authState),
        ),
      ],
      child: const WeTravelApp(autoInitialize: false),
    );
  }

  const authenticatedState = AuthAuthenticated(
    UserEntity(id: 'test_user', email: 'test@wetravel.test'),
  );

  testWidgets('1. Splash route opens on initial launch', (tester) async {
    await tester.pumpWidget(createTestWidget(authState: const AuthInitial()));
    appRouter.go(RouteNames.splash);
    await tester.pumpAndSettle();

    expect(find.byType(SplashPage), findsOneWidget);
  });

  testWidgets('2. Onboarding route opens', (tester) async {
    await tester.pumpWidget(createTestWidget(authState: const AuthUnauthenticated()));
    appRouter.go(RouteNames.onboarding);
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingPage), findsOneWidget);
  });

  testWidgets('3. Login route opens', (tester) async {
    await tester.pumpWidget(createTestWidget(authState: const AuthUnauthenticated()));
    appRouter.go(RouteNames.login);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('4. Navigation shell and Home route open', (tester) async {
    await tester.pumpWidget(createTestWidget(authState: authenticatedState));
    appRouter.go(RouteNames.home);
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('5. Navigation shell switches between tabs (Trips, Friends, Profile)', (tester) async {
    await tester.pumpWidget(createTestWidget(authState: authenticatedState));
    appRouter.go(RouteNames.trips);
    await tester.pumpAndSettle();

    expect(find.byType(TripsPage), findsOneWidget);

    appRouter.go(RouteNames.friends);
    await tester.pumpAndSettle();
    expect(find.byType(FriendsPage), findsOneWidget);

    appRouter.go(RouteNames.profile);
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);
  });

  testWidgets('6. Trip details route accepts :tripId', (tester) async {
    const testTripId = 'trip-tokyo-2026';
    await tester.pumpWidget(createTestWidget(authState: authenticatedState));
    appRouter.go(RouteNames.tripDetailsPath(testTripId));
    await tester.pumpAndSettle();

    expect(find.byType(TripDetailsPage), findsOneWidget);
    expect(find.text('Trip Details ($testTripId)'), findsOneWidget);
  });

  testWidgets('7. Nested trip routes work for itinerary, chat, polls, expenses, memories', (tester) async {
    const testTripId = 'trip-bali-101';
    await tester.pumpWidget(createTestWidget(authState: authenticatedState));

    // Itinerary
    appRouter.go(RouteNames.itineraryPath(testTripId));
    await tester.pumpAndSettle();
    expect(find.byType(ItineraryPage), findsOneWidget);
    expect(find.text('Itinerary ($testTripId)'), findsOneWidget);

    // Chat
    appRouter.go(RouteNames.chatPath(testTripId));
    await tester.pumpAndSettle();
    expect(find.byType(GroupChatPage), findsOneWidget);
    expect(find.text('Group Chat ($testTripId)'), findsOneWidget);

    // Polls
    appRouter.go(RouteNames.pollsPath(testTripId));
    await tester.pumpAndSettle();
    expect(find.byType(PollsPage), findsOneWidget);
    expect(find.text('Polls ($testTripId)'), findsOneWidget);

    // Expenses
    appRouter.go(RouteNames.expensesPath(testTripId));
    await tester.pumpAndSettle();
    expect(find.byType(ExpensesPage), findsOneWidget);
    expect(find.text('Expenses ($testTripId)'), findsOneWidget);

    // Memories
    appRouter.go(RouteNames.memoriesPath(testTripId));
    await tester.pumpAndSettle();
    expect(find.byType(MemoriesPage), findsOneWidget);
    expect(find.text('Memories ($testTripId)'), findsOneWidget);
  });
}

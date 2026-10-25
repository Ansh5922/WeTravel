import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/router/auth_guard.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import 'package:frontend/features/auth/presentation/bloc/auth_state.dart';
import 'package:frontend/features/trips/domain/entities/trip_entity.dart';
import 'package:frontend/features/trips/domain/entities/trip_member.dart';
import 'package:frontend/features/trips/domain/entities/trip_review_draft.dart';
import 'package:frontend/features/trips/presentation/bloc/trip_bloc.dart';
import 'package:frontend/features/trips/presentation/bloc/trip_state.dart';
import 'package:frontend/features/trip_details/presentation/pages/trip_details_page.dart';
import 'package:frontend/features/trips/presentation/pages/create_trip_page.dart';
import 'package:frontend/features/trips/presentation/pages/invite_members_page.dart';
import 'package:frontend/features/trips/presentation/pages/review_trip_page.dart';
import 'package:frontend/features/trips/presentation/pages/trips_page.dart';

void main() {
  const testUser = UserEntity(id: 'test_user_id', email: 'test@wetravel.test');

  setUp(() {
    authNotifierListenable.value = const AuthAuthenticatedState(user: testUser);
  });

  testWidgets('CreateTripPage renders Next: Review Trip button for Step 1 of wizard', (tester) async {
    await tester.pumpWidget(const WeTravelApp(autoInitialize: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    appRouter.push(RouteNames.createTrip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(CreateTripPage), findsOneWidget);

    // Verify wizard Step 1 CTA is 'Next: Review Trip'
    expect(find.widgetWithText(ElevatedButton, 'Next: Review Trip'), findsOneWidget);
  });

  testWidgets('CreateTripPage validates empty destination when Next: Review Trip is tapped', (tester) async {
    await tester.pumpWidget(const WeTravelApp(autoInitialize: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    appRouter.push(RouteNames.createTrip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap Next: Review Trip with empty destination
    final continueBtn = find.widgetWithText(ElevatedButton, 'Next: Review Trip');
    await tester.tap(continueBtn);
    await tester.pump();

    // Verify validation snackbar is shown
    expect(find.text('Please enter a valid destination.'), findsOneWidget);
  });

  testWidgets('CreateTripPage navigates to ReviewTripPage upon Next: Review Trip with destination filled', (tester) async {
    await tester.pumpWidget(const WeTravelApp(autoInitialize: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    appRouter.push(RouteNames.createTrip);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Enter destination
    final destinationField = find.byType(TextField).first;
    await tester.enterText(destinationField, 'Goa, India');
    await tester.pump();

    // Tap Next: Review Trip
    final continueBtn = find.widgetWithText(ElevatedButton, 'Next: Review Trip');
    await tester.tap(continueBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify Step 2: ReviewTripPage is displayed
    expect(find.byType(ReviewTripPage), findsOneWidget);
    expect(find.text('Review Trip'), findsWidgets);
    expect(find.text('Goa, India'), findsWidgets);
    expect(find.widgetWithText(OutlinedButton, 'Edit'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Create Trip'), findsOneWidget);
  });

  testWidgets('TripsPage correctly handles TripCreatedState without infinite loop', (tester) async {
    await tester.pumpWidget(const WeTravelApp(autoInitialize: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    appRouter.go(RouteNames.trips);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(TripsPage), findsOneWidget);

    // Simulate TripCreatedState emission
    final trip = TripEntity(
      id: 'test-trip-999',
      name: 'Shimla Snow Trip',
      createdBy: 'test_user_id',
      status: 'planning',
      members: const [],
      createdAt: DateTime.now(),
    );

    final tripBloc = rootNavigatorKey.currentContext!.read<TripBloc>();
    tripBloc.emit(TripCreatedState(trip: trip, message: 'Created successfully'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify trip is now shown in Trips list
    expect(find.text('Shimla Snow Trip'), findsOneWidget);
  });

  testWidgets('ReviewTripPage finalizes trip creation and navigates cleanly', (tester) async {
    await tester.pumpWidget(const WeTravelApp(autoInitialize: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final draft = TripReviewDraft(
      destination: 'Goa, India',
      startDate: DateTime(2026, 11, 10),
      endDate: DateTime(2026, 11, 15),
      budget: '₹20k–₹30k',
      tripStyle: 'Beach + Food',
      selectedMembers: [
        TripMember(id: 'friend-uuid-1', name: 'Aarav Patel', email: '@aarav', isSelected: true),
      ],
    );

    appRouter.push(RouteNames.reviewTrip, extra: draft);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ReviewTripPage), findsOneWidget);

    final trip = TripEntity(
      id: 'goa-getaway',
      name: 'Goa, India',
      createdBy: 'test_user_id',
      status: 'planning',
      members: const [],
      createdAt: DateTime.now(),
    );

    final tripBloc = rootNavigatorKey.currentContext!.read<TripBloc>();
    tripBloc.emit(TripCreatedState(trip: trip, message: 'Created successfully'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Navigates to InviteMembersPage with the created trip
    expect(find.byType(InviteMembersPage), findsOneWidget);
    expect(find.text('Invite Members'), findsWidgets);
    expect(find.widgetWithText(ElevatedButton, 'Done & Open Trip'), findsOneWidget);

    // Tap Done & Open Trip
    final doneBtn = find.widgetWithText(ElevatedButton, 'Done & Open Trip');
    await tester.tap(doneBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(TripDetailsPage), findsOneWidget);
  });
}

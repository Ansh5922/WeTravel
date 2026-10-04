import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:frontend/features/onboarding/presentation/widgets/onboarding_visual_one.dart';
import 'package:frontend/features/onboarding/presentation/widgets/onboarding_visual_two.dart';
import 'package:frontend/features/onboarding/presentation/widgets/onboarding_visual_three.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/pages/signup_page.dart';

void main() {
  testWidgets('OnboardingPage renders 3 pages with proper interactions and navigation', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WeTravelApp(),
      ),
    );

    appRouter.go(RouteNames.onboarding);
    await tester.pumpAndSettle();

    // ── 1. Page 1 Verification ────────────────────────────────────────────────
    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.byType(OnboardingVisualOne), findsOneWidget);
    expect(find.text('Plan together.'), findsOneWidget);
    expect(
      find.text("Bring everyone's ideas, preferences, and plans into one shared trip."),
      findsOneWidget,
    );
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // ── 2. Advance to Page 2 via "Next" Button ────────────────────────────────
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingVisualTwo), findsOneWidget);
    expect(find.text('Your trip. Your way.'), findsOneWidget);
    expect(
      find.text("WeTravel uses everyone's preferences to help create a plan that works for the whole group."),
      findsOneWidget,
    );

    // Verify "Back" button works
    expect(find.byTooltip('Back'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Plan together.'), findsOneWidget);

    // Advance back to Page 2 then Page 3
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // ── 3. Page 3 Verification ────────────────────────────────────────────────
    expect(find.byType(OnboardingVisualThree), findsOneWidget);
    expect(find.text('More exploring. Less planning.'), findsOneWidget);
    expect(
      find.text('Collaborate on activities, itineraries, polls, expenses, and memories — all in one place.'),
      findsOneWidget,
    );
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Already have an account? Log in'), findsOneWidget);

    // ── 4. Verify "Get Started" Navigation ────────────────────────────────────
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.byType(SignupPage), findsOneWidget);
  });

  testWidgets('OnboardingPage "Skip" button navigates directly to LoginPage', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WeTravelApp(),
      ),
    );

    appRouter.go(RouteNames.onboarding);
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:frontend/features/auth/presentation/pages/login_page.dart';
import 'package:frontend/features/auth/presentation/pages/signup_page.dart';

void main() {
  testWidgets('OnboardingPage renders editorial single-page design with badges and actions', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WeTravelApp(),
      ),
    );

    appRouter.go(RouteNames.onboarding);
    await tester.pumpAndSettle();

    // ── 1. Verification of Brand Elements & Content ─────────────────────────
    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.text('WeTravel'), findsOneWidget);
    expect(find.text('Adventure'), findsOneWidget);
    expect(find.text('Plan Explore & Experience Together'), findsOneWidget);

    // ── 2. Feature Badges Verification ──────────────────────────────────────
    expect(find.text('Plan\nSmart'), findsOneWidget);
    expect(find.text('Manage\nMultiple\nInterests'), findsOneWidget);
    expect(find.text('Explore\nThe World'), findsOneWidget);

    // ── 3. Actions Verification ─────────────────────────────────────────────
    final getStartedFinder = find.text('Get Started');
    expect(getStartedFinder, findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);

    // Ensure the CTA button is visible in viewport before tapping
    await tester.ensureVisible(getStartedFinder);
    await tester.pumpAndSettle();

    await tester.tap(getStartedFinder);
    await tester.pumpAndSettle();

    expect(find.byType(SignupPage), findsOneWidget);
  });

  testWidgets('OnboardingPage "Log in" link navigates directly to LoginPage', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WeTravelApp(),
      ),
    );

    appRouter.go(RouteNames.onboarding);
    await tester.pumpAndSettle();

    final loginFinder = find.text('Log in');
    expect(loginFinder, findsOneWidget);

    // Ensure the login link is visible in viewport before tapping
    await tester.ensureVisible(loginFinder);
    await tester.pumpAndSettle();

    await tester.tap(loginFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}

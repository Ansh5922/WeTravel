import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/app.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/router/route_names.dart';
import 'package:frontend/features/splash/presentation/pages/splash_page.dart';
import 'package:frontend/features/splash/presentation/widgets/travel_emblem.dart';
import 'package:frontend/features/onboarding/presentation/pages/onboarding_page.dart';

void main() {
  testWidgets('SplashPage renders brand identity, emblem, typography, and AI badge', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WeTravelApp(),
      ),
    );

    appRouter.go(RouteNames.splash);
    await tester.pump();

    // Verify presence of core elements
    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.byType(TravelEmblem), findsOneWidget);
    expect(find.text('WeTravel'), findsOneWidget);
    expect(find.text('Plan together. Travel better.'), findsOneWidget);
    expect(find.text('AI-Assisted Group Journeys'), findsOneWidget);

    // Let animation run to completion
    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.byType(SplashPage), findsOneWidget);

    // Advance past auto-navigation timer (1500ms total)
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify it transitioned to OnboardingPage
    expect(find.byType(OnboardingPage), findsOneWidget);
  });
}

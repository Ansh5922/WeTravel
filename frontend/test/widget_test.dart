import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/app.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WeTravelApp(),
      ),
    );

    // Allow startup initialization timers to complete
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(WeTravelApp), findsOneWidget);
  });
}

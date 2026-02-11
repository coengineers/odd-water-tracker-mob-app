import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/app.dart';

void main() {
  group('Navigation', () {
    testWidgets('can navigate to Daily tab', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: WaterLogApp()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();

      expect(find.text('Daily'), findsWidgets);
    });

    testWidgets('can navigate to Weekly tab', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: WaterLogApp()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      expect(find.text('Weekly Summary'), findsWidgets);
    });

    testWidgets('can navigate to Monthly tab', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: WaterLogApp()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      expect(find.text('Monthly Patterns'), findsWidgets);
    });

    testWidgets('can navigate back to Home tab', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: WaterLogApp()),
      );
      await tester.pumpAndSettle();

      // Navigate away
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();

      // Navigate back
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(find.text('WaterLog'), findsOneWidget);
    });
  });
}

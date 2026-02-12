import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/app.dart';
import 'package:water_log/db/app_database.dart';
import 'package:water_log/providers/database_provider.dart';

void main() {
  group('Navigation', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('can navigate to Daily tab', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const WaterLogApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();

      expect(find.text('Daily'), findsWidgets);
    });

    testWidgets('can navigate to Weekly tab', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const WaterLogApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();

      expect(find.text('Weekly Summary'), findsWidgets);
    });

    testWidgets('can navigate to Monthly tab', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const WaterLogApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      expect(find.text('Monthly Patterns'), findsWidgets);
    });

    testWidgets('can navigate back to Home tab', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const WaterLogApp(),
        ),
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

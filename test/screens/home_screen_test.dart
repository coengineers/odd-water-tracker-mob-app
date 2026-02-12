import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/app.dart';
import 'package:water_log/db/app_database.dart';
import 'package:water_log/providers/database_provider.dart';
import 'package:water_log/widgets/progress_ring.dart';
import 'package:water_log/widgets/streak_card.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const WaterLogApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows progress ring at 0% on fresh start', (tester) async {
    await pumpApp(tester);

    expect(find.byType(ProgressRing), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('0 / 2000 ml'), findsOneWidget);
  });

  testWidgets('shows daily target text', (tester) async {
    await pumpApp(tester);

    expect(find.text('Daily Target: 2000 ml'), findsOneWidget);
  });

  testWidgets('displays four quick-add buttons', (tester) async {
    await pumpApp(tester);

    expect(find.text('Glass'), findsOneWidget);
    expect(find.text('Bottle'), findsOneWidget);
    expect(find.text('Large'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
  });

  testWidgets('tapping Glass updates progress', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Glass'));
    await tester.pumpAndSettle();

    expect(find.text('250 / 2000 ml'), findsOneWidget);
  });

  testWidgets('tapping Custom opens bottom sheet', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    expect(find.text('Custom Amount'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('entering valid custom amount updates progress', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '350');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('350 / 2000 ml'), findsOneWidget);
  });

  testWidgets('shows empty state prompt when no entries', (tester) async {
    await pumpApp(tester);

    expect(
      find.text('Start tracking by logging your first glass!'),
      findsOneWidget,
    );
  });

  testWidgets('hides empty state after first entry', (tester) async {
    await pumpApp(tester);

    expect(
      find.text('Start tracking by logging your first glass!'),
      findsOneWidget,
    );

    await tester.tap(find.text('Glass'));
    await tester.pumpAndSettle();

    expect(
      find.text('Start tracking by logging your first glass!'),
      findsNothing,
    );
  });

  testWidgets('shows streak counters', (tester) async {
    await pumpApp(tester);

    expect(find.byType(StreakCard), findsOneWidget);
    expect(find.text('Current Streak'), findsOneWidget);
    expect(find.text('Longest Streak'), findsOneWidget);
  });
}

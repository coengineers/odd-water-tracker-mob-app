import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:water_log/app.dart';
import 'package:water_log/db/app_database.dart';
import 'package:water_log/providers/database_provider.dart';

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

  Future<void> goToMonthly(WidgetTester tester) async {
    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
  }

  Future<void> addEntryOnDate(String date, int amountMl) async {
    await db
        .into(db.waterEntries)
        .insert(
          WaterEntriesCompanion.insert(
            id: 'test-$date-$amountMl',
            entryTs: '${date}T12:00:00.000',
            entryDate: date,
            amountMl: amountMl,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
  }

  testWidgets('shows empty state on fresh DB', (tester) async {
    await pumpApp(tester);
    await goToMonthly(tester);

    expect(find.text('No data this month'), findsOneWidget);
    expect(
      find.text('Log water from the Home tab to start tracking!'),
      findsOneWidget,
    );
  });

  testWidgets('heatmap renders with seeded data', (tester) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await addEntryOnDate(today, 2000);

    await pumpApp(tester);
    await goToMonthly(tester);

    expect(find.text('No data this month'), findsNothing);
    // Check icons appear for target-met days
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('shows month title', (tester) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await addEntryOnDate(today, 1000);

    await pumpApp(tester);
    await goToMonthly(tester);

    final expected = DateFormat('MMMM yyyy').format(DateTime.now());
    expect(find.text(expected), findsOneWidget);
  });

  testWidgets('tap day shows tooltip', (tester) async {
    final now = DateTime.now();
    final day10 =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-10';
    await addEntryOnDate(day10, 1500);

    await pumpApp(tester);
    await goToMonthly(tester);

    // Tap day 10
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();

    expect(find.text(day10), findsOneWidget);
    expect(find.text('1500 ml'), findsOneWidget);
  });
}

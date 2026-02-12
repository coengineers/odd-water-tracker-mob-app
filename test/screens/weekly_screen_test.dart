import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

  Future<void> goToWeekly(WidgetTester tester) async {
    await tester.tap(find.text('Weekly'));
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
    await goToWeekly(tester);

    expect(find.text('No data this week'), findsOneWidget);
    expect(
      find.text('Log water from the Home tab to start tracking!'),
      findsOneWidget,
    );
  });

  testWidgets('shows bar chart with seeded data', (tester) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await addEntryOnDate(today, 1500);

    await pumpApp(tester);
    await goToWeekly(tester);

    expect(find.byType(BarChart), findsOneWidget);
    expect(find.text('No data this week'), findsNothing);
  });

  testWidgets('stats row shows correct values', (tester) async {
    final today = DateTime.now();
    final todayStr = today.toIso8601String().substring(0, 10);
    final yesterdayStr = today
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

    // 2000 + 1400 = 3400, avg = 3400 ~/ 7 = 485
    await addEntryOnDate(todayStr, 2000);
    await addEntryOnDate(yesterdayStr, 1400);

    await pumpApp(tester);
    await goToWeekly(tester);

    expect(find.text('485 ml'), findsOneWidget);
    expect(find.text('Avg / day'), findsOneWidget);
    // 1 day at target (2000 >= 2000)
    expect(find.text('1 / 7'), findsOneWidget);
    expect(find.text('Days on target'), findsOneWidget);
  });
}

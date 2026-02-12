import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uuid/uuid.dart';
import 'package:water_log/app.dart';
import 'package:water_log/db/app_database.dart';
import 'package:water_log/providers/database_provider.dart';
import 'package:water_log/widgets/weekly_bar_chart.dart';
import 'package:water_log/widgets/calendar_heatmap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> seedMultiDayEntries() async {
    const uuid = Uuid();
    final now = DateTime.now();

    for (var daysAgo = 0; daysAgo < 7; daysAgo++) {
      final day = now.subtract(Duration(days: daysAgo));
      final entryDate = day.toIso8601String().substring(0, 10);
      final entryTs = DateTime(
        day.year,
        day.month,
        day.day,
        10,
        0,
      ).toIso8601String();

      await db
          .into(db.waterEntries)
          .insert(
            WaterEntriesCompanion.insert(
              id: uuid.v4(),
              entryTs: entryTs,
              entryDate: entryDate,
              amountMl: 500,
              createdAt: entryTs,
            ),
          );
    }
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const WaterLogApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Weekly tab shows BarChart with seeded data', (tester) async {
    await seedMultiDayEntries();
    await pumpApp(tester);

    // Navigate to Weekly tab
    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pumpAndSettle();

    expect(find.byType(WeeklyBarChart), findsOneWidget);
  });

  testWidgets('Monthly tab shows CalendarHeatmap with seeded data', (
    tester,
  ) async {
    await seedMultiDayEntries();
    await pumpApp(tester);

    // Navigate to Monthly tab
    await tester.tap(find.byIcon(Icons.calendar_month));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarHeatmap), findsOneWidget);
  });
}

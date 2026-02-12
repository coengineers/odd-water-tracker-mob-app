import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/app.dart';
import 'package:water_log/db/app_database.dart';
import 'package:water_log/providers/database_provider.dart';
import 'package:water_log/widgets/progress_bar.dart';

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

  Future<void> goToDaily(WidgetTester tester) async {
    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();
  }

  Future<WaterEntry> addEntry(int amountMl) async {
    return db
        .into(db.waterEntries)
        .insertReturning(
          WaterEntriesCompanion.insert(
            id: 'test-${DateTime.now().microsecondsSinceEpoch}-$amountMl',
            entryTs: DateTime.now().toIso8601String(),
            entryDate: DateTime.now().toIso8601String().substring(0, 10),
            amountMl: amountMl,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
  }

  testWidgets('shows progress bar at 0% on fresh start', (tester) async {
    await pumpApp(tester);
    await goToDaily(tester);

    expect(find.byType(ProgressBar), findsOneWidget);
    expect(find.text('0 / 2000 ml'), findsOneWidget);
  });

  testWidgets('shows today total header', (tester) async {
    await pumpApp(tester);
    await goToDaily(tester);

    expect(find.text('Today: 0 ml'), findsOneWidget);
  });

  testWidgets('shows progress bar filled for logged entries', (tester) async {
    await addEntry(500);

    await pumpApp(tester);
    await goToDaily(tester);

    expect(find.text('500 / 2000 ml'), findsOneWidget);
    expect(find.text('Today: 500 ml'), findsOneWidget);
  });

  testWidgets('lists entries newest-first with formatted text', (tester) async {
    await addEntry(250);

    await pumpApp(tester);
    await goToDaily(tester);

    final listTileFinder = find.byType(ListTile);
    expect(listTileFinder, findsOneWidget);

    // Verify format: "{amount}ml at HH:mm"
    final textFinder = find.textContaining('250ml at');
    expect(textFinder, findsOneWidget);
  });

  testWidgets('shows empty state when no entries', (tester) async {
    await pumpApp(tester);
    await goToDaily(tester);

    expect(find.text('No entries yet today'), findsOneWidget);
    expect(
      find.text('Log water from the Home tab to start tracking!'),
      findsOneWidget,
    );
  });

  testWidgets('hides empty state when entries exist', (tester) async {
    await addEntry(250);

    await pumpApp(tester);
    await goToDaily(tester);

    expect(find.text('No entries yet today'), findsNothing);
    expect(
      find.text('Log water from the Home tab to start tracking!'),
      findsNothing,
    );
  });

  testWidgets('tapping entry shows delete confirmation dialog', (tester) async {
    await addEntry(300);

    await pumpApp(tester);
    await goToDaily(tester);

    await tester.tap(find.textContaining('300ml at'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Entry?'), findsOneWidget);
    expect(find.textContaining('Remove 300ml logged at'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('cancel dismisses dialog without deleting', (tester) async {
    await addEntry(300);

    await pumpApp(tester);
    await goToDaily(tester);

    await tester.tap(find.textContaining('300ml at'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Dialog dismissed
    expect(find.text('Delete Entry?'), findsNothing);
    // Entry still visible
    expect(find.textContaining('300ml at'), findsOneWidget);
  });

  testWidgets('confirming delete removes entry and updates total', (
    tester,
  ) async {
    await addEntry(300);
    await addEntry(500);

    await pumpApp(tester);
    await goToDaily(tester);

    expect(find.text('Today: 800 ml'), findsOneWidget);

    // Tap the first entry (300ml)
    await tester.tap(find.textContaining('300ml at'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Total updated
    expect(find.text('Today: 500 ml'), findsOneWidget);
    // Deleted entry gone
    expect(find.textContaining('300ml at'), findsNothing);
    // Other entry still there
    expect(find.textContaining('500ml at'), findsOneWidget);
  });

  testWidgets('deleting last entry shows empty state', (tester) async {
    await addEntry(250);

    await pumpApp(tester);
    await goToDaily(tester);

    expect(find.text('No entries yet today'), findsNothing);

    await tester.tap(find.textContaining('250ml at'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('No entries yet today'), findsOneWidget);
    expect(find.text('Today: 0 ml'), findsOneWidget);
  });
}

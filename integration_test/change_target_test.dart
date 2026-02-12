import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uuid/uuid.dart';
import 'package:water_log/app.dart';
import 'package:water_log/db/app_database.dart';
import 'package:water_log/providers/database_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> seedTodayEntry(int amountMl) async {
    const uuid = Uuid();
    final now = DateTime.now();
    final entryDate = now.toIso8601String().substring(0, 10);
    final entryTs = now.toIso8601String();

    await db
        .into(db.waterEntries)
        .insert(
          WaterEntriesCompanion.insert(
            id: uuid.v4(),
            entryTs: entryTs,
            entryDate: entryDate,
            amountMl: amountMl,
            createdAt: entryTs,
          ),
        );
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

  testWidgets('change target to match intake shows 100%', (tester) async {
    // Seed 1500ml entry for today
    await seedTodayEntry(1500);
    await pumpApp(tester);

    // Verify initial state with 2000ml target
    expect(find.text('1500 / 2000 ml'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);

    // Navigate to Settings
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    // Change target to 1500
    await tester.tap(find.text('Daily Target'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '1500');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify target updated in settings
    expect(find.text('1500 ml'), findsOneWidget);

    // Navigate back to Home
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // Verify 100% progress
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('1500 / 1500 ml'), findsOneWidget);
  });
}

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
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

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const WaterLogApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('add entry, cancel delete, confirm delete', (tester) async {
    await pumpApp(tester);

    // Add an entry
    await tester.tap(find.text('Glass'));
    await tester.pumpAndSettle();

    // Navigate to Daily tab
    await tester.tap(find.byIcon(Icons.today));
    await tester.pumpAndSettle();

    // Tap entry to show delete dialog
    await tester.tap(find.textContaining('250ml'));
    await tester.pumpAndSettle();

    // Cancel delete
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Entry should still be there
    expect(find.textContaining('250ml'), findsOneWidget);

    // Tap entry again
    await tester.tap(find.textContaining('250ml'));
    await tester.pumpAndSettle();

    // Confirm delete
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Entry should be gone
    expect(find.textContaining('250ml'), findsNothing);
    expect(find.text('No entries yet today'), findsOneWidget);
  });
}

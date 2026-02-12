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

  testWidgets('tap Glass and Bottle, verify cumulative progress', (
    tester,
  ) async {
    await pumpApp(tester);

    // Tap Glass (250ml)
    await tester.tap(find.text('Glass'));
    await tester.pumpAndSettle();
    expect(find.text('250 / 2000 ml'), findsOneWidget);

    // Tap Bottle (500ml)
    await tester.tap(find.text('Bottle'));
    await tester.pumpAndSettle();
    expect(find.text('750 / 2000 ml'), findsOneWidget);

    // Navigate to Daily tab
    await tester.tap(find.byIcon(Icons.today));
    await tester.pumpAndSettle();

    // Verify entries appear
    expect(find.textContaining('250ml'), findsOneWidget);
    expect(find.textContaining('500ml'), findsOneWidget);
  });
}

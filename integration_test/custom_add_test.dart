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

  testWidgets('custom add: empty submit shows error, then valid entry works', (
    tester,
  ) async {
    await pumpApp(tester);

    // Tap Custom
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    // Try empty submit
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter an amount'), findsOneWidget);

    // Enter 330ml and submit
    await tester.enterText(find.byType(TextField), '330');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify progress updated
    expect(find.text('330 / 2000 ml'), findsOneWidget);
  });
}

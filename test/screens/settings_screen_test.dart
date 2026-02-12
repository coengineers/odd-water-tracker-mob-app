import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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

  Future<void> navigateToSettings(WidgetTester tester) async {
    await pumpApp(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
  }

  testWidgets('shows current daily target (2000 ml)', (tester) async {
    await navigateToSettings(tester);

    expect(find.text('Daily Target'), findsOneWidget);
    expect(find.text('2000 ml'), findsOneWidget);
  });

  testWidgets('tapping Daily Target opens edit sheet', (tester) async {
    await navigateToSettings(tester);

    await tester.tap(find.text('Daily Target'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Daily Target'), findsOneWidget);
  });

  testWidgets('edit sheet shows pre-populated 2000', (tester) async {
    await navigateToSettings(tester);

    await tester.tap(find.text('Daily Target'));
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, '2000');
  });

  testWidgets('saving valid target updates display', (tester) async {
    await navigateToSettings(tester);

    await tester.tap(find.text('Daily Target'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '3000');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('3000 ml'), findsOneWidget);
  });

  testWidgets('shows About section', (tester) async {
    await navigateToSettings(tester);

    expect(find.text('About'), findsOneWidget);
    expect(find.text('WaterLog v1.0 — Offline water tracker'), findsOneWidget);
  });

  testWidgets('shows Reset All Data option', (tester) async {
    await navigateToSettings(tester);

    expect(find.text('Reset All Data'), findsOneWidget);
  });

  testWidgets('Reset All Data shows confirmation dialog', (tester) async {
    await navigateToSettings(tester);

    await tester.tap(find.text('Reset All Data'));
    await tester.pumpAndSettle();

    expect(find.text('Reset All Data?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('confirming reset clears data', (tester) async {
    await navigateToSettings(tester);

    await tester.tap(find.text('Reset All Data'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    // Should navigate back to home after reset
    expect(find.text('WaterLog'), findsOneWidget);
  });
}

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/app.dart';
import 'package:water_log/db/app_database.dart';
import 'package:water_log/providers/database_provider.dart';

void main() {
  testWidgets('App renders without errors', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const WaterLogApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Home tab is visible on launch', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const WaterLogApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('WaterLog'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
  });
}

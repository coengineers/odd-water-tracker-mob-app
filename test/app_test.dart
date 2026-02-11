import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/app.dart';

void main() {
  testWidgets('App renders without errors', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WaterLogApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Home tab is visible on launch', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WaterLogApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('WaterLog'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/widgets/progress_ring.dart';

void main() {
  Widget buildSubject({required int consumed, required int target}) {
    return MaterialApp(
      home: Scaffold(
        body: ProgressRing(consumed: consumed, target: target),
      ),
    );
  }

  testWidgets('shows 0% when consumed is 0', (tester) async {
    await tester.pumpWidget(buildSubject(consumed: 0, target: 2000));

    expect(find.text('0%'), findsOneWidget);
    expect(find.text('0 / 2000 ml'), findsOneWidget);
  });

  testWidgets('shows 25% for consumed=500, target=2000', (tester) async {
    await tester.pumpWidget(buildSubject(consumed: 500, target: 2000));

    expect(find.text('25%'), findsOneWidget);
    expect(find.text('500 / 2000 ml'), findsOneWidget);
  });

  testWidgets('shows 100% when target exactly met', (tester) async {
    await tester.pumpWidget(buildSubject(consumed: 2000, target: 2000));

    expect(find.text('100%'), findsOneWidget);
    expect(find.text('2000 / 2000 ml'), findsOneWidget);
  });

  testWidgets('shows >100% percentage when exceeded', (tester) async {
    await tester.pumpWidget(buildSubject(consumed: 2500, target: 2000));

    expect(find.text('125%'), findsOneWidget);
    expect(find.text('2500 / 2000 ml'), findsOneWidget);
  });

  testWidgets('displays consumed / target ml text', (tester) async {
    await tester.pumpWidget(buildSubject(consumed: 750, target: 3000));

    expect(find.text('750 / 3000 ml'), findsOneWidget);
  });
}

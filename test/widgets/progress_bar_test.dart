import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/theme/app_colors.dart';
import 'package:water_log/widgets/progress_bar.dart';

void main() {
  Widget buildBar({required int consumed, required int target}) {
    return MaterialApp(
      home: Scaffold(
        body: ProgressBar(consumed: consumed, target: target),
      ),
    );
  }

  testWidgets('shows "0 / 2000 ml" when consumed is 0', (tester) async {
    await tester.pumpWidget(buildBar(consumed: 0, target: 2000));

    expect(find.text('0 / 2000 ml'), findsOneWidget);
  });

  testWidgets('shows "500 / 2000 ml" for partial fill', (tester) async {
    await tester.pumpWidget(buildBar(consumed: 500, target: 2000));

    expect(find.text('500 / 2000 ml'), findsOneWidget);
  });

  testWidgets('shows success colour when target met', (tester) async {
    await tester.pumpWidget(buildBar(consumed: 2000, target: 2000));

    final fractionBox = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(fractionBox.widthFactor, 1.0);

    final decoratedBox = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
    final decoration = decoratedBox.decoration as BoxDecoration;
    expect(decoration.color, AppColors.success);
  });

  testWidgets('clamps fill when exceeded and shows actual values', (
    tester,
  ) async {
    await tester.pumpWidget(buildBar(consumed: 2500, target: 2000));

    expect(find.text('2500 / 2000 ml'), findsOneWidget);

    final fractionBox = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(fractionBox.widthFactor, 1.0);
  });

  testWidgets('has correct Semantics label', (tester) async {
    await tester.pumpWidget(buildBar(consumed: 750, target: 2000));

    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (w) =>
            w is Semantics && w.properties.label == '750 of 2000 ml consumed',
      ),
    );
    expect(semantics, isNotNull);
  });
}

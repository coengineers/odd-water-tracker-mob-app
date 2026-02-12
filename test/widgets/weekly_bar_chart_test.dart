import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/theme/app_colors.dart';
import 'package:water_log/widgets/weekly_bar_chart.dart';

void main() {
  Widget buildSubject({
    required Map<String, int> dailyTotals,
    int targetMl = 2000,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: WeeklyBarChart(dailyTotals: dailyTotals, targetMl: targetMl),
      ),
    );
  }

  List<String> last7Days() {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      return d.toIso8601String().substring(0, 10);
    });
  }

  testWidgets('renders a BarChart widget', (tester) async {
    await tester.pumpWidget(buildSubject(dailyTotals: {}));
    expect(find.byType(BarChart), findsOneWidget);
  });

  testWidgets('renders 7 bars', (tester) async {
    await tester.pumpWidget(buildSubject(dailyTotals: {}));

    final barChart = tester.widget<BarChart>(find.byType(BarChart));
    expect(barChart.data.barGroups.length, 7);
  });

  testWidgets('has a horizontal target line', (tester) async {
    await tester.pumpWidget(buildSubject(dailyTotals: {}, targetMl: 2000));

    final barChart = tester.widget<BarChart>(find.byType(BarChart));
    final lines = barChart.data.extraLinesData.horizontalLines;
    expect(lines.length, 1);
    expect(lines.first.y, 2000);
  });

  testWidgets('bar uses success color when at or above target', (tester) async {
    final days = last7Days();
    // Make the last day hit the target
    final totals = {days.last: 2500};

    await tester.pumpWidget(buildSubject(dailyTotals: totals, targetMl: 2000));

    final barChart = tester.widget<BarChart>(find.byType(BarChart));
    // Last bar (index 6) should have success color
    final lastBar = barChart.data.barGroups[6];
    expect(lastBar.barRods.first.color, AppColors.success);
  });

  testWidgets('bar uses primary color when below target', (tester) async {
    final days = last7Days();
    final totals = {days.last: 500};

    await tester.pumpWidget(buildSubject(dailyTotals: totals, targetMl: 2000));

    final barChart = tester.widget<BarChart>(find.byType(BarChart));
    final lastBar = barChart.data.barGroups[6];
    expect(lastBar.barRods.first.color, AppColors.primary);
  });

  testWidgets('has Semantics label', (tester) async {
    await tester.pumpWidget(buildSubject(dailyTotals: {}));
    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.label == 'Weekly water intake bar chart',
      ),
    );
    expect(semantics, isNotNull);
  });
}

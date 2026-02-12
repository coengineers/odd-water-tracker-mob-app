import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/widgets/weekly_stats_row.dart';

void main() {
  Widget buildSubject({
    required Map<String, int> dailyTotals,
    int targetMl = 2000,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: WeeklyStatsRow(dailyTotals: dailyTotals, targetMl: targetMl),
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

  testWidgets('shows correct average calculation', (tester) async {
    final days = last7Days();
    // 3 days with 1400 ml each → sum = 4200, avg = 4200 ~/ 7 = 600
    final totals = {days[0]: 1400, days[2]: 1400, days[4]: 1400};

    await tester.pumpWidget(buildSubject(dailyTotals: totals));

    expect(find.text('600 ml'), findsOneWidget);
    expect(find.text('Avg / day'), findsOneWidget);
  });

  testWidgets('shows correct days-hit count', (tester) async {
    final days = last7Days();
    // 2 days at/above target of 2000
    final totals = {days[0]: 2000, days[1]: 500, days[3]: 2500};

    await tester.pumpWidget(buildSubject(dailyTotals: totals, targetMl: 2000));

    expect(find.text('2 / 7'), findsOneWidget);
    expect(find.text('Days on target'), findsOneWidget);
  });

  testWidgets('shows 0 average and 0 days hit for empty data', (tester) async {
    await tester.pumpWidget(buildSubject(dailyTotals: {}));

    expect(find.text('0 ml'), findsOneWidget);
    expect(find.text('0 / 7'), findsOneWidget);
  });
}

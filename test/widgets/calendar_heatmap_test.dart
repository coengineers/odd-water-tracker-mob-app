import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/widgets/calendar_heatmap.dart';

void main() {
  // Use a known month: January 2025 starts on Wednesday, has 31 days
  const testYear = 2025;
  const testMonth = 1;

  Widget buildSubject({
    required Map<String, int> dailyTotals,
    int targetMl = 2000,
    int year = testYear,
    int month = testMonth,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: CalendarHeatmap(
            dailyTotals: dailyTotals,
            targetMl: targetMl,
            year: year,
            month: month,
          ),
        ),
      ),
    );
  }

  testWidgets('shows day-of-week headers', (tester) async {
    await tester.pumpWidget(buildSubject(dailyTotals: {}));

    // M T W T F S S
    expect(find.text('M'), findsOneWidget);
    expect(find.text('W'), findsOneWidget);
    expect(find.text('F'), findsOneWidget);
    expect(find.text('S'), findsNWidgets(2)); // Saturday + Sunday
    expect(find.text('T'), findsNWidgets(2)); // Tuesday + Thursday
  });

  testWidgets('renders correct number of day cells', (tester) async {
    // January 2025 has 31 days
    await tester.pumpWidget(buildSubject(dailyTotals: {}));

    // Should see day numbers 1-31 for empty cells
    expect(find.text('1'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('31'), findsOneWidget);
  });

  testWidgets('shows check icon for days at target', (tester) async {
    final totals = {'2025-01-10': 2000, '2025-01-15': 2500};

    await tester.pumpWidget(buildSubject(dailyTotals: totals, targetMl: 2000));

    // Days at/above target show check icons
    expect(find.byIcon(Icons.check), findsNWidgets(2));
  });

  testWidgets('no check icon for days below target', (tester) async {
    final totals = {'2025-01-10': 500};

    await tester.pumpWidget(buildSubject(dailyTotals: totals, targetMl: 2000));

    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('tap day shows tooltip card', (tester) async {
    final totals = {'2025-01-10': 1500};

    await tester.pumpWidget(buildSubject(dailyTotals: totals, targetMl: 2000));

    // Tap on day 10
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();

    // Tooltip should show date and amount
    expect(find.text('2025-01-10'), findsOneWidget);
    expect(find.text('1500 ml'), findsOneWidget);
    expect(find.text('Below target'), findsOneWidget);
  });

  testWidgets('tap same day again dismisses tooltip', (tester) async {
    final totals = {'2025-01-10': 1500};

    await tester.pumpWidget(buildSubject(dailyTotals: totals, targetMl: 2000));

    // Tap to show
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    expect(find.text('1500 ml'), findsOneWidget);

    // Tap again to dismiss
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    expect(find.text('1500 ml'), findsNothing);
  });

  testWidgets('tap different day switches tooltip', (tester) async {
    final totals = {'2025-01-10': 1500, '2025-01-12': 800};

    await tester.pumpWidget(buildSubject(dailyTotals: totals, targetMl: 2000));

    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    expect(find.text('1500 ml'), findsOneWidget);

    await tester.tap(find.text('12'));
    await tester.pumpAndSettle();
    expect(find.text('800 ml'), findsOneWidget);
    expect(find.text('1500 ml'), findsNothing);
  });
}

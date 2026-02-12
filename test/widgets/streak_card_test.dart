import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/widgets/streak_card.dart';

void main() {
  testWidgets('renders current and longest streak values', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StreakCard(current: 5, longest: 12)),
      ),
    );

    expect(find.text('5'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Current Streak'), findsOneWidget);
    expect(find.text('Longest Streak'), findsOneWidget);
  });

  testWidgets('shows 0 for both when no streaks', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StreakCard(current: 0, longest: 0)),
      ),
    );

    expect(find.text('0'), findsNWidgets(2));
    expect(find.text('Current Streak'), findsOneWidget);
    expect(find.text('Longest Streak'), findsOneWidget);
  });
}

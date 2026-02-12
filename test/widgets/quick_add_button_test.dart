import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/widgets/quick_add_button.dart';

void main() {
  testWidgets('renders label, icon, and amount text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickAddButton(
            label: 'Glass',
            icon: Icons.local_drink_outlined,
            amountMl: 250,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Glass'), findsOneWidget);
    expect(find.text('250 ml'), findsOneWidget);
    expect(find.byIcon(Icons.local_drink_outlined), findsOneWidget);
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickAddButton(
            label: 'Glass',
            icon: Icons.local_drink_outlined,
            amountMl: 250,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Glass'));
    expect(pressed, isTrue);
  });

  testWidgets('omits amount text when amountMl is null', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickAddButton(
            label: 'Custom',
            icon: Icons.edit_outlined,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Custom'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    // No "ml" text
    expect(find.textContaining('ml'), findsNothing);
  });
}

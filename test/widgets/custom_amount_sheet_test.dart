import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/widgets/custom_amount_sheet.dart';

void main() {
  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                await CustomAmountSheet.show(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows title, text field, and Add button', (tester) async {
    await openSheet(tester);

    expect(find.text('Custom Amount'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('empty input shows error', (tester) async {
    await openSheet(tester);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter an amount'), findsOneWidget);
  });

  testWidgets('amount 0 shows error', (tester) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextField), '0');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Amount must be at least 1 ml'), findsOneWidget);
  });

  testWidgets('amount > 5000 shows error', (tester) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextField), '5001');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Amount must be at most 5,000 ml'), findsOneWidget);
  });

  testWidgets('valid amount dismisses and returns value', (tester) async {
    int? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await CustomAmountSheet.show(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '350');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(result, 350);
  });

  testWidgets('boundary: 1 ml is valid', (tester) async {
    int? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await CustomAmountSheet.show(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '1');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(result, 1);
  });

  testWidgets('boundary: 5000 ml is valid', (tester) async {
    int? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await CustomAmountSheet.show(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '5000');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(result, 5000);
  });
}

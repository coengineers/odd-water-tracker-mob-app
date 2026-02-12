import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_log/widgets/edit_target_sheet.dart';

void main() {
  Future<void> openSheet(
    WidgetTester tester, {
    int currentTarget = 2000,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                await EditTargetSheet.show(
                  context,
                  currentTarget: currentTarget,
                );
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

  testWidgets('shows title "Edit Daily Target"', (tester) async {
    await openSheet(tester);

    expect(find.text('Edit Daily Target'), findsOneWidget);
  });

  testWidgets('shows pre-populated value in text field', (tester) async {
    await openSheet(tester, currentTarget: 2000);

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, '2000');
  });

  testWidgets('shows Save button', (tester) async {
    await openSheet(tester);

    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('empty input shows error', (tester) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter an amount'), findsOneWidget);
  });

  testWidgets('value below 250 shows error', (tester) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextField), '249');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Target must be at least 250 ml'), findsOneWidget);
  });

  testWidgets('value above 10000 shows error', (tester) async {
    await openSheet(tester);

    await tester.enterText(find.byType(TextField), '10001');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Target must be at most 10,000 ml'), findsOneWidget);
  });

  testWidgets('valid input returns value via Navigator.pop', (tester) async {
    int? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await EditTargetSheet.show(
                  context,
                  currentTarget: 2000,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '3000');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 3000);
  });

  testWidgets('boundary: 250 accepted', (tester) async {
    int? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await EditTargetSheet.show(
                  context,
                  currentTarget: 2000,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '250');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 250);
  });

  testWidgets('boundary: 10000 accepted', (tester) async {
    int? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await EditTargetSheet.show(
                  context,
                  currentTarget: 2000,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '10000');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, 10000);
  });
}

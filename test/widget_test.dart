import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workspace/main.dart';

void main() {
  Future<void> tapSequence(WidgetTester tester, String sequence) async {
    for (final value in sequence.split(' ')) {
      await tester.tap(find.widgetWithText(FilledButton, value));
    }
    await tester.pump();
  }

  testWidgets('evaluates expressions with algebraic precedence', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());

    await tapSequence(tester, '2 + 3 * 4 =');

    expect(find.text('2 + 3 * 4 = 14'), findsOneWidget);
  });

  testWidgets('shows an error for division by zero', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tapSequence(tester, '8 / 0 =');

    expect(find.text('8 / 0 = Error'), findsOneWidget);
  });

  testWidgets('clear resets the accumulator display', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tapSequence(tester, '9 + 1 =');
    await tester.tap(find.widgetWithText(FilledButton, 'C'));
    await tester.pump();

    expect(find.text('0').first, findsOneWidget);
  });
}

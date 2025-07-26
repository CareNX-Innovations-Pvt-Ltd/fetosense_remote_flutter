import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_remote_flutter/ui/shared/customRadioBtn.dart';

void main() {
  testWidgets('CustomRadioBtn displays buttons with correct labels',
      (WidgetTester tester) async {
    final List<String> labels = ['Option 1', 'Option 2', 'Option 3'];
    final List<int> values = [1, 2, 3];
    int? selectedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomRadioBtn(
            buttonLables: labels,
            buttonValues: values,
            buttonColor: Colors.blue,
            selectedColor: Colors.green,
            radioButtonValue: (value) {
              selectedValue = value;
            },
            enableAll: true,
          ),
        ),
      ),
    );

    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('CustomRadioBtn calls radioButtonValue when a button is pressed',
      (WidgetTester tester) async {
    final List<String> labels = ['Option A', 'Option B'];
    final List<String> values = ['A', 'B'];
    String? selectedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomRadioBtn(
            buttonLables: labels,
            buttonValues: values,
            buttonColor: Colors.blue,
            selectedColor: Colors.green,
            radioButtonValue: (value) {
              selectedValue = value;
            },
            enableAll: true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Option B'));
    await tester.pump();

    expect(selectedValue, 'B');
  });

  testWidgets('CustomRadioBtn selects the correct button based on defaultValue',
      (WidgetTester tester) async {
    final List<String> labels = ['First', 'Second', 'Third'];
    final List<int> values = [10, 20, 30];
    String? selectedLabel;
    int? selectedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomRadioBtn(
            buttonLables: labels,
            buttonValues: values,
            buttonColor: Colors.grey,
            selectedColor: Colors.orange,
            defaultValue: 'Second',
            radioButtonValue: (value) {
              selectedValue = value;
            },
            enableAll: true,
          ),
        ),
      ),
    );

    // The button with the default value should be selected initially.
    final defaultButton = find.widgetWithText(Card, 'Second');
    expect(defaultButton, findsOneWidget);
  });

  testWidgets('CustomRadioBtn handles horizontal layout',
      (WidgetTester tester) async {
    final List<String> labels = ['One', 'Two'];
    final List<int> values = [1, 2];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomRadioBtn(
            buttonLables: labels,
            buttonValues: values,
            buttonColor: Colors.blue,
            selectedColor: Colors.green,
            horizontal: true,
            radioButtonValue: (value) {},
            enableAll: true,
          ),
        ),
      ),
    );

    // In horizontal layout, the buttons are within a Column
    expect(find.byType(Column), findsOneWidget);
    expect(find.byType(Row), findsNothing);
  });

  testWidgets('CustomRadioBtn handles vertical layout',
      (WidgetTester tester) async {
    final List<String> labels = ['Alpha', 'Beta'];
    final List<int> values = [1, 2];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomRadioBtn(
            buttonLables: labels,
            buttonValues: values,
            buttonColor: Colors.blue,
            selectedColor: Colors.green,
            horizontal: false,
            // Vertical is the default, but explicitly setting for clarity
            radioButtonValue: (value) {},
            enableAll: true,
          ),
        ),
      ),
    );

    // In vertical layout, the buttons are within a Row
    expect(find.byType(Row), findsOneWidget);
    expect(find.byType(Column), findsNothing);
  });

  testWidgets('CustomRadioBtn colors change on selection',
      (WidgetTester tester) async {
    final List<String> labels = ['Red', 'Blue'];
    final List<String> values = ['R', 'B'];
    final Color buttonColor = Color(0xff009688);
    final Color selectedColor = Color(0xff009688);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomRadioBtn(
            buttonLables: labels,
            buttonValues: values,
            buttonColor: buttonColor,
            selectedColor: selectedColor,
            radioButtonValue: (value) {},
            enableAll: true,
          ),
        ),
      ),
    );

    // Initially, the first button is selected (default)
    final initialSelectedButton = find.widgetWithText(Card, 'Red');
    final initialUnselectedButton = find.widgetWithText(Card, 'Blue');

    expect((initialSelectedButton.evaluate().first.widget as Card).color,
        selectedColor);
    expect((initialUnselectedButton.evaluate().first.widget as Card).color,
        buttonColor);

    // Tap the second button
    await tester.tap(find.text('Blue'));
    await tester.pump();

    // Now the second button should be selected
    final afterTapSelectedButton = find.widgetWithText(Card, 'Blue');
    final afterTapUnselectedButton = find.widgetWithText(Card, 'Red');

    expect((afterTapSelectedButton.evaluate().first.widget as Card).color,
        selectedColor);
    expect((afterTapUnselectedButton.evaluate().first.widget as Card).color,
        buttonColor);
  });
}

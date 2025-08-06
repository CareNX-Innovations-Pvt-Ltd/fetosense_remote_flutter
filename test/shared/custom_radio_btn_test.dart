import 'package:fetosense_remote_flutter/ui/shared/customRadioBtn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomRadioBtn', () {
    testWidgets('initializes with defaultValue', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomRadioBtn(
            buttonLables: ['A', 'B', 'C'],
            buttonValues: ['a', 'b', 'c'],
            buttonColor: Colors.grey,
            selectedColor: Colors.blue,
            defaultValue: 'B',
            enableAll: true,
          ),
        ),
      ));

      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('initializes currentSelectedLabel to empty when defaultValue is null', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomRadioBtn(
            buttonLables: ['Yes'],
            buttonValues: ['yes'],
            buttonColor: Colors.grey,
            selectedColor: Colors.blue,
            enableAll: true,
          ),
        ),
      ));

      expect(find.text('Yes'), findsOneWidget);
    });


    testWidgets('fires callback and updates selected value when enableAll = true', (tester) async {
      String? selected;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomRadioBtn(
            buttonLables: ['A', 'B'],
            buttonValues: ['a', 'b'],
            buttonColor: Colors.grey,
            selectedColor: Colors.blue,
            enableAll: true,
            radioButtonValue: (val) => selected = val,
          ),
        ),
      ));

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(selected, equals('b'));
    });

    testWidgets('fires fallback callback when enableAll = false', (tester) async {
      String? selected = 'should not change';
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomRadioBtn(
            buttonLables: ['A', 'B'],
            buttonValues: ['a', 'b'],
            buttonColor: Colors.grey,
            selectedColor: Colors.blue,
            enableAll: false,
            radioButtonValue: (val) => selected = val,
          ),
        ),
      ));

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(selected, equals('should not change')); // still called, but with current
    });

    testWidgets('uses custom shape when enableShape = true and customShape is provided', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomRadioBtn(
            buttonLables: ['X'],
            buttonValues: ['x'],
            buttonColor: Colors.grey,
            selectedColor: Colors.blue,
            enableAll: true,
            enableShape: true,
            customShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ));

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('renders vertical buttons when horizontal = true', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomRadioBtn(
            buttonLables: ['1', '2'],
            buttonValues: ['1', '2'],
            buttonColor: Colors.grey,
            selectedColor: Colors.green,
            enableAll: true,
            horizontal: true,
          ),
        ),
      ));

      expect(find.byType(Column), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('handles missing custom shape gracefully when enableShape = true', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomRadioBtn(
            buttonLables: ['Y'],
            buttonValues: ['y'],
            buttonColor: Colors.grey,
            selectedColor: Colors.red,
            enableAll: true,
            enableShape: true, // no customShape
          ),
        ),
      ));

      expect(find.text('Y'), findsOneWidget);
    });
  });
}

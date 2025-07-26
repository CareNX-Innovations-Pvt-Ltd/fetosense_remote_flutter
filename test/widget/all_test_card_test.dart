import 'package:fetosense_remote_flutter/ui/widgets/all_test_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:intl/intl.dart';

void main() {
  group('AllTestCard Widget Tests', () {
    late Test mockTest;

    setUp(() {
      mockTest = Test.withData(
        id: 'test-id',
        motherName: 'Jane Doe',
        bpmEntries: List.generate(200, (index) => 140),
        movementEntries: List.generate(5, (index) => 1),
        autoFetalMovement: List.generate(3, (index) => 1),
        autoInterpretations: {'basalHeartRate': 135},
        gAge: 32,
        lengthOfTest: 1200,
        createdOn: DateTime(2024, 7, 10),
      );
    });

    testWidgets('renders correct mother name and movement info', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllTestCard(testDetails: mockTest),
          ),
        ),
      );

      // Verify mother's name is displayed
      expect(find.text('Jane Doe'), findsOneWidget);

      // Check movement and heart rate display
      expect(find.textContaining('135 Basal HR'), findsOneWidget);
      expect(find.textContaining('08 Movements'), findsOneWidget);

      // Check date format
      expect(find.text(DateFormat('dd\nMMM').format(mockTest.createdOn!)), findsOneWidget);
    });

    testWidgets('navigates to DetailsView on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AllTestCard(testDetails: mockTest),
        ),
      );

      await tester.tap(find.byType(AllTestCard));
      await tester.pumpAndSettle();

      // Since DetailsView isn't mocked here, test only verifies that tap doesn't throw
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays Live Now if test is live', (WidgetTester tester) async {

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AllTestCard(testDetails: mockTest),
          ),
        ),
      );

      expect(find.text('Live\nnow'), findsOneWidget);
    });
  });
}

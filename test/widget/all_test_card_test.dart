import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_remote_flutter/ui/widgets/all_test_card.dart';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:intl/intl.dart';


Test createFakeTest({
  bool isLive = false,
  int bpmCount = 300,
  int lengthOfTest = 600,
  int gAge = 9,
}) {
  return Test.withData(
    motherName: 'Jane Doe',
    bpmEntries: List.filled(bpmCount, 140),
    movementEntries: List.filled(3, 1),
    autoFetalMovement: List.filled(2, 1),
    createdOn: DateTime(2023, 5, 10),
    autoInterpretations: {'basalHeartRate': 130},
    lengthOfTest: lengthOfTest,
    gAge: gAge,
  );
}


void main() {
  Test testLive = createFakeTest(isLive: true);
  Test testNotLive = createFakeTest(isLive: false);

  testWidgets('Displays "Live now" when test is live', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AllTestCard(testDetails: testLive),
        ),
      ),
    );

    expect(find.text('Live\nnow'), findsOneWidget);
  });

  testWidgets('Displays formatted date when test is not live', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AllTestCard(testDetails: testNotLive),
        ),
      ),
    );

    final formattedDate =
    DateFormat('dd\nMMM').format(testNotLive.createdOn!);
    expect(find.text(formattedDate), findsOneWidget);
  });

  testWidgets('Displays correct mother name, time, and movements', (tester) async {
    final test = createFakeTest(bpmCount: 400, lengthOfTest: 900); // 15 mins
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AllTestCard(testDetails: test),
        ),
      ),
    );

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.textContaining('15'), findsOneWidget); // "15 min"
    expect(find.textContaining('Movements'), findsOneWidget);
    expect(find.textContaining('05 Movements'), findsOneWidget);
  });

  testWidgets('Tapping on card navigates to DetailsView', (tester) async {
    final test = createFakeTest();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => AllTestCard(testDetails: test),
        ),
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => Scaffold(body: Text('Details View')),
        ),
      ),
    );

    await tester.tap(find.byType(AllTestCard));
    await tester.pumpAndSettle();

    expect(find.text('Details View'), findsOneWidget);
  });
}

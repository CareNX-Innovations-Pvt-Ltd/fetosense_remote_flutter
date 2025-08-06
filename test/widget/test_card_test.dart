import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/utils/intrepretations2.dart';
import 'package:fetosense_remote_flutter/ui/views/details_view.dart';
import 'package:fetosense_remote_flutter/ui/widgets/test_card.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late Test baseTest;
  late NavigatorObserver mockObserver;

  setUp(() {
    mockObserver = MockNavigatorObserver();
    baseTest = Test.withData(
      id: '1',
      documentId: '1',
      motherId: 'mother1',
      gAge: 32,
      bpmEntries: List.filled(100, 140),
      movementEntries: List.filled(3, 1),
      autoFetalMovement: List.filled(2, 1),
      lengthOfTest: 300,
      createdOn: DateTime(2023, 8, 1),
      live: false,
    );
  });

  testWidgets('TestCard renders all text correctly when test is not live', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TestCard(testDetails: baseTest)),
      ),
    );

    // Check for core labels
    expect(find.text('Basal HR'), findsOneWidget);
    expect(find.text('Movements'), findsOneWidget);
    expect(find.text('ACCELERATION'), findsOneWidget);
    expect(find.text('DECELERATION'), findsOneWidget);
    expect(find.text('SHORT TERM VARI'), findsOneWidget);
    expect(find.text('LONG TERM VARI'), findsOneWidget);
    expect(find.text('min'), findsOneWidget);

    // Check for calculated time
    expect(find.text('05'), findsOneWidget); // 300 seconds = 5 minutes
  });

  testWidgets('TestCard renders Live Now indicator if test is live', (tester) async {
    final liveTest = baseTest..live = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TestCard(testDetails: liveTest)),
      ),
    );

    expect(find.text('Live\nnow'), findsOneWidget);
  });

  testWidgets('TestCard navigates to DetailsView on tap', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TestCard(testDetails: baseTest),
        navigatorObservers: [mockObserver],
      ),
    );

    await tester.tap(find.byType(TestCard));
    await tester.pumpAndSettle();

    // Confirm navigation
    verify(() => mockObserver.didPush(any(), any())).called(1);
    expect(find.byType(DetailsView), findsOneWidget);
  });

  testWidgets('TestCard handles short lengthOfTest gracefully (<180)', (tester) async {
    final shortTest = baseTest..lengthOfTest = 100;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TestCard(testDetails: shortTest)),
      ),
    );

    expect(find.byType(TestCard), findsOneWidget);
  });

  testWidgets('TestCard handles long lengthOfTest gracefully (>3600)', (tester) async {
    final longTest = baseTest..lengthOfTest = 4000;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TestCard(testDetails: longTest)),
      ),
    );

    expect(find.byType(TestCard), findsOneWidget);
  });

  testWidgets('TestCard handles <10 movements correctly with padding', (tester) async {
    final paddedMovementTest = baseTest
      ..movementEntries = List.filled(2, 1)
      ..autoFetalMovement = List.filled(2, 1); // total = 4

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TestCard(testDetails: paddedMovementTest)),
      ),
    );

    expect(find.textContaining('04'), findsOneWidget);
  });

  testWidgets('TestCard handles >=10 movements without padding', (tester) async {
    final paddedMovementTest = baseTest
      ..movementEntries = List.filled(6, 1)
      ..autoFetalMovement = List.filled(5, 1); // total = 11

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TestCard(testDetails: paddedMovementTest)),
      ),
    );

    expect(find.textContaining('11'), findsOneWidget);
  });
}

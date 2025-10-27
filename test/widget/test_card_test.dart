import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/utils/intrepretations2.dart';
import 'package:fetosense_remote_flutter/ui/shared/textWithIcon.dart';
import 'package:fetosense_remote_flutter/ui/views/details_view.dart';
import 'package:fetosense_remote_flutter/ui/widgets/test_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:intl/intl.dart';

// Generate mocks
@GenerateMocks([
  Test,
  Interpretations2,
  NavigatorObserver,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TestCard - Constructor Tests', () {
    test('should initialize with valid test data and lengthOfTest > 180 and < 3600', () {
      final test = Test.withData(
        documentId: 'test_123',
        id: 'test_123',
        motherName: 'Jane Doe',
        createdOn: DateTime(2025, 10, 20, 10, 30),
        lengthOfTest: 600, // 10 minutes (600 seconds)
        gAge: 32,
        bpmEntries: List.generate(600, (i) => 140 + (i % 20)),
        movementEntries: List.generate(5, (i) => i * 100),
        autoFetalMovement: List.generate(3, (i) => i * 120),
        live: false,
      );

      final card = TestCard(testDetails: test);

      expect(card.testDetails, test);
      expect(card.interpretation, isNotNull);
      expect(card.movements, '08'); // 5 + 3 = 8 < 10, so "08"
      expect(card.time, '10'); // 600/60 = 10
    });

    test('should create empty interpretation when lengthOfTest <= 180', () {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 150, // Less than 180
        gAge: 32,
        bpmEntries: List.generate(150, (i) => 140),
        movementEntries: [],
        autoFetalMovement: [],
        createdOn: DateTime.now(),
        live: false,
      );

      final card = TestCard(testDetails: test);

      expect(card.interpretation, isNotNull);
      expect(card.interpretation, isA<Interpretations2>());
    });

    test('should create empty interpretation when lengthOfTest >= 3600', () {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 3600, // Exactly 3600
        gAge: 32,
        bpmEntries: List.generate(3600, (i) => 140),
        movementEntries: [],
        autoFetalMovement: [],
        createdOn: DateTime.now(),
        live: false,
      );

      final card = TestCard(testDetails: test);

      expect(card.interpretation, isNotNull);
      expect(card.interpretation, isA<Interpretations2>());
    });

    test('should format movements with leading zero when < 10', () {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 300,
        gAge: 32,
        bpmEntries: List.generate(300, (i) => 140),
        movementEntries: List.generate(3, (i) => i),
        autoFetalMovement: List.generate(2, (i) => i),
        createdOn: DateTime.now(),
        live: false,
      );

      final card = TestCard(testDetails: test);

      expect(card.movements, '05'); // 3 + 2 = 5
    });

    test('should format movements without leading zero when >= 10', () {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 300,
        gAge: 32,
        bpmEntries: List.generate(300, (i) => 140),
        movementEntries: List.generate(7, (i) => i),
        autoFetalMovement: List.generate(5, (i) => i),
        createdOn: DateTime.now(),
        live: false,
      );

      final card = TestCard(testDetails: test);

      expect(card.movements, '12'); // 7 + 5 = 12
    });

    test('should format time with leading zero when < 10 minutes', () {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 480, // 8 minutes
        gAge: 32,
        bpmEntries: List.generate(480, (i) => 140),
        movementEntries: [],
        autoFetalMovement: [],
        createdOn: DateTime.now(),
        live: false,
      );

      final card = TestCard(testDetails: test);

      expect(card.time, '08');
    });

    test('should format time without leading zero when >= 10 minutes', () {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 900, // 15 minutes
        gAge: 32,
        bpmEntries: List.generate(900, (i) => 140),
        movementEntries: [],
        autoFetalMovement: [],
        createdOn: DateTime.now(),
        live: false,
      );

      final card = TestCard(testDetails: test);

      expect(card.time, '15');
    });

    test('should handle movements count of exactly 9', () {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 300,
        gAge: 32,
        bpmEntries: List.generate(300, (i) => 140),
        movementEntries: List.generate(5, (i) => i),
        autoFetalMovement: List.generate(4, (i) => i),
        createdOn: DateTime.now(),
        live: false,
      );

      final card = TestCard(testDetails: test);

      expect(card.movements, '09');
    });

    test('should handle movements count of exactly 10', () {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 300,
        gAge: 32,
        bpmEntries: List.generate(300, (i) => 140),
        movementEntries: List.generate(6, (i) => i),
        autoFetalMovement: List.generate(4, (i) => i),
        createdOn: DateTime.now(),
        live: false,
      );

      final card = TestCard(testDetails: test);

      expect(card.movements, '10');
    });

    test('should handle time of exactly 9 minutes', () {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 540, // 9 minutes
        gAge: 32,
        bpmEntries: List.generate(540, (i) => 140),
        movementEntries: [],
        autoFetalMovement: [],
        createdOn: DateTime.now(),
        live: false,
      );

      final card = TestCard(testDetails: test);

      expect(card.time, '09');
    });

    test('should handle time of exactly 10 minutes', () {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 600, // 10 minutes
        gAge: 32,
        bpmEntries: List.generate(600, (i) => 140),
        movementEntries: [],
        autoFetalMovement: [],
        createdOn: DateTime.now(),
        live: false,
      );

      final card = TestCard(testDetails: test);

      expect(card.time, '10');
    });

    test('should handle zero movements', () {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 300,
        gAge: 32,
        bpmEntries: List.generate(300, (i) => 140),
        movementEntries: [],
        autoFetalMovement: [],
        createdOn: DateTime.now(),
        live: false,
      );

      final card = TestCard(testDetails: test);

      expect(card.movements, '00');
    });

    test('should truncate time correctly for non-exact minutes', () {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 659, // 10.98 minutes, should truncate to 10
        gAge: 32,
        bpmEntries: List.generate(659, (i) => 140),
        movementEntries: [],
        autoFetalMovement: [],
        createdOn: DateTime.now(),
        live: false,
      );

      final card = TestCard(testDetails: test);

      expect(card.time, '10');
    });
  });

  group('TestCard - Widget Build Tests', () {
    testWidgets('should render all interpretation values', (WidgetTester tester) async {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 600,
        gAge: 32,
        bpmEntries: List.generate(600, (i) => 140 + (i % 20)),
        movementEntries: List.generate(5, (i) => i),
        autoFetalMovement: List.generate(3, (i) => i),
        createdOn: DateTime(2025, 10, 20),
        live: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestCard(testDetails: test),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that key labels are present
      expect(find.text('Basal HR'), findsOneWidget);
      expect(find.text('Movements'), findsOneWidget);
      expect(find.text('ACCELERATION'), findsOneWidget);
      expect(find.text('DECELERATION'), findsOneWidget);
      expect(find.text('SHORT TERM VARI'), findsOneWidget);
      expect(find.text('LONG TERM VARI'), findsOneWidget);
      expect(find.text('min'), findsOneWidget);
    });

    testWidgets('should display live indicator when test is live', (WidgetTester tester) async {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 600,
        gAge: 32,
        bpmEntries: List.generate(600, (i) => 140),
        movementEntries: [],
        autoFetalMovement: [],
        createdOn: DateTime.now(),
        live: true, // Live test
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestCard(testDetails: test),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Live\nnow'), findsOneWidget);
    });

    testWidgets('should display date when test is not live', (WidgetTester tester) async {
      final testDate = DateTime(2025, 10, 20);
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 600,
        gAge: 32,
        bpmEntries: List.generate(600, (i) => 140),
        movementEntries: [],
        autoFetalMovement: [],
        createdOn: testDate,
        live: false, // Not live
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestCard(testDetails: test),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final expectedDate = DateFormat('dd\nMMM').format(testDate);
      expect(find.text(expectedDate), findsOneWidget);
      expect(find.text('Live\nnow'), findsNothing);
    });

    testWidgets('should display formatted time', (WidgetTester tester) async {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 480, // 8 minutes
        gAge: 32,
        bpmEntries: List.generate(480, (i) => 140),
        movementEntries: [],
        autoFetalMovement: [],
        createdOn: DateTime.now(),
        live: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestCard(testDetails: test),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('08'), findsOneWidget);
    });

    testWidgets('should display movements as "--" when both movement arrays are empty',
            (WidgetTester tester) async {
          final test = Test.withData(
            documentId: 'test_123',
            lengthOfTest: 600,
            gAge: 32,
            bpmEntries: List.generate(600, (i) => 140),
            movementEntries: [],
            autoFetalMovement: [],
            createdOn: DateTime.now(),
            live: false,
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: TestCard(testDetails: test),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // The movements display should show "--" when sum is 0
          expect(find.textContaining('--'), findsOneWidget);
        });

    testWidgets('should display movements count when movements > 0',
            (WidgetTester tester) async {
          final test = Test.withData(
            documentId: 'test_123',
            lengthOfTest: 600,
            gAge: 32,
            bpmEntries: List.generate(600, (i) => 140),
            movementEntries: List.generate(5, (i) => i),
            autoFetalMovement: List.generate(3, (i) => i),
            createdOn: DateTime.now(),
            live: false,
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: TestCard(testDetails: test),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(find.textContaining('08'), findsWidgets);
        });

    testWidgets('should have proper container decorations', (WidgetTester tester) async {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 600,
        gAge: 32,
        bpmEntries: List.generate(600, (i) => 140),
        movementEntries: [],
        autoFetalMovement: [],
        createdOn: DateTime.now(),
        live: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestCard(testDetails: test),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for containers with decorations
      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers.length, greaterThan(0));

      // Check for teal colored container (time display)
      final tealContainer = containers.firstWhere(
            (container) => container.decoration is BoxDecoration &&
            (container.decoration as BoxDecoration).color == Colors.teal,
      );
      expect(tealContainer, isNotNull);
    });

    testWidgets('should have TextWithIcon widgets', (WidgetTester tester) async {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 600,
        gAge: 32,
        bpmEntries: List.generate(600, (i) => 140),
        movementEntries: List.generate(5, (i) => i),
        autoFetalMovement: List.generate(3, (i) => i),
        createdOn: DateTime.now(),
        live: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestCard(testDetails: test),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextWithIcon), findsNWidgets(2));
    });
  });

  group('TestCard - Navigation Tests', () {
    testWidgets('should navigate to DetailsView on tap', (WidgetTester tester) async {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 600,
        gAge: 32,
        bpmEntries: List.generate(600, (i) => 140),
        movementEntries: [],
        autoFetalMovement: [],
        createdOn: DateTime.now(),
        live: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestCard(testDetails: test),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on the card
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Should navigate to DetailsView
      expect(find.byType(DetailsView), findsOneWidget);
    });

    testWidgets('should pass correct test details to DetailsView',
            (WidgetTester tester) async {
          final test = Test.withData(
            documentId: 'test_123',
            lengthOfTest: 600,
            gAge: 32,
            bpmEntries: List.generate(600, (i) => 140),
            movementEntries: [],
            autoFetalMovement: [],
            createdOn: DateTime.now(),
            live: false,
            motherName: 'Jane Doe',
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: TestCard(testDetails: test),
              ),
            ),
          );

          await tester.pumpAndSettle();

          await tester.tap(find.byType(InkWell));
          await tester.pumpAndSettle();

          final detailsView = tester.widget<DetailsView>(find.byType(DetailsView));
          expect(detailsView.test.documentId, 'test_123');
          expect(detailsView.test.motherName, 'Jane Doe');
        });
  });

  group('TestCard - Edge Cases', () {
    testWidgets('should handle null movementEntries gracefully',
            (WidgetTester tester) async {
          final test = Test.withData(
            documentId: 'test_123',
            lengthOfTest: 600,
            gAge: 32,
            bpmEntries: List.generate(600, (i) => 140),
            movementEntries: null,
            autoFetalMovement: [],
            createdOn: DateTime.now(),
            live: false,
          );

          // This should not throw an error
          expect(() => TestCard(testDetails: test), returnsNormally);
        });

    testWidgets('should render with minimal data', (WidgetTester tester) async {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 200,
        gAge: 32,
        bpmEntries: List.generate(200, (i) => 140),
        movementEntries: [],
        autoFetalMovement: [],
        createdOn: DateTime.now(),
        live: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestCard(testDetails: test),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TestCard), findsOneWidget);
    });

    testWidgets('should handle very large movement counts', (WidgetTester tester) async {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 600,
        gAge: 32,
        bpmEntries: List.generate(600, (i) => 140),
        movementEntries: List.generate(50, (i) => i),
        autoFetalMovement: List.generate(49, (i) => i),
        createdOn: DateTime.now(),
        live: false,
      );

      final card = TestCard(testDetails: test);
      expect(card.movements, '99');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: card,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(TestCard), findsOneWidget);
    });

    testWidgets('should handle very long test duration', (WidgetTester tester) async {
      final test = Test.withData(
        documentId: 'test_123',
        lengthOfTest: 5999, // 99 minutes
        gAge: 32,
        bpmEntries: List.generate(600, (i) => 140), // Not matching length intentionally
        movementEntries: [],
        autoFetalMovement: [],
        createdOn: DateTime.now(),
        live: false,
      );

      final card = TestCard(testDetails: test);
      expect(card.time, '99');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: card,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('should handle lengthOfTest at boundary 180',
            (WidgetTester tester) async {
          final test = Test.withData(
            documentId: 'test_123',
            lengthOfTest: 180, // Exactly at boundary
            gAge: 32,
            bpmEntries: List.generate(180, (i) => 140),
            movementEntries: [],
            autoFetalMovement: [],
            createdOn: DateTime.now(),
            live: false,
          );

          final card = TestCard(testDetails: test);

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: card,
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(find.byType(TestCard), findsOneWidget);
        });

    testWidgets('should handle lengthOfTest at boundary 3600',
            (WidgetTester tester) async {
          final test = Test.withData(
            documentId: 'test_123',
            lengthOfTest: 3600, // Exactly at boundary
            gAge: 32,
            bpmEntries: List.generate(600, (i) => 140),
            movementEntries: [],
            autoFetalMovement: [],
            createdOn: DateTime.now(),
            live: false,
          );

          final card = TestCard(testDetails: test);
          expect(card.time, '60');

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: card,
              ),
            ),
          );

          await tester.pumpAndSettle();
          expect(find.text('60'), findsOneWidget);
        });
  });

  group('TestCard - Live Status Styling Tests', () {
    testWidgets('should apply red decoration for live tests',
            (WidgetTester tester) async {
          final test = Test.withData(
            documentId: 'test_123',
            lengthOfTest: 600,
            gAge: 32,
            bpmEntries: List.generate(600, (i) => 140),
            movementEntries: [],
            autoFetalMovement: [],
            createdOn: DateTime.now(),
            live: true,
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: TestCard(testDetails: test),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Find the live indicator container
          final liveContainer = tester.widget<Container>(
            find.descendant(
              of: find.text('Live\nnow').first,
              matching: find.byType(Container),
            ).first,
          );

          final decoration = liveContainer.decoration as BoxDecoration;
          expect(decoration.color, Colors.red);
        });

    testWidgets('should apply proper styling to non-live date display',
            (WidgetTester tester) async {
          final test = Test.withData(
            documentId: 'test_123',
            lengthOfTest: 600,
            gAge: 32,
            bpmEntries: List.generate(600, (i) => 140),
            movementEntries: [],
            autoFetalMovement: [],
            createdOn: DateTime(2025, 5, 15),
            live: false,
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: TestCard(testDetails: test),
              ),
            ),
          );

          await tester.pumpAndSettle();

          final dateText = DateFormat('dd\nMMM').format(DateTime(2025, 5, 15));
          expect(find.text(dateText), findsOneWidget);
        });
  });
}

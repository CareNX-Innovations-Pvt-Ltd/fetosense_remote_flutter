import 'dart:async';

import 'package:fetosense_remote_flutter/core/model/mother_model.dart';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/view_models/test_crud_model.dart';
import 'package:fetosense_remote_flutter/ui/views/mother_test_list_view.dart';
import 'package:fetosense_remote_flutter/ui/widgets/test_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

@GenerateMocks([TestCRUDModel, Mother, Test])
import 'mother_test_list_view_test.mocks.dart';

void main() {
  group('MotherTestListView Widget Tests', () {
    late MockTestCRUDModel mockTestCRUDModel;
    late MockMother mockMother;

    setUp(() {
      mockTestCRUDModel = MockTestCRUDModel();
      mockMother = MockMother();

      // Setup default mock behavior
      when(mockMother.documentId).thenReturn('test-doc-id');
    });

    Widget createTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<TestCRUDModel>.value(
            value: mockTestCRUDModel,
            child: child,
          ),
        ),
      );
    }

    testWidgets('should create state', (WidgetTester tester) async {
      // Arrange
      when(mockTestCRUDModel.fetchTestsAsStream('test-doc-id'))
          .thenAnswer((_) => Stream.value([]));

      // Act
      await tester.pumpWidget(
        createTestWidget(MotherTestListView(mother: mockMother)),
      );

      // Assert
      expect(find.byType(MotherTestListView), findsOneWidget);
    });

    testWidgets('should display CircularProgressIndicator when loading',
            (WidgetTester tester) async {
          // Arrange
          final streamController = StreamController<List<Test>>();
          when(mockTestCRUDModel.fetchTestsAsStream('test-doc-id'))
              .thenAnswer((_) => streamController.stream);

          // Act
          await tester.pumpWidget(
            createTestWidget(MotherTestListView(mother: mockMother)),
          );
          await tester.pump();

          // Assert
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(
            find.byWidgetPredicate(
                  (widget) =>
              widget is CircularProgressIndicator &&
                  widget.valueColor?.value == Colors.black,
            ),
            findsOneWidget,
          );

          streamController.close();
        });

    testWidgets('should display "No test yet" when tests list is empty',
            (WidgetTester tester) async {
          // Arrange
          when(mockTestCRUDModel.fetchTestsAsStream('test-doc-id'))
              .thenAnswer((_) => Stream.value([]));

          // Act
          await tester.pumpWidget(
            createTestWidget(MotherTestListView(mother: mockMother)),
          );
          await tester.pumpAndSettle();

          // Assert
          expect(find.text('No test yet'), findsOneWidget);
          expect(
            find.byWidgetPredicate(
                  (widget) =>
              widget is Text &&
                  widget.data == 'No test yet' &&
                  widget.style?.fontWeight == FontWeight.w800 &&
                  widget.style?.color == Colors.grey &&
                  widget.style?.fontSize == 20,
            ),
            findsOneWidget,
          );
        });

    testWidgets('should display ListView with TestCards when tests are available',
            (WidgetTester tester) async {
          // Arrange
          final mockTest1 = MockTest();
          final mockTest2 = MockTest();
          final mockTest3 = MockTest();
          final testsList = [mockTest1, mockTest2, mockTest3];

          when(mockTestCRUDModel.fetchTestsAsStream('test-doc-id'))
              .thenAnswer((_) => Stream.value(testsList));

          // Act
          await tester.pumpWidget(
            createTestWidget(MotherTestListView(mother: mockMother)),
          );
          await tester.pumpAndSettle();

          // Assert
          expect(find.byType(ListView), findsOneWidget);
          expect(find.byType(TestCard), findsNWidgets(3));

          // Verify ListView properties
          final listView = tester.widget<ListView>(find.byType(ListView));
          expect(listView.shrinkWrap, true);
        });

    testWidgets('should display error message when stream has error',
            (WidgetTester tester) async {
          // Arrange
          final error = Exception('Database connection failed');
          when(mockTestCRUDModel.fetchTestsAsStream('test-doc-id'))
              .thenAnswer((_) => Stream.error(error));

          // Act
          await tester.pumpWidget(
            createTestWidget(MotherTestListView(mother: mockMother)),
          );
          await tester.pumpAndSettle();

          // Assert
          expect(find.textContaining('Error loading tests:'), findsOneWidget);
          expect(find.textContaining('Database connection failed'), findsOneWidget);
          expect(
            find.byWidgetPredicate(
                  (widget) =>
              widget is Text &&
                  widget.style?.color == Colors.red,
            ),
            findsOneWidget,
          );
        });

    testWidgets('should call fetchTestsAsStream with correct documentId',
            (WidgetTester tester) async {
          // Arrange
          when(mockMother.documentId).thenReturn('specific-doc-id-123');
          when(mockTestCRUDModel.fetchTestsAsStream('specific-doc-id-123'))
              .thenAnswer((_) => Stream.value([]));

          // Act
          await tester.pumpWidget(
            createTestWidget(MotherTestListView(mother: mockMother)),
          );
          await tester.pumpAndSettle();

          // Assert
          verify(mockTestCRUDModel.fetchTestsAsStream('specific-doc-id-123'))
              .called(greaterThan(0));
        });

    testWidgets('should update UI when stream emits new data',
            (WidgetTester tester) async {
          // Arrange
          final streamController = StreamController<List<Test>>();
          when(mockTestCRUDModel.fetchTestsAsStream('test-doc-id'))
              .thenAnswer((_) => streamController.stream);

          // Act
          await tester.pumpWidget(
            createTestWidget(MotherTestListView(mother: mockMother)),
          );
          await tester.pump();

          // Initially loading
          expect(find.byType(CircularProgressIndicator), findsOneWidget);

          // Emit empty list
          streamController.add([]);
          await tester.pumpAndSettle();
          expect(find.text('No test yet'), findsOneWidget);

          // Emit list with tests
          final mockTest = MockTest();
          streamController.add([mockTest]);
          await tester.pumpAndSettle();
          expect(find.byType(TestCard), findsOneWidget);

          streamController.close();
        });

    testWidgets('should build SizedBox as root widget',
            (WidgetTester tester) async {
          // Arrange
          when(mockTestCRUDModel.fetchTestsAsStream('test-doc-id'))
              .thenAnswer((_) => Stream.value([]));

          // Act
          await tester.pumpWidget(
            createTestWidget(MotherTestListView(mother: mockMother)),
          );
          await tester.pumpAndSettle();

          // Assert
          final sizedBox = find.descendant(
            of: find.byType(MotherTestListView),
            matching: find.byType(SizedBox),
          );
          expect(sizedBox, findsWidgets);
        });

    testWidgets('should store tests in state when data is received',
            (WidgetTester tester) async {
          // Arrange
          final mockTest1 = MockTest();
          final mockTest2 = MockTest();
          final testsList = [mockTest1, mockTest2];

          when(mockTestCRUDModel.fetchTestsAsStream('test-doc-id'))
              .thenAnswer((_) => Stream.value(testsList));

          // Act
          await tester.pumpWidget(
            createTestWidget(MotherTestListView(mother: mockMother)),
          );
          await tester.pumpAndSettle();

          // Assert - verify state has been updated by checking TestCards are rendered
          expect(find.byType(TestCard), findsNWidgets(2));
        });

    testWidgets('should handle multiple documentId values',
            (WidgetTester tester) async {
          // Arrange
          when(mockMother.documentId).thenReturn('doc-id-xyz');
          when(mockTestCRUDModel.fetchTestsAsStream('doc-id-xyz'))
              .thenAnswer((_) => Stream.value([]));

          // Act
          await tester.pumpWidget(
            createTestWidget(MotherTestListView(mother: mockMother)),
          );
          await tester.pumpAndSettle();

          // Assert
          verify(mockTestCRUDModel.fetchTestsAsStream('doc-id-xyz')).called(greaterThan(0));
          expect(find.text('No test yet'), findsOneWidget);
        });
  });
}
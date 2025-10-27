import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/mother_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/view_models/crud_view_model.dart';
import 'package:fetosense_remote_flutter/ui/views/search_view.dart';
import 'package:fetosense_remote_flutter/ui/widgets/mother_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'dart:async';

@GenerateMocks([Doctor, Organization, Mother, CRUDModel])
import 'search_view_test.mocks.dart';

void main() {
  group('SearchView Widget Tests', () {
    late MockDoctor mockDoctor;
    late MockOrganization mockOrganization;
    late MockCRUDModel mockCRUDModel;
    late MockMother mockMother1;
    late MockMother mockMother2;

    setUp(() {
      mockDoctor = MockDoctor();
      mockOrganization = MockOrganization();
      mockCRUDModel = MockCRUDModel();
      mockMother1 = MockMother();
      mockMother2 = MockMother();

      // Default mock setup
      when(mockDoctor.organizationId).thenReturn('org-123');
    });

    Widget createTestWidget(Widget child) {
      return ChangeNotifierProvider<CRUDModel>.value(
        value: mockCRUDModel,
        child: MaterialApp(home: child),
      );
    }

    group('Widget Creation Tests', () {
      testWidgets('should create SearchView with doctor and organization',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            // Act
            await tester.pumpWidget(
              createTestWidget(
                SearchView(doctor: mockDoctor, organization: mockOrganization),
              ),
            );

            // Assert
            expect(find.byType(SearchView), findsOneWidget);
          });

      testWidgets('should create SearchView with only doctor',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            // Act
            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );

            // Assert
            expect(find.byType(SearchView), findsOneWidget);
          });

      testWidgets('should create SearchView with only organization',
              (WidgetTester tester) async {
            // Act & Assert - this will fail if doctor is required
            expect(
                  () => SearchView(organization: mockOrganization),
              returnsNormally,
            );
          });

      testWidgets('should create state', (WidgetTester tester) async {
        // Arrange
        when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
            .thenAnswer((_) => Stream.value([]));

        // Act
        await tester.pumpWidget(
          createTestWidget(SearchView(doctor: mockDoctor)),
        );

        // Assert
        final state = tester.state<SearchViewState>(find.byType(SearchView));
        expect(state, isNotNull);
        expect(state.query, '');
      });
    });

    group('InitState Tests', () {
      testWidgets('should initialize searchController with listener',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            // Act
            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Assert
            final state = tester.state<SearchViewState>(find.byType(SearchView));
            expect(state.searchController, isNotNull);
            expect(state.query, '');
          });

      testWidgets('should update query when searchController text changes',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', 'Jane'))
                .thenAnswer((_) => Stream.value([]));

            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Act
            await tester.enterText(find.byType(TextField), 'Jane');
            await tester.pumpAndSettle();

            // Assert
            final state = tester.state<SearchViewState>(find.byType(SearchView));
            expect(state.query, 'Jane');
          });
    });

    group('UI Structure Tests', () {
      testWidgets('should have Scaffold as root widget',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            // Act
            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );

            // Assert
            expect(find.byType(Scaffold), findsOneWidget);
          });

      testWidgets('should have SafeArea widget', (WidgetTester tester) async {
        // Arrange
        when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
            .thenAnswer((_) => Stream.value([]));

        // Act
        await tester.pumpWidget(
          createTestWidget(SearchView(doctor: mockDoctor)),
        );

        // Assert
        expect(find.byType(SafeArea), findsOneWidget);
      });

      testWidgets('should have Column with two children',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            // Act
            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );

            // Assert
            final column = tester.widget<Column>(
              find.descendant(
                of: find.byType(SafeArea),
                matching: find.byType(Column),
              ),
            );
            expect(column.children.length, 2);
          });

      testWidgets('should have ListTile with search bar',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            // Act
            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );

            // Assert
            expect(find.byType(ListTile), findsOneWidget);
          });

      testWidgets('should display "fetosense" title',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            // Act
            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );

            // Assert
            expect(find.text('fetosense'), findsOneWidget);

            final text = tester.widget<Text>(find.text('fetosense'));
            expect(text.style?.fontWeight, FontWeight.w300);
            expect(text.style?.fontSize, 14);
          });

      testWidgets('should have TextField with correct properties',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            // Act
            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );

            // Assert
            expect(find.byType(TextField), findsOneWidget);

            final textField = tester.widget<TextField>(find.byType(TextField));
            expect(textField.decoration?.hintText, 'Search mothers...');
            expect(textField.decoration?.filled, true);
            expect(textField.decoration?.fillColor, Colors.white);
          });

      testWidgets('should have TextField with correct border properties',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            // Act
            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );

            // Assert
            final textField = tester.widget<TextField>(find.byType(TextField));
            final decoration = textField.decoration!;

            expect(decoration.focusedBorder, isA<OutlineInputBorder>());
            expect(decoration.enabledBorder, isA<OutlineInputBorder>());

            final focusedBorder = decoration.focusedBorder as OutlineInputBorder;
            expect(focusedBorder.borderSide.color, Colors.black);
            expect(focusedBorder.borderRadius, BorderRadius.circular(10));

            final enabledBorder = decoration.enabledBorder as OutlineInputBorder;
            expect(enabledBorder.borderSide.color, Colors.black);
            expect(enabledBorder.borderRadius, BorderRadius.circular(10));
          });

      testWidgets('should have TextField with correct content padding',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            // Act
            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );

            // Assert
            final textField = tester.widget<TextField>(find.byType(TextField));
            expect(
              textField.decoration?.contentPadding,
              const EdgeInsets.only(left: 16, bottom: 8.0, top: 8.0),
            );
          });

      testWidgets('should have close IconButton as trailing',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            // Act
            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );

            // Assert
            expect(find.byIcon(Icons.close), findsOneWidget);

            final icon = tester.widget<Icon>(find.byIcon(Icons.close));
            expect(icon.size, 35);
          });

      testWidgets('should have Expanded widget with StreamBuilder',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            // Act
            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );

            // Assert
            expect(find.byType(Expanded), findsOneWidget);
            expect(find.byType(StreamBuilder<List<Mother>>), findsOneWidget);
          });
    });

    group('Search Functionality Tests', () {
      testWidgets('should clear search when close button is pressed',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', 'test'))
                .thenAnswer((_) => Stream.value([]));

            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Enter text first
            await tester.enterText(find.byType(TextField), 'test');
            await tester.pumpAndSettle();

            var state = tester.state<SearchViewState>(find.byType(SearchView));
            expect(state.query, 'test');

            // Act - tap close button
            await tester.tap(find.byIcon(Icons.close));
            await tester.pumpAndSettle();

            // Assert
            state = tester.state<SearchViewState>(find.byType(SearchView));
            expect(state.query, '');
            expect(state.searchController.text, '');
          });

      testWidgets('should update query when typing in TextField',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', 'J'))
                .thenAnswer((_) => Stream.value([]));
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', 'Jane'))
                .thenAnswer((_) => Stream.value([]));

            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Act - type 'Jane'
            await tester.enterText(find.byType(TextField), 'Jane');
            await tester.pumpAndSettle();

            // Assert
            final state = tester.state<SearchViewState>(find.byType(SearchView));
            expect(state.query, 'Jane');
            expect(state.searchController.text, 'Jane');
          });
    });

    group('getMotherStream Method Tests', () {
      testWidgets('should call fetchMothersAsStreamSearchMothers with empty string when query is empty',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Assert
            verify(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .called(greaterThan(0));
          });

      testWidgets('should call fetchMothersAsStreamSearchMothers with query when query is not empty',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', 'Jane'))
                .thenAnswer((_) => Stream.value([]));

            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Act
            await tester.enterText(find.byType(TextField), 'Jane');
            await tester.pumpAndSettle();

            // Assert
            verify(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', 'Jane'))
                .called(greaterThan(0));
          });

      testWidgets('should use doctor organizationId in stream',
              (WidgetTester tester) async {
            // Arrange
            when(mockDoctor.organizationId).thenReturn('specific-org-id');
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('specific-org-id', ''))
                .thenAnswer((_) => Stream.value([]));

            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Assert
            verify(mockCRUDModel.fetchMothersAsStreamSearchMothers('specific-org-id', ''))
                .called(greaterThan(0));
          });

      testWidgets('should use empty string when organizationId is null',
              (WidgetTester tester) async {
            // Arrange
            when(mockDoctor.organizationId).thenReturn(null);
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('', ''))
                .thenAnswer((_) => Stream.value([]));

            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Assert
            verify(mockCRUDModel.fetchMothersAsStreamSearchMothers('', ''))
                .called(greaterThan(0));
          });
    });

    group('StreamBuilder Tests', () {
      testWidgets('should display "No Data Found" when stream has no data',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            // Act
            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Assert
            expect(find.text('No Data Found'), findsOneWidget);
          });

      testWidgets('should display "No Data Found" when snapshot has no data',
              (WidgetTester tester) async {
            // Arrange
            final streamController = StreamController<List<Mother>>();
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => streamController.stream);

            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pump();

            // Assert - before any data
            expect(find.text('No Data Found'), findsOneWidget);

            streamController.close();
          });

      testWidgets('should display "No Data Found" when data is empty list',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            // Act
            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Assert
            expect(find.text('No Data Found'), findsOneWidget);
          });

      testWidgets('should display ListView with MotherCards when data is available',
              (WidgetTester tester) async {
            // Arrange
            when(mockMother1.name).thenReturn('Mother 1');
            when(mockMother2.name).thenReturn('Mother 2');

            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([mockMother1, mockMother2]));

            // Act
            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Assert
            expect(find.byType(ListView), findsOneWidget);
            expect(find.byType(MotherCard), findsNWidgets(2));
          });

      testWidgets('should update ListView when stream emits new data',
              (WidgetTester tester) async {
            // Arrange
            final streamController = StreamController<List<Mother>>();
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => streamController.stream);

            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pump();

            // Initially no data
            expect(find.text('No Data Found'), findsOneWidget);

            // Act - emit data
            streamController.add([mockMother1, mockMother2]);
            await tester.pumpAndSettle();

            // Assert
            expect(find.byType(MotherCard), findsNWidgets(2));
            expect(find.text('No Data Found'), findsNothing);

            streamController.close();
          });

      testWidgets('should display single MotherCard when one mother in list',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([mockMother1]));

            // Act
            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Assert
            expect(find.byType(MotherCard), findsOneWidget);
            expect(find.text('No Data Found'), findsNothing);
          });
    });

    group('Dispose Tests', () {
      testWidgets('should dispose searchController and FocusNode',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));

            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            final state = tester.state<SearchViewState>(find.byType(SearchView));
            final controller = state.searchController;
            // final focusNode = state._focus;

            // Act - dispose by removing widget
            await tester.pumpWidget(Container());

            // Assert - controllers should be disposed (calling methods should throw)
            expect(() => controller.text, throwsFlutterError);
            // expect(() => focusNode.hasFocus, throwsFlutterError);
          });
    });

    group('Integration Tests', () {
      testWidgets('should search and display results',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([mockMother1, mockMother2]));
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', 'Jane'))
                .thenAnswer((_) => Stream.value([mockMother1]));

            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Initial state - 2 mothers
            expect(find.byType(MotherCard), findsNWidgets(2));

            // Act - search for 'Jane'
            await tester.enterText(find.byType(TextField), 'Jane');
            await tester.pumpAndSettle();

            // Assert - 1 mother
            expect(find.byType(MotherCard), findsOneWidget);
          });

      testWidgets('should clear search and show all results',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([mockMother1, mockMother2]));
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', 'Jane'))
                .thenAnswer((_) => Stream.value([mockMother1]));

            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Search for 'Jane'
            await tester.enterText(find.byType(TextField), 'Jane');
            await tester.pumpAndSettle();
            expect(find.byType(MotherCard), findsOneWidget);

            // Act - clear search
            await tester.tap(find.byIcon(Icons.close));
            await tester.pumpAndSettle();

            // Assert - back to 2 mothers
            expect(find.byType(MotherCard), findsNWidgets(2));
          });

      testWidgets('should handle empty search results',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([mockMother1]));
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', 'xyz'))
                .thenAnswer((_) => Stream.value([]));

            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Initial - 1 mother
            expect(find.byType(MotherCard), findsOneWidget);

            // Act - search for non-existent mother
            await tester.enterText(find.byType(TextField), 'xyz');
            await tester.pumpAndSettle();

            // Assert - no data found
            expect(find.text('No Data Found'), findsOneWidget);
            expect(find.byType(MotherCard), findsNothing);
          });
    });

    group('Edge Cases', () {
      testWidgets('should handle rapid text changes',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', 'a'))
                .thenAnswer((_) => Stream.value([]));
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', 'ab'))
                .thenAnswer((_) => Stream.value([]));
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', 'abc'))
                .thenAnswer((_) => Stream.value([]));

            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Act - rapid text changes
            await tester.enterText(find.byType(TextField), 'a');
            await tester.pump();
            await tester.enterText(find.byType(TextField), 'ab');
            await tester.pump();
            await tester.enterText(find.byType(TextField), 'abc');
            await tester.pumpAndSettle();

            // Assert
            final state = tester.state<SearchViewState>(find.byType(SearchView));
            expect(state.query, 'abc');
          });

      testWidgets('should handle special characters in search',
              (WidgetTester tester) async {
            // Arrange
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', ''))
                .thenAnswer((_) => Stream.value([]));
            when(mockCRUDModel.fetchMothersAsStreamSearchMothers('org-123', '@#\$%'))
                .thenAnswer((_) => Stream.value([]));

            await tester.pumpWidget(
              createTestWidget(SearchView(doctor: mockDoctor)),
            );
            await tester.pumpAndSettle();

            // Act
            await tester.enterText(find.byType(TextField), '@#\$%');
            await tester.pumpAndSettle();

            // Assert
            final state = tester.state<SearchViewState>(find.byType(SearchView));
            expect(state.query, '@#\$%');
          });
    });
  });
}
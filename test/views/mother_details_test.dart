import 'package:fetosense_remote_flutter/core/model/mother_model.dart';
import 'package:fetosense_remote_flutter/ui/views/mother_test_list_view.dart';
import 'package:fetosense_remote_flutter/ui/views/mothers_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:intl/intl.dart';

// Mock classes
class MockMother extends Mock implements Mother {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockMother mockMother;
  late MockNavigatorObserver mockObserver;

  setUp(() {
    mockMother = MockMother();
    mockObserver = MockNavigatorObserver();
  });

  Widget createWidget() => MaterialApp(
    home: MotherDetails(mother: mockMother),
    navigatorObservers: [mockObserver],
  );

  group('MotherUtils unit tests', () {
    test('getGestAge returns 0 if edd is null', () {
      expect(MotherUtils.getGestAge(null), 0);
    });

    test('getGestAge calculates correct weeks for future EDD', () {
      final futureEdd = DateTime.now().add(const Duration(days: 140));
      expect(MotherUtils.getGestAge(futureEdd), 20);
    });

    test('getGestAge clamps to 0 if EDD far in future', () {
      final futureEdd = DateTime.now().add(const Duration(days: 300));
      expect(MotherUtils.getGestAge(futureEdd), 0);
    });

    test('getGestAge clamps to 42 if EDD in past', () {
      final pastEdd = DateTime.now().subtract(const Duration(days: 100));
      expect(MotherUtils.getGestAge(pastEdd), 42);
    });

    test('getMonthName returns correct month for 1-12', () {
      expect(MotherUtils.getMonthName(1), 'JAN');
      expect(MotherUtils.getMonthName(12), 'DEC');
    });

    test('getMonthName returns DEC for invalid months', () {
      expect(MotherUtils.getMonthName(0), 'DEC');
      expect(MotherUtils.getMonthName(13), 'DEC');
      expect(MotherUtils.getMonthName(-5), 'DEC');
    });
  });

  group('MotherDetails widget tests', () {
    testWidgets('displays mother name or Unknown', (tester) async {
      when(() => mockMother.name).thenReturn('Jane Doe');
      when(() => mockMother.edd).thenReturn(DateTime.now());

      await tester.pumpWidget(createWidget());
      expect(find.text('Jane Doe'), findsOneWidget);

      when(() => mockMother.name).thenReturn(null);
      await tester.pumpWidget(createWidget());
      expect(find.text('Unknown'), findsOneWidget);
    });

    testWidgets('displays gestational age in weeks', (tester) async {
      final futureEdd = DateTime.now().add(const Duration(days: 140));
      when(() => mockMother.edd).thenReturn(futureEdd);
      when(() => mockMother.name).thenReturn('Test');

      await tester.pumpWidget(createWidget());
      expect(find.text('20'), findsOneWidget);
      expect(find.text('weeks'), findsOneWidget);
    });

    testWidgets('displays formatted EDD or "EDD not available"', (tester) async {
      final eddDate = DateTime(2025, 6, 15);
      when(() => mockMother.name).thenReturn('Test Mother');
      when(() => mockMother.edd).thenReturn(eddDate);

      await tester.pumpWidget(createWidget());
      final expectedEddText = "EDD - ${DateFormat('dd MMM yyyy').format(eddDate)}";
      expect(find.text(expectedEddText), findsOneWidget);

      when(() => mockMother.edd).thenReturn(null);
      await tester.pumpWidget(createWidget());
      expect(find.text('EDD not available'), findsOneWidget);
    });

    testWidgets('back button pops navigator', (tester) async {
      when(() => mockMother.name).thenReturn('Test');
      when(() => mockMother.edd).thenReturn(DateTime.now());

      await tester.pumpWidget(createWidget());
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPop(any(), any())).called(1);
    });

    testWidgets('renders MotherTestListView', (tester) async {
      when(() => mockMother.name).thenReturn('Test');
      when(() => mockMother.edd).thenReturn(DateTime.now());

      await tester.pumpWidget(createWidget());
      expect(find.byType(MotherTestListView), findsOneWidget);
    });
  });
}

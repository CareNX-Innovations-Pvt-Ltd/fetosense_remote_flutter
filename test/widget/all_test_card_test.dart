import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/ui/views/details_view.dart';
import 'package:fetosense_remote_flutter/ui/widgets/all_test_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';

class MockTest extends Fake implements Test {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockTest());
  });

  Widget wrap(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, _) => MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  Test buildTest({
    required bool live,
    required int lengthOfTest,
    required int bpmLength,
    required int movementsCount,
  }) {
    final test = Test.withData(
      id: '1',
      documentId: 'doc1',
      motherId: 'mother1',
      deviceId: 'device1',
      doctorId: 'doctor1',
      weight: 70,
      gAge: 30,
      age: 25,
      fisherScore: 8,
      fisherScore2: 9,
      motherName: 'Mother One',
      deviceName: 'Device One',
      doctorName: 'Doctor One',
      patientId: 'patient1',
      organizationId: 'org1',
      organizationName: 'Organization One',
      imageLocalPath: '/local/path',
      imageFirePath: '/fire/path',
      audioLocalPath: '/local/audio/path',
      audioFirePath: '/fire/audio/path',
      isImgSynced: true,
      isAudioSynced: true,
      bpmEntries: [120, 130, 140],
      bpmEntries2: [125, 135, 145],
      baseLineEntries: [130, 130, 130],
      movementEntries: [1, 0, 1],
      autoFetalMovement: [0, 1, 0],
      tocoEntries: [10, 20, 15],
      lengthOfTest: 30,
      averageFHR: 135,
      live: true,
      testByMother: false,
      testById: 'tester1',
      interpretationType: 'Normal',
      interpretationExtraComments: 'No issues',
      associations: {'key1': 'value1'},
      autoInterpretations: {'autoKey1': 'autoValue1'},
      delete: false,
      createdOn: DateTime.parse('2023-10-27T10:00:00.000Z'),
      createdBy: 'creator1',
    );

    // Mock isLive()
    return test;
  }

  group('AllTestCard', () {
    testWidgets('displays live view with short time & movements < 10', (tester) async {
      final test = buildTest(
        live: true,
        lengthOfTest: 300, // > 180 && < 3600
        bpmLength: 200,    // > 180 && < 3600
        movementsCount: 5, // < 10
      );

      await tester.pumpWidget(wrap(AllTestCard(testDetails: test)));

      expect(find.textContaining('Live'), findsOneWidget);
      expect(find.text('Jane Doe '), findsOneWidget);
      expect(find.textContaining('Movements'), findsOneWidget);
    });

    testWidgets('displays date view with long time & movements >= 10', (tester) async {
      final test = buildTest(
        live: false,
        lengthOfTest: 4000, // > 3600
        bpmLength: 50,      // < 180
        movementsCount: 15, // >= 10
      );

      await tester.pumpWidget(wrap(AllTestCard(testDetails: test)));

      final expectedDate = DateFormat('dd\nMMM').format(test.createdOn!);
      expect(find.text(expectedDate), findsOneWidget);
    });

    testWidgets('navigates to DetailsView on tap', (tester) async {
      final test = buildTest(
        live: true,
        lengthOfTest: 200,
        bpmLength: 200,
        movementsCount: 5,
      );

      await tester.pumpWidget(MaterialApp(
        home: AllTestCard(testDetails: test),
      ));

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      expect(find.byType(DetailsView), findsOneWidget);
    });

    testWidgets('handles null autoInterpretations and shows --', (tester) async {
      final test = buildTest(
        live: false,
        lengthOfTest: 200,
        bpmLength: 50,
        movementsCount: 0,
      )..autoInterpretations = null;

      await tester.pumpWidget(wrap(AllTestCard(testDetails: test)));

      expect(find.textContaining('-- Basal HR'), findsOneWidget);
    });
  });
}

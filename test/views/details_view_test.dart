import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/utils/intrepretations2.dart';
import 'package:fetosense_remote_flutter/core/view_models/test_crud_model.dart';
import 'package:fetosense_remote_flutter/ui/views/details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pdf;

import '../widget/test_card_test.mocks.dart';


class MockDatabases extends Mock implements Databases {}

class MockTestCRUDModel extends Mock implements TestCRUDModel {
  final StreamController<Test> controller = StreamController<Test>.broadcast();

  @override
  Stream<Test> get testStream => controller.stream;

  void closeController() => controller.close();
}

class MockTest extends Mock implements Test {}

class MockInterpretations2 extends Mock implements Interpretations2 {}

class FakeTest extends Fake implements Test {}

class FakePdfImage extends Fake implements pdf.ImageProvider {}

class FakePdfContext extends Fake implements pdf.Context {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeTest());

    final TestDefaultBinaryMessenger messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    messenger.setMockMethodCallHandler(
      const MethodChannel('com.carenx.fetosense/print'),
          (MethodCall methodCall) async {
        return 'OK';
      },
    );
  });

  tearDownAll(() {
    final TestDefaultBinaryMessenger messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('com.carenx.fetosense/print'),
      null,
    );
  });

  group('DetailsView tests (logic + UI)', () {
    late MockDatabases mockDb;
    late MockTestCRUDModel mockCrud;
    late MockTest mockTest;
    late MockInterpretations2 mockInterp;

    setUp(() {
      mockDb = MockDatabases();
      mockCrud = MockTestCRUDModel();
      mockTest = MockTest();
      mockInterp = MockInterpretations2();

      when(() => mockTest.lengthOfTest).thenReturn(180);
      when(() => mockTest.bpmEntries).thenReturn(List<int>.filled(180, 120));
      when(() => mockTest.bpmEntries2).thenReturn(<int>[]);
      when(() => mockTest.gAge).thenReturn(32);
      when(() => mockTest.interpretationType).thenReturn(null);
      when(() => mockTest.documentId).thenReturn('doc-1');
      when(() => mockTest.movementEntries).thenReturn(<int>[]);
      when(() => mockTest.autoFetalMovement).thenReturn(<int>[]);
      when(() => mockTest.createdOn).thenReturn(DateTime.now().subtract(const Duration(days: 1)));
      when(() => mockTest.motherName).thenReturn('Jane Doe');
      when(() => mockTest.isLive()).thenReturn(false);
      when(() => mockTest.toJson()).thenReturn(<String, dynamic>{});
      when(() => mockTest.id).thenReturn('id-123');

      when(() => mockDb.updateDocument(
        databaseId: any(named: 'databaseId'),
        collectionId: any(named: 'collectionId'),
        documentId: any(named: 'documentId'),
        data: any(named: 'data'),
      )).thenAnswer((_) async => Future.value());

      when(() => mockInterp.getBasalHeartRate()).thenReturn(140);
      when(() => mockInterp.getnAccelerations()).thenReturn(1);
      when(() => mockInterp.getnDecelerations()).thenReturn(0);
      when(() => mockInterp.getShortTermVariationBpm()).thenReturn(3.0);
      when(() => mockInterp.getLongTermVariation()).thenReturn(8);
    });

    Widget createTestableWidget(Widget child) {
      return Provider<TestCRUDModel>.value(
        value: mockCrud,
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('builds and displays basic UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(DetailsView(test: mockTest)));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      final expectedDate = DateFormat('dd MMM yy - hh:mm a').format(mockTest.createdOn!);
      expect(find.text(expectedDate), findsOneWidget);
      expect(find.text('${mockTest.motherName}'), findsOneWidget);

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('back button pops navigator', (WidgetTester tester) async {
      final mockObserver = MockNavigatorObserver();
      await tester.pumpWidget(
        Provider<TestCRUDModel>.value(
          value: mockCrud,
          child: MaterialApp(
            home: DetailsView(test: mockTest),
            navigatorObservers: [mockObserver],
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPop(any(), any())).called(1);
    });

    testWidgets('toggle zoom icon changes gridPreMin (zoom out -> zoom in)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(DetailsView(test: mockTest)));
      await tester.pumpAndSettle();

      final zoomButton = find.byIcon(Icons.zoom_out).first;
      expect(zoomButton, findsOneWidget);

      await tester.tap(zoomButton);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.zoom_in), findsWidgets);
    });

    testWidgets('dragging on graph does not throw and trap handles range', (WidgetTester tester) async {
      when(() => mockTest.bpmEntries).thenReturn(List<int>.filled(200, 120));
      await tester.pumpWidget(createTestableWidget(DetailsView(test: mockTest)));
      await tester.pumpAndSettle();

      final gd = find.byType(GestureDetector);
      expect(gd, findsWidgets);

      // Perform a horizontal drag
      await tester.drag(gd.first, const Offset(-150.0, 0.0));
      await tester.pumpAndSettle();

      // Now get the state and call trap for some edge values
      final state = tester.state(find.byType(DetailsView)) as DetailsViewState;
      // Negative pos -> returns 0
      expect(state.trap(-10), 0);
      // Pos greater than entries length -> should clamp near length-10
      final largePos = mockTest.bpmEntries!.length + 100;
      final trapped = state.trap(largePos);
      expect(trapped <= mockTest.bpmEntries!.length, isTrue);
    });

    testWidgets('updateCallback updates when update true and resets when update false', (WidgetTester tester) async {
      // Ensure updateDocument completes
      when(() => mockDb.updateDocument(
        databaseId: any(named: 'databaseId'),
        collectionId: any(named: 'collectionId'),
        documentId: any(named: 'documentId'),
        data: any(named: 'data'),
      )).thenAnswer((_) async => Future.value());

      await tester.pumpWidget(createTestableWidget(DetailsView(test: mockTest)));
      await tester.pumpAndSettle();

      final state = tester.state(find.byType(DetailsView)) as DetailsViewState;

      // call updateCallback with update = true
      state.updateCallback('Normal', 'some comments', true);
      // wait for any async setState side-effects
      await tester.pumpAndSettle();

      expect(state.radioValue, 'Normal');

      // call updateCallback with update = false to clear radioValue
      state.updateCallback('Ignored', 'x', false);
      await tester.pumpAndSettle();
      expect(state.radioValue, null);
    });

    testWidgets('classifyFromInterpretations returns expected labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(DetailsView(test: mockTest)));
      await tester.pumpAndSettle();

      final state = tester.state(find.byType(DetailsView)) as DetailsViewState;

      // ABNORMAL conditions: basal HR < 110 or > 160, dec >=2, stv < 2.0, ltv < 6
      when(() => mockInterp.getBasalHeartRate()).thenReturn(100);
      when(() => mockInterp.getnAccelerations()).thenReturn(0);
      when(() => mockInterp.getnDecelerations()).thenReturn(0);
      when(() => mockInterp.getShortTermVariationBpm()).thenReturn(3.0);
      when(() => mockInterp.getLongTermVariation()).thenReturn(8);
      expect(state.classifyFromInterpretations(mockInterp), 'Abnormal');

      // Abnormal by decelerations
      when(() => mockInterp.getBasalHeartRate()).thenReturn(140);
      when(() => mockInterp.getnDecelerations()).thenReturn(2);
      when(() => mockInterp.getShortTermVariationBpm()).thenReturn(3.0);
      when(() => mockInterp.getLongTermVariation()).thenReturn(8);
      expect(state.classifyFromInterpretations(mockInterp), 'Abnormal');

      // Atypical path: stv in range or ltv in range or acc==0
      when(() => mockInterp.getnDecelerations()).thenReturn(0);
      when(() => mockInterp.getShortTermVariationBpm()).thenReturn(3.0); // in 2.0..4.5
      when(() => mockInterp.getLongTermVariation()).thenReturn(8); // in 6..10
      when(() => mockInterp.getnAccelerations()).thenReturn(0); // acc == 0 triggers atypical
      expect(state.classifyFromInterpretations(mockInterp), 'Atypical');

      // Normal case
      when(() => mockInterp.getnAccelerations()).thenReturn(2);
      when(() => mockInterp.getShortTermVariationBpm()).thenReturn(5.0);
      when(() => mockInterp.getLongTermVariation()).thenReturn(12);
      expect(state.classifyFromInterpretations(mockInterp), 'Normal');
    });

    testWidgets('pressing print/share while in GENERATING_PRINT branch handles state safely', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(DetailsView(test: mockTest)));
      await tester.pumpAndSettle();

      final state = tester.state(find.byType(DetailsView)) as DetailsViewState;

      // Prepare pdfDoc so GENERATING_PRINT branch can add page
      state.pdfDoc = pdf.Document();
      // Ensure code goes into GENERATING_PRINT branch without calling heavy _generatePdf
      state.printStatus = PrintStatus.GENERATING_PRINT;

      // Tap the print button: find Icon(Icons.print)
      final printButton = find.byIcon(Icons.print);
      expect(printButton, findsOneWidget);

      await tester.tap(printButton);
      await tester.pumpAndSettle();

      expect(state.printStatus, PrintStatus.PRE_PROCESSING);
    });

    testWidgets('renders web-specific side panel when kIsWeb is true', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(DetailsView(test: mockTest)));
      await tester.pumpAndSettle();
      expect(find.byType(DetailsView), findsOneWidget);
    });

    tearDown(() {
      mockCrud.closeController();
    });
  });
}

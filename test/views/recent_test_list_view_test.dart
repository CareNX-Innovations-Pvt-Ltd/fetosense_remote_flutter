import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/view_models/test_crud_model.dart';
import 'package:fetosense_remote_flutter/ui/views/recent_test_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/ui/widgets/all_test_card.dart';


class MockDatabases extends Mock implements Databases {}

class MockAppwriteService extends Mock implements AppwriteService {}

class MockTestCrudModel extends Mock implements TestCRUDModel {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockFlutterToast extends Mock implements Fluttertoast {}

class MockLaunchUrl extends Mock {
  Future<bool> call(Uri url);
}

// ---------------------- MAIN TEST ----------------------

void main() {
  late MockDatabases mockDatabases;
  late MockTestCrudModel mockTestCrudModel;
  late Doctor testDoctor;
  late Organization testOrg;
  late NavigatorObserver mockObserver;

  setUp(() {
    mockDatabases = MockDatabases();
    mockTestCrudModel = MockTestCrudModel();
    mockObserver = MockNavigatorObserver();
    testDoctor =
        Doctor(name: 'Dr. John', documentId: 'doc123', );
    testOrg = Organization();
  });

  Widget buildTestable(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TestCRUDModel>.value(value: mockTestCrudModel),
      ],
      child: MaterialApp(
        home: child,
        navigatorObservers: [mockObserver],
      ),
    );
  }

  group('RecentTestListView Tests', () {
    testWidgets('initState calls getPaasKeys and sets doctor', (tester) async {
      when(mockDatabases.getDocument(
        databaseId: 'databaseId',
        collectionId: 'collectionId',
        documentId: 'documentId',
        queries: anyNamed('queries'),
      )).thenAnswer((_) async => models.Document(data: {'fetosense': '123'}, $id: '', $collectionId: '', $databaseId: '', $createdAt: '', $updatedAt: '', $permissions: []));

      await tester.pumpWidget(buildTestable(
        RecentTestListView(
          doctor: testDoctor,
          databases: mockDatabases,
        ),
      ));

      await tester.pumpAndSettle();
      verify(mockDatabases.getDocument(
        databaseId: 'databaseId',
        collectionId: 'collectionId',
        documentId: 'documentId',
        queries: anyNamed('queries'),
      )).called(1);
    });

    testWidgets('shows "No test yet" when no tests are available',
        (tester) async {
      testDoctor.organizationId = 'org123';
      when(mockTestCrudModel.fetchAllTestsAsStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(buildTestable(
        RecentTestListView(
          doctor: testDoctor,
          databases: mockDatabases,
        ),
      ));

      await tester.pump();
      expect(find.text('No test yet'), findsOneWidget);
    });

    testWidgets('shows tests when available', (tester) async {
      testDoctor.organizationId = 'org123';
      final testList = [Test.withData(documentId: 't1')];
      when(mockTestCrudModel.fetchAllTestsAsStream(any))
          .thenAnswer((_) => Stream.value(testList));

      await tester.pumpWidget(buildTestable(
        RecentTestListView(
          doctor: testDoctor,
          databases: mockDatabases,
        ),
      ));

      await tester.pump();
      expect(find.byType(AllTestCard), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when waiting', (tester) async {
      testDoctor.organizationId = 'org123';
      final controller = StreamController<List<Test>>();
      when(mockTestCrudModel.fetchAllTestsAsStream(any))
          .thenAnswer((_) => controller.stream);

      await tester.pumpWidget(buildTestable(
        RecentTestListView(
          doctor: testDoctor,
          databases: mockDatabases,
        ),
      ));

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      controller.close();
    });

    testWidgets('shows error message when stream has error', (tester) async {
      testDoctor.organizationId = 'org123';
      when(mockTestCrudModel.fetchAllTestsAsStream(any))
          .thenAnswer((_) => Stream.error('Some error'));

      await tester.pumpWidget(buildTestable(
        RecentTestListView(
          doctor: testDoctor,
          databases: mockDatabases,
        ),
      ));

      await tester.pump();
      expect(find.textContaining('Something went wrong'), findsOneWidget);
    });

    testWidgets('builds welcome screen when doctor.organizationId is empty',
        (tester) async {
      await tester.pumpWidget(buildTestable(
        RecentTestListView(
          doctor: testDoctor,
          databases: mockDatabases,
        ),
      ));
      await tester.pump();
      expect(find.text('Welcome back,'), findsOneWidget);
      expect(find.textContaining('Dr. John'), findsOneWidget);
    });

    testWidgets('tap on Scan QR button changes state', (tester) async {
      await tester.pumpWidget(buildTestable(
        RecentTestListView(
          doctor: testDoctor,
          databases: mockDatabases,
        ),
      ));

      await tester.tap(find.text('Scan QR'));
      await tester.pump();
      expect(find.byType(MaterialButton), findsOneWidget);
    });

    testWidgets('updateOrg with empty code shows toast', (tester) async {
      final view = RecentTestListView(
        doctor: testDoctor,
        databases: mockDatabases,
      );
      final state = view.createState();
      await tester.pumpWidget(buildTestable(view));
      await tester.runAsync(() async {
        await state.updateOrg('');
      });
      expect(state.isEditOrg, isFalse);
    });

    testWidgets('getDevice shows SnackBar on empty documents', (tester) async {
      when(mockDatabases.listDocuments(
        databaseId: 'databaseId',
        collectionId: 'collectionId',
        queries: anyNamed('queries'),
      )).thenAnswer((_) async => models.DocumentList(total: 0, documents: []));

      final view = RecentTestListView(
        doctor: testDoctor,
        databases: mockDatabases,
      );

      await tester.pumpWidget(buildTestable(view));
      final state = tester.state(find.byType(RecentTestListView))
          as RecentTestListViewState;
      await tester.runAsync(() async {
        await state.getDevice('key');
      });
      await tester.pump();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('getOrganization handles exception', (tester) async {
      when(mockDatabases.getDocument(
        databaseId: 'databaseId',
        collectionId: 'collectionId',
        documentId: 'documentId',
      )).thenThrow(Exception('error'));

      final view = RecentTestListView(
        doctor: testDoctor,
        databases: mockDatabases,
      );

      await tester.pumpWidget(buildTestable(view));
      final state = tester.state(find.byType(RecentTestListView))
          as RecentTestListViewState;

      await tester.runAsync(() async {
        state.getOrganization('id123');
      });

      expect(state.isEditOrg, isFalse);
    });

    testWidgets('setDeviceAssociations executes successfully', (tester) async {
      final deviceDoc = models.Document(
        data: {
          'type': 'device',
          'organizationId': 'org1',
          'associations': {},
        },
        $id: "",
        $collectionId: '',
        $databaseId: '',
        $createdAt: '',
        $updatedAt: '',
        $permissions: [],
      );

      when(mockDatabases.listDocuments(
        databaseId: 'databaseId',
        collectionId: 'collectionId',
        queries: anyNamed('queries'),
      )).thenAnswer(
          (_) async => models.DocumentList(total: 1, documents: [deviceDoc]));

      final view = RecentTestListView(
        doctor: testDoctor,
        databases: mockDatabases,
      );

      await tester.pumpWidget(buildTestable(view));
      final state = tester.state(find.byType(RecentTestListView))
          as RecentTestListViewState;

      await tester.runAsync(() async {
        await state.setDeviceAssociations('org1');
      });

      verify(mockDatabases.listDocuments(
        databaseId: 'databaseId',
        collectionId: 'collectionId',
        queries: anyNamed('queries'),
      )).called(1);
    });
  });
}

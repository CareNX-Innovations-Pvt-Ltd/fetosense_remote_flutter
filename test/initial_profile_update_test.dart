import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fetosense_remote_flutter/app_router.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:fetosense_remote_flutter/ui/views/initial_profile_update1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'initial_profile_update_test.mocks.dart';

@GenerateMocks(
    [BaseAuth, AppwriteService, Client, Databases, Document, Response])
void main() {
  group('InitialProfileUpdate Tests', () {
    late MockBaseAuth mockAuth;
    late MockAppwriteService mockAppwriteService;
    late MockClient mockClient;
    late MockDatabases mockDatabases;
    late MockDocument mockDocument;
    late MockResponse mockResponse;
    late Doctor testDoctor;
    late GoRouter _router;

    setUp(() {
      mockAuth = MockBaseAuth();
      mockAppwriteService = MockAppwriteService();
      mockClient = MockClient();
      mockDatabases = MockDatabases();
      mockDocument = MockDocument();
      mockResponse = MockResponse();

      // Mock AppwriteService to return the mocked Client
      when(mockAppwriteService.client).thenReturn(mockClient);

      // Set up locator with mocks
      locator.allowReassignment = true;
      locator.registerSingleton<BaseAuth>(mockAuth);
      locator.registerSingleton<AppwriteService>(mockAppwriteService);

      // Mock the Databases constructor to return the mocked Databases instance
      locator.registerSingleton<Databases>(mockDatabases);

      // Mock the Document's data to return a Map<String, dynamic>
      when(mockDocument.data).thenReturn({
        'name': 'Test Name',
        'email': 'test@example.com',
      });

      // Mock the updateDocument method to return a Future<Document>
      when(mockDatabases.updateDocument(
        databaseId: anyNamed('databaseId'),
        collectionId: anyNamed('collectionId'),
        documentId: anyNamed('documentId'),
        data: anyNamed('data'),
        permissions: anyNamed('permissions'),
      )).thenAnswer((_) async => mockDocument);

      // Mock the Client's call method
      when(mockClient.call(
        any,
        path: anyNamed('path'),
        headers: anyNamed('headers'),
        params: anyNamed('params'),
        responseType: anyNamed('responseType'),
      )).thenAnswer((_) async => mockResponse);

      // Mock the Response's data to return the mock Document (this might be redundant now, but keep for safety)
      when(mockResponse.data).thenReturn(mockDocument);

      testDoctor = Doctor(documentId: 'test_doc_id', email: 'test@example.com');

      _router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                InitialProfileUpdate(doctor: testDoctor),
          ),
          GoRoute(
            path: AppRoutes.initProfileUpdate2,
            builder: (context, state) => Scaffold(
                appBar: AppBar(title: Text('Next Page'))), // Dummy page
          ),
        ],
        initialLocation: '/',
      );
    });

    tearDown(() {
      locator.reset();
    });

    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: InitialProfileUpdate(doctor: testDoctor),
      ));

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Hero), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(MaterialButton), findsOneWidget);
    });

    testWidgets('shows error when name is empty on save',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: InitialProfileUpdate(doctor: testDoctor),
      ));

      // Tap the save button without entering a name
      await tester.tap(find.text('Save'));
      await tester.pump();

      // Expect a SnackBar to be shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please fill your name!'), findsOneWidget);
    });

    // testWidgets('calls updateDocument and navigates on save with valid name',
    //     (WidgetTester tester) async {
    //   await tester.pumpWidget(MaterialApp.router(
    //     routerDelegate: _router.routerDelegate,
    //     routeInformationParser: _router.routeInformationParser,
    //     routeInformationProvider: _router.routeInformationProvider,
    //   ));
    //
    //   // Enter a name
    //   // Type name
    //   await tester.enterText(find.byType(TextFormField), 'Test Name');
    //   await tester.pump(); // Let the text field rebuild
    //
    //   // Tap save button
    //   await tester.tap(find.text('Save'));
    //   await tester.pumpAndSettle(); // Let all async and UI settle
    //
    //   // Then verify
    //   verify(mockDatabases.updateDocument(
    //     databaseId: AppConstants.appwriteDatabaseId,
    //     collectionId: AppConstants.userCollectionId,
    //     documentId: testDoctor.documentId!,
    //     data: {
    //       "name": "Test Name",
    //       "email": testDoctor.email!,
    //     },
    //     permissions: anyNamed('permissions'),
    //   )).called(1);
    //
    //   // Verify navigation occurred by checking if the next page is rendered
    //   expect(find.text('Next Page'), findsOneWidget);
    // });

    testWidgets('shows snackbar on updateDocument error',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: InitialProfileUpdate(doctor: testDoctor),
      ));

      // Enter a name
      await tester.enterText(find.byType(TextFormField), 'Test Name');

      // Make updateDocument throw an error
      when(mockDatabases.updateDocument(
        databaseId: anyNamed('databaseId'),
        collectionId: anyNamed('collectionId'),
        documentId: anyNamed('documentId'),
        data: anyNamed('data'),
        permissions: anyNamed('permissions'),
      )).thenThrow(AppwriteException('Test Error'));

      // Tap the save button
      await tester.tap(find.text('Save'));
      await tester.pump();

      // Expect a SnackBar to be shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Something went wrong while saving.'), findsOneWidget);
    });
  });
}

// A mock observer to track navigation calls
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Mock GoRouterState for navigation testing
class MockGoRouterState extends Mock implements GoRouterState {}

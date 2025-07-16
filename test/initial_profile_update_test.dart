import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:fetosense_remote_flutter/ui/views/initial_profile_update1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:appwrite/models.dart' as models;

class MockAppwriteService extends Mock implements AppwriteService {
  @override
  Client get client => Client();
}

class MockBaseAuth extends Mock implements BaseAuth {}

class MockClient extends Mock implements Client {}

class MockDatabases extends Mock implements Databases {}

void main() {
  final locator = GetIt.instance;

  late MockAppwriteService mockAppwriteService;
  late MockBaseAuth mockBaseAuth;
  late MockClient mockClient;
  late MockDatabases mockDatabases;

  // Dummy doctor object
  final doctor = Doctor();

  setUp(() {
    mockAppwriteService = MockAppwriteService();
    mockBaseAuth = MockBaseAuth();
    mockClient = MockClient();
    mockDatabases = MockDatabases();

    locator.reset();

    // Register mocks
    // when(mockAppwriteService.client).thenReturn(mockClient);
    locator.registerSingleton<AppwriteService>(mockAppwriteService);
    locator.registerSingleton<BaseAuth>(mockBaseAuth);
  });

  Future<void> pumpWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: InitialProfileUpdate(doctor: doctor),
      ),
    );
  }

  testWidgets('Renders input field and Save button',
      (WidgetTester tester) async {
    await pumpWidget(tester);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('Shows snackbar when name is empty', (WidgetTester tester) async {
    await pumpWidget(tester);

    await tester.tap(find.text('Save'));
    await tester.pump(); // allow snackbar to appear

    expect(find.text('Please fill your name!'), findsOneWidget);
  });

  testWidgets('Updates doctor document when name is filled',
      (WidgetTester tester) async {
    // Inject fake database in the widget via Databases(client)
    when(mockDatabases.updateDocument(
      databaseId: ('databaseId'),
      collectionId: ('collectionId'),
      documentId: ('documentId'),
      data: anyNamed('data'),
    )).thenAnswer((_) async => models.Document(
          $id: 'docId',
          data: {'name': 'Dr. Updated'},
          $collectionId: AppConstants.userCollectionId,
          $databaseId: AppConstants.appwriteDatabaseId,
          $createdAt: '',
          $updatedAt: '',
          $permissions: [],
        ));

    // override `Databases` inside the widget by patching `locator<AppwriteService>().client`
    when(mockAppwriteService.client).thenReturn(mockClient);

    // Instead of injecting `mockDatabases`, override `Databases()` logic in real use
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return InitialProfileUpdate(doctor: doctor);
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Dr. Updated');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    verify(mockDatabases.updateDocument(
      databaseId: ('databaseId'),
      collectionId: ('collectionId'),
      documentId: 'doctor123',
      data: {
        'name': 'Dr. Updated',
        'email': 'doctor@test.com',
      },
    )).called(1);
  });

  testWidgets('Shows snackbar on updateDocument failure',
      (WidgetTester tester) async {
    when(mockDatabases.updateDocument(
      databaseId: ('databaseId'),
      collectionId: ('collectionId'),
      documentId: ('documentId'),
      data: anyNamed('data'),
    )).thenThrow(Exception('Database error'));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return InitialProfileUpdate(doctor: doctor);
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Dr. Error');
    await tester.tap(find.text('Save'));
    await tester.pump(); // for snackbar to appear

    expect(find.text('Something went wrong while saving.'), findsOneWidget);
  });
}

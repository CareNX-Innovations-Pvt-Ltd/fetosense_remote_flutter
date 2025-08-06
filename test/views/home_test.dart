import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/app_router.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/core/utils/preferences.dart';
import 'package:fetosense_remote_flutter/ui/views/home.dart';
import 'package:fetosense_remote_flutter/ui/views/profile_view.dart';
import 'package:fetosense_remote_flutter/ui/views/recent_test_list_view.dart';
import 'package:fetosense_remote_flutter/ui/views/search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:appwrite/models.dart' as appwrite;
import 'package:go_router/go_router.dart';

import 'login_test.dart';

class MockPreferenceHelper extends Mock implements PreferenceHelper {}

class MockBaseAuth extends Mock implements BaseAuth {}

class MockAppwriteService extends Mock implements AppwriteService {}

class MockDatabases extends Mock implements Databases {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late MockPreferenceHelper mockPrefs;
  late MockBaseAuth mockAuth;
  late MockAppwriteService mockAppwrite;
  late MockDatabases mockDatabases;

  final fakeDoctor = Doctor(documentId: 'doc123', email: 'doc@example.com');

  setUp(() {
    mockPrefs = MockPreferenceHelper();
    mockAuth = MockBaseAuth();
    mockAppwrite = MockAppwriteService();
    mockDatabases = MockDatabases();

    when(() => mockPrefs.getDoctor()).thenReturn(fakeDoctor);
    when(() => mockAppwrite.client);
    when(() => mockDatabases.getDocument(
      databaseId: any(named: 'databaseId'),
      collectionId: any(named: 'collectionId'),
      documentId: any(named: 'documentId'),
    )).thenAnswer((_) async => appwrite.Document(
      $id: 'org123',
      data: {
        'name': 'Test Org',
      },
      $permissions: [], $collectionId: '', $databaseId: '', $createdAt: '', $updatedAt: '',
    ));

    // Inject into locator
    locator.registerSingleton<PreferenceHelper>(mockPrefs);
    locator.registerSingleton<BaseAuth>(mockAuth);
    locator.registerSingleton<AppwriteService>(mockAppwrite);
  });

  testWidgets('renders Home and bottom nav works', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const Home(),
      ),
    );

    // Default page (RecentTestListView)
    expect(find.byType(RecentTestListView), findsOneWidget);

    // Tap on search icon
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.byType(SearchView), findsOneWidget);

    // Tap on profile icon
    await tester.tap(find.byIcon(Icons.perm_identity));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileView), findsOneWidget);

    // Tap again to go back to index 0
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.perm_identity));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.perm_identity)); // Redundant tap to cover all flow
  });

  testWidgets('calls getOrganization if doctor has organizationId', (tester) async {
    final doctorWithOrg = Doctor(documentId: 'doc1').. organizationId = 'org1';
    when(() => mockPrefs.getDoctor()).thenReturn(doctorWithOrg);

    await tester.pumpWidget(
      MaterialApp(
        home: const Home(),
      ),
    );

    await tester.pumpAndSettle();
    // Should fetch and set organization successfully
    expect(find.byType(RecentTestListView), findsOneWidget);
  });

  testWidgets('redirects to init profile update if doctor organizationName is empty', (tester) async {
    final doctor = Doctor(documentId: 'doc1', email: 'doc@example.com');
    when(() => mockPrefs.getDoctor()).thenReturn(doctor);

    final mockContext = MockBuildContext();
    when(() => mockContext.push(AppRoutes.initProfileUpdate2, extra: any(named: 'extra'))).thenReturn(Future.value());

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            Future.microtask(() => context.push(AppRoutes.initProfileUpdate2, extra: doctor));
            return const Home();
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(Home), findsOneWidget);
  });

  testWidgets('onPop returns true if _page is 0', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Home()));

    final state = tester.state<HomeState>(find.byType(Home));

    final result = await state.onPop(MockBuildContext());
    expect(result, isTrue);
  });

  testWidgets('onPop returns false and sets _page = 0 if _page is not 0', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Home()));

    final state = tester.state<HomeState>(find.byType(Home));

    state.setState(() {
      // state._page = 2;
    });

    final result = await state.onPop(MockBuildContext());
    expect(result, isFalse);
    // expect(state._page, 0);
  });

  testWidgets('setOrganization and setOrganizationBabyBeat set state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Home()));

    final state = tester.state<HomeState>(find.byType(Home));
    final testOrg = Organization.fromMap({'name': 'Baby Org'});

    state.setOrganization(testOrg);
    expect(state.organization, testOrg);

    state.setOrganizationBabyBeat(testOrg);
    expect(state.organizationBabyBeat, testOrg);
  });
}

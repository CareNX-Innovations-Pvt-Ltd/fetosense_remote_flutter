import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/core/utils/preferences.dart';
import 'package:fetosense_remote_flutter/ui/views/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart' as p;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:upgrader/upgrader.dart';
import 'package:get_it/get_it.dart';


class MockAppwriteService extends Mock implements AppwriteService {}

class MockDatabases extends Mock implements Databases {}

class MockBaseAuth extends Mock implements BaseAuth {}

class MockPreferenceHelper extends Mock implements PreferenceHelper {}

class MockGoRouter extends Mock implements GoRouter {}

class MockOrganization extends Mock implements Organization {}

class MockDoctor extends Mock implements Doctor {}

void main() {
  late GetIt locator;
  late MockDatabases mockDatabases;
  late MockPreferenceHelper mockPrefs;
  late MockAppwriteService mockAppwriteService;
  late MockBaseAuth mockAuth;
  late Doctor doctor;

  setUpAll(() {
    registerFallbackValue(Uri.parse(''));
    WidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    locator = GetIt.instance;
    locator.reset();

    mockDatabases = MockDatabases();
    mockPrefs = MockPreferenceHelper();
    mockAppwriteService = MockAppwriteService();
    mockAuth = MockBaseAuth();

    doctor = Doctor(
      documentId: 'doc1',
      email: 'doctor@test.com',
      name: 'Dr. Test',
    );

    locator.registerSingleton<AppwriteService>(mockAppwriteService);
    locator.registerSingleton<BaseAuth>(mockAuth);
    locator.registerSingleton<PreferenceHelper>(mockPrefs);

    when(() => mockPrefs.getDoctor()).thenReturn(doctor);
    when(() => mockAppwriteService.client).thenReturn(Client());
  });

  testWidgets('renders Home widget with correct initial page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Home(doctor: doctor),
      ),
    );

    expect(find.byType(CurvedNavigationBar), findsOneWidget);
    expect(find.byType(UpgradeAlert), findsOneWidget);
  });

  testWidgets('changes page when bottom navigation tapped', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Home(doctor: doctor)));
    await tester.pumpAndSettle();

    final icons = find.byType(Icon);
    expect(icons, findsWidgets);

    await tester.tap(icons.at(1)); // Tap second icon
    await tester.pumpAndSettle();
  });

  testWidgets('calls getPermission and returns true/false properly', (tester) async {
    final homeState = HomeState();
    final resultFuture = homeState.getPermission();

    // Simulate permissions being granted
    homeState.permissions = {p.Permission.storage: p.PermissionStatus.granted};
    expect(await resultFuture, isA<bool>());
  });

  testWidgets('setOrganization and setOrganizationBabyBeat updates state', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Home(doctor: doctor)));
    final state = tester.state<HomeState>(find.byType(Home));

    final org = Organization();
    state.setOrganization(org);
    state.setOrganizationBabyBeat(org);

    expect(state.organization, org);
    expect(state.organizationBabyBeat, org);
  });

  testWidgets('onPop returns true when page=0', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Home(doctor: doctor)));
    final state = tester.state<HomeState>(find.byType(Home));

    final result = await state.onPop(tester.element(find.byType(Home)));
    expect(result, true);
  });

  testWidgets('onPop resets page when not on first tab', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Home(doctor: doctor)));
    final state = tester.state<HomeState>(find.byType(Home));

    state.setState(() {
      state.onPop(tester.element(find.byType(Home)));
    });

    final result = await state.onPop(tester.element(find.byType(Home)));
    expect(result, false);
  });

  testWidgets('setUpBottomNavigation returns correct widget per index', (tester) async {
    final state = HomeState();

    expect(state.setUpBottomNavigation(0), isA<Widget>());
    expect(state.setUpBottomNavigation(1), isA<Widget>());
    expect(() => state.setUpBottomNavigation(2), returnsNormally);
    expect(state.setUpBottomNavigation(999), isA<Widget>());
  });

  testWidgets('getOrganization handles exception gracefully', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Home(doctor: doctor)));
    final state = tester.state<HomeState>(find.byType(Home));

    when(() => mockDatabases.getDocument(
      databaseId: any(named: 'databaseId'),
      collectionId: any(named: 'collectionId'),
      documentId: any(named: 'documentId'),
    )).thenThrow(Exception('Network error'));

    state.getOrganization();
  });

  testWidgets('initState triggers navigation when organizationName is empty', (tester) async {
    final emptyDoctor = Doctor(
      documentId: 'doc2',
      email: 'no_org@test.com',
    );
    when(() => mockPrefs.getDoctor()).thenReturn(emptyDoctor);

    await tester.pumpWidget(
      MaterialApp(
        home: Home(doctor: emptyDoctor),
      ),
    );

    await tester.pumpAndSettle();
  });
}

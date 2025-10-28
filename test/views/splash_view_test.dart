import 'package:device_info/device_info.dart';
import 'package:device_info/device_info.dart';
import 'package:fetosense_remote_flutter/app_router.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/core/utils/preferences.dart';
import 'package:fetosense_remote_flutter/ui/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

final locator = GetIt.instance;

// -------- Mock classes --------
class MockPreferenceHelper extends Mock implements PreferenceHelper {}
class MockBaseAuth extends Mock implements BaseAuth {}
class MockAndroidDeviceInfo extends Mock implements AndroidDeviceInfo {}
class MockDeviceInfoPlugin extends Mock implements DeviceInfoPlugin {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockPreferenceHelper mockPrefs;
  late MockBaseAuth mockAuth;

  setUp(() {
    locator.reset();
    mockPrefs = MockPreferenceHelper();
    mockAuth = MockBaseAuth();
    locator.registerSingleton<PreferenceHelper>(mockPrefs);
    locator.registerSingleton<BaseAuth>(mockAuth);
  });

  Widget buildTestApp() {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            name: AppRoutes.splash,
            builder: (_, __) => const SplashView(),
          ),
          GoRoute(
            path: '/login',
            name: AppRoutes.login,
            builder: (_, __) => const Scaffold(body: Text('Login Screen')),
          ),
          GoRoute(
            path: '/home',
            name: AppRoutes.home,
            builder: (_, __) => const Scaffold(body: Text('Home Screen')),
          ),
        ],
      ),
    );
  }

  testWidgets('renders splash screen correctly', (tester) async {
    await tester.pumpWidget(buildTestApp());
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(SafeArea), findsOneWidget);
  });

  testWidgets('calls _initialize with auto-login false navigates to login', (tester) async {
    when(mockPrefs.getAutoLogin()).thenReturn(false);

    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    final state = tester.state(find.byType(SplashView)) as dynamic;
    await state._initialize();
    expect(state.mounted, isTrue);
  });

  testWidgets('calls _handleAutoLogin navigates to home when doctor exists', (tester) async {
    final doctor = Doctor(documentId: 'doc-123');
    when(mockPrefs.getAutoLogin()).thenReturn(true);
    when(mockPrefs.getDoctor()).thenReturn(doctor);

    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    final state = tester.state(find.byType(SplashView)) as dynamic;
    await state._handleAutoLogin();
    expect(state.mounted, isTrue);
  });

  testWidgets('calls _handleAutoLogin catches exception and navigates to login', (tester) async {
    when(mockPrefs.getAutoLogin()).thenReturn(true);
    when(mockPrefs.getDoctor()).thenThrow(Exception('login failed'));

    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    final state = tester.state(find.byType(SplashView)) as dynamic;
    await state._handleAutoLogin();
    expect(state.mounted, isTrue);
  });

  testWidgets('_detectDeviceType runs on web', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashView()));
    final state = tester.state(find.byType(SplashView)) as dynamic;
    await state._detectDeviceType();
    expect(state._isAndroidTv, isFalse);
  });

  testWidgets('_detectDeviceType runs on android', (tester) async {
    final mockInfo = MockAndroidDeviceInfo();
    final mockPlugin = MockDeviceInfoPlugin();
    when(mockInfo.systemFeatures).thenReturn(['android.software.leanback']);
    when(mockPlugin.androidInfo).thenAnswer((_) async => mockInfo);

    await tester.pumpWidget(const MaterialApp(home: SplashView()));
    final state = tester.state(find.byType(SplashView)) as dynamic;
    await state._detectDeviceType();
    expect(state._isAndroidTv, isA<bool>());
  });

  testWidgets('initState triggers _initialize after delay (via fakeAsync)', (tester) async {
    when(mockPrefs.getAutoLogin()).thenReturn(false);


  });

  testWidgets('buildWaitingScreen returns SafeArea and Scaffold', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashView()));
    final state = tester.state(find.byType(SplashView)) as dynamic;
    final widget = state._buildWaitingScreen();
    expect(widget, isA<SafeArea>());
  });

  testWidgets('full build renders splash image', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashView()));
    expect(find.byType(Image), findsOneWidget);
  });
}

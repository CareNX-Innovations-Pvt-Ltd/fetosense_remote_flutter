import 'package:fetosense_remote_flutter/app_router.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/ui/views/home.dart';
import 'package:fetosense_remote_flutter/ui/views/initial_profile_update1.dart';
import 'package:fetosense_remote_flutter/ui/views/initial_profile_update2.dart';
import 'package:fetosense_remote_flutter/ui/views/login_view.dart';
import 'package:fetosense_remote_flutter/ui/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';


class FakeGoRouterState extends Fake implements GoRouterState {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGoRouterState());
  });

  test('AppRoutes values are correct', () {
    expect(AppRoutes.splash, '/');
    expect(AppRoutes.login, '/login');
    expect(AppRoutes.home, '/home');
    expect(AppRoutes.initProfileUpdate, '/initProfileUpdate');
    expect(AppRoutes.initProfileUpdate2, '/initProfileUpdate2');
  });

  testWidgets('Navigates to SplashView', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: AppRouter.router,
    ));

    expect(find.byType(SplashView), findsOneWidget);
  });

  testWidgets('Navigates to LoginView', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: AppRouter.router,
    ));

    AppRouter.router.go(AppRoutes.login);
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('Navigates to Home with doctor', (WidgetTester tester) async {
    final doctor = Doctor(name: 'Dr. Test'); // minimal valid instance

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: AppRouter.router,
    ));

    AppRouter.router.go(AppRoutes.home, extra: doctor);
    await tester.pumpAndSettle();

    expect(find.byType(Home), findsOneWidget);
  });

  testWidgets('Navigates to InitialProfileUpdate with doctor', (tester) async {
    final doctor = Doctor(name: 'Dr. Test');

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: AppRouter.router,
    ));

    AppRouter.router.go(AppRoutes.initProfileUpdate, extra: doctor);
    await tester.pumpAndSettle();

    expect(find.byType(InitialProfileUpdate), findsOneWidget);
  });

  testWidgets('Navigates to InitialProfileUpdate2 with doctor', (tester) async {
    final doctor = Doctor( name: 'Dr. Jane');

    await tester.pumpWidget(MaterialApp.router(
      routerConfig: AppRouter.router,
    ));

    AppRouter.router.go(AppRoutes.initProfileUpdate2, extra: doctor);
    await tester.pumpAndSettle();

    expect(find.byType(InitialProfileUpdate2), findsOneWidget);
  });

  testWidgets('Shows error page for unknown route', (tester) async {
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: AppRouter.router,
    ));

    AppRouter.router.go('/unknown');
    await tester.pumpAndSettle();

    expect(find.text('Page not found'), findsOneWidget);
  });
}

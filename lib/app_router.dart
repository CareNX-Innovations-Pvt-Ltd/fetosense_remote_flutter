import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/ui/views/home.dart';
import 'package:fetosense_remote_flutter/ui/views/initial_profile_update1.dart';
import 'package:fetosense_remote_flutter/ui/views/initial_profile_update2.dart';
import 'package:fetosense_remote_flutter/ui/views/login_view.dart';
import 'package:fetosense_remote_flutter/ui/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const initProfileUpdate = '/initProfileUpdate';
  static const initProfileUpdate2 = '/initProfileUpdate2';
}

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        name: AppRoutes.splash,
        path: AppRoutes.splash,
        builder: (context, state) => SplashView(),
      ),
      GoRoute(
        name: AppRoutes.login,
        path: AppRoutes.login,
        builder: (context, state) => LoginView(),
      ),
      GoRoute(
          name: AppRoutes.home,
          path: AppRoutes.home,
          builder: (context, state) {
            var doctor = state.extra as Doctor?;
            return Home(doctor: doctor);
          }),
      GoRoute(
          name: AppRoutes.initProfileUpdate,
          path: AppRoutes.initProfileUpdate,
          builder: (context, state) {
            var doctor = state.extra as Doctor;
            return InitialProfileUpdate(
              doctor: doctor,
            );
          }),
      GoRoute(
          name: AppRoutes.initProfileUpdate2,
          path: AppRoutes.initProfileUpdate2,
          builder: (context, state) {
            var doctor = state.extra as Doctor;
            return InitialProfileUpdate2(
              doctor: doctor,
            );
          }),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(child: Text('Page not found')),
    ),
  );
}

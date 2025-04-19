import 'package:fetosense_remote_flutter/ui/views/splash_view.dart';
import 'package:flutter/material.dart';

/// A class that handles the routing for the application.
class Router {
  /// Generates the route based on the given [RouteSettings].
  /// [settings] contains the name and arguments of the route.
  /// Returns a [Route] object for the specified route.
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => SplashView(
          )
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

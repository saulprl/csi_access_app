import "package:flutter/material.dart";

import "package:csi_door_logs/screens/screens.dart";

class Routes {
  static const String splash = "/splash";
  static const String login = "/login";
  static const String signup = "/signup";
  static const String dashboard = "/dashboard";
  static const String accessLogs = "/access-logs";
  static const String csiCredentials = "/csi-credentials";

  static final routes = <Route>[
    Route(route: splash, screen: const SplashScreen()),
    Route(route: login, screen: const LoginScreen()),
    Route(route: signup, screen: const SignupScreen()),
    Route(route: dashboard, screen: const DashboardScreen()),
    Route(route: accessLogs, screen: const LogsScreen()),
    Route(route: csiCredentials, screen: const CSICredentialsScreen()),
  ];

  static Map<String, Widget Function(BuildContext)> getAppRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};
    for (final route in routes) {
      appRoutes.addAll({route.route: (BuildContext context) => route.screen});
    }

    return appRoutes;
  }
}

class Route {
  final String route;
  final Widget screen;

  Route({required this.route, required this.screen});
}

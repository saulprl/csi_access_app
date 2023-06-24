import "package:flutter/material.dart";

import "package:csi_door_logs/screens/screens.dart";

class Routes {
  static const String splash = "/splash";
  static const String login = "/login";
  static const String signup = "/signup";
  static const String dashboard = "/dashboard";
  static const String accessLogs = "/access-logs";
  static const String csiCredentials = "/csi-credentials";

  static final routes = <StaticRoute>[
    StaticRoute(route: splash, screen: const SplashScreen()),
    StaticRoute(route: login, screen: const LoginScreen()),
    StaticRoute(route: signup, screen: const SignupScreen()),
    StaticRoute(route: dashboard, screen: const DashboardScreen()),
    StaticRoute(route: accessLogs, screen: const LogsScreen()),
    StaticRoute(route: csiCredentials, screen: const CSICredentialsScreen()),
  ];

  static Map<String, Widget Function(BuildContext)> getAppRoutes() {
    Map<String, Widget Function(BuildContext)> appRoutes = {};
    for (final route in routes) {
      appRoutes.addAll({route.route: (BuildContext context) => route.screen});
    }

    return appRoutes;
  }

  static Route pushFromRight(Widget route) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => route,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}

class StaticRoute {
  final String route;
  final Widget screen;

  StaticRoute({required this.route, required this.screen});
}

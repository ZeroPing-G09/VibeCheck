import 'package:flutter/material.dart';
import '../../ui/auth/view/login_view.dart';
import '../../ui/home/view/home_view.dart';
import '../../ui/profile/view/profile_view.dart';
import '../../ui/settings/view/settings_view.dart';
import '../../ui/dashboard/view/dashboard_view.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';

  static const String initialRoute = dashboardRoute;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case dashboardRoute:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfileView());
      case settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsView());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}

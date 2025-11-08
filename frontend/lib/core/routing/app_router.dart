import 'package:flutter/material.dart';
import '../../ui/auth/view/login_view.dart';
import '../../ui/dashboard/view/dashboard_view.dart';
import '../../ui/profile/view/profile_view.dart';
import '../../ui/settings/view/settings_view.dart';

class AppRouter {
  static const String initialRoute = '/login';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginView());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardView());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileView());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsView());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}

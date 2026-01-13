import 'package:flutter/material.dart';
import 'package:frontend/core/routing/oauth_handler.dart';
import 'package:frontend/ui/auth/view/login_view.dart';
import 'package:frontend/ui/home/view/home_view.dart';
import 'package:frontend/ui/onboarding/view/onboarding_view.dart';
import 'package:frontend/ui/profile/view/profile_view.dart';
import 'package:frontend/ui/settings/view/settings_view.dart';

/// Centralized router for handling all navigation in the application
class AppRouter {
  /// Private constructor to prevent instantiation
  AppRouter._();

  /// Global navigator key used for navigation without BuildContext
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Route name for the login screen
  static const String loginRoute = '/login';

  /// Route name for the dashboard (home) screen
  static const String dashboardRoute = '/dashboard';

  /// Route name for the profile screen
  static const String profileRoute = '/profile';

  /// Route name for the settings screen
  static const String settingsRoute = '/settings';

  /// Route name for the onboarding flow
  static const String onboardingRoute = '/onboarding';

  /// Initial route used when the app starts
  static const String initialRoute = dashboardRoute;

  /// Generates a Route based on the provided RouteSettings
  ///
  /// Handles:
  /// - Null or invalid routes
  /// - OAuth callback routes
  /// - All known app routes
  /// - Fallback for unknown routes
  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('Generating route for: ${settings.name}');

    /// If route name is null, default to login
    if (settings.name == null) {
      debugPrint('Route name is null, defaulting to login');
      return MaterialPageRoute(builder: (_) => const LoginView());
    }

    /// Handle OAuth callback routes
    if (settings.name!.startsWith('/?') || settings.name!.contains('code=')) {
      return MaterialPageRoute(
        builder: (_) => OAuthCallbackHandler(callbackRoute: settings.name!),
      );
    }

    switch (settings.name) {
      /// Root route: show loading indicator
      case '/':
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
        );

      /// Login route
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginView());

      /// Dashboard route
      case dashboardRoute:
        return MaterialPageRoute(builder: (_) => const HomeView());

      /// Profile route
      case profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfileView());

      /// Settings route
      case settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsView());

      /// Onboarding route
      case onboardingRoute:
        return MaterialPageRoute(builder: (_) => const OnboardingView());

      /// Fallback for unknown routes
      default:
        debugPrint('Unknown route: ${settings.name}');
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Route not found: ${settings.name}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      navigatorKey.currentState?.pushNamedAndRemoveUntil(
                        loginRoute,
                        (route) => false,
                      );
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  /// Navigates to [route] and clears the entire navigation stack
  static Future<void> goToRouteAndClearStack(String route) async {
    await navigatorKey.currentState?.pushNamedAndRemoveUntil(
      route,
      (r) => false,
    );
  }

  /// Navigates to the login screen and clears the navigation stack
  static Future<void> goToLogin() async {
    await goToRouteAndClearStack(loginRoute);
  }

  /// Navigates to the dashboard screen and clears the navigation stack
  static Future<void> goToDashboard() async {
    await goToRouteAndClearStack(dashboardRoute);
  }
}

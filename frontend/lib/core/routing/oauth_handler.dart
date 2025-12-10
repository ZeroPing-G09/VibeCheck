import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/routing/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OAuthCallbackHandler extends StatefulWidget {
  final String callbackRoute; // e.g. "/?code=..." or "/?access_token=..."

  const OAuthCallbackHandler({super.key, required this.callbackRoute});

  @override
  State<OAuthCallbackHandler> createState() => _OAuthCallbackHandlerState();
}

class _OAuthCallbackHandlerState extends State<OAuthCallbackHandler> {
  StreamSubscription<AuthState>? _sub;
  bool _handled = false;
  Timer? _timeout;

  @override
  void initState() {
    super.initState();

    // Listen to auth changes – when session becomes non-null, navigate
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final session =
          event.session ?? Supabase.instance.client.auth.currentSession;
      if (!_handled && session != null) {
        _handled = true;
        _navigateToPostAuth();
      }
    });

    // As a fallback, navigate to login after a short timeout
    _timeout = Timer(const Duration(seconds: 10), () {
      if (!_handled) {
        _handled = true;
        _goToLogin();
      }
    });
  }

  void _navigateToPostAuth() {
    // Navigate to dashboard using the new helper
    AppRouter.goToDashboard();
  }

  void _goToLogin() {
    // Navigate to login using the new helper
    AppRouter.goToLogin();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Completing authentication...'),
          ],
        ),
      ),
    );
  }
}

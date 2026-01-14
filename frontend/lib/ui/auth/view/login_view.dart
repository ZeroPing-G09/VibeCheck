import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/error_state.dart';
import 'package:frontend/core/widgets/loading_state.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/ui/auth/viewmodel/auth_view_model.dart';
import 'package:provider/provider.dart';

/// Login screen for the application
/// Displays a Spotify login button and handles loading or error states
class LoginView extends StatelessWidget {
  /// Creates a [LoginView] widget
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthViewModel>(
        builder: (context, viewModel, child) {
          // Show loading state while signing in
          if (viewModel.isLoading) {
            return const LoadingState(message: 'Signing in...');
          }

          // Show error state if login failed
          if (viewModel.error != null) {
            return ErrorState(
              message: viewModel.error!,
              onRetry: () => viewModel.signInWithSpotify(),
            );
          }

          // Show main login UI
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Button to initiate Spotify login
                PrimaryButton(
                  label: 'Login with Spotify',
                  icon: Icons.music_note,
                  onPressed: () => viewModel.signInWithSpotify(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

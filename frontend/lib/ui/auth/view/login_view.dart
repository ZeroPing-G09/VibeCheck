import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/error_state.dart';
import 'package:frontend/core/widgets/loading_state.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/ui/auth/viewmodel/auth_view_model.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingState(message: 'Signing in...');
          }

          if (viewModel.error != null) {
            return ErrorState(
              message: viewModel.error!,
              onRetry: () => viewModel.signInWithSpotify(),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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

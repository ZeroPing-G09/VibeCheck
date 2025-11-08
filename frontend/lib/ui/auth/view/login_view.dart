import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_view_model.dart';
import '../../../core/widgets/loading_indicator.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/home');
          });
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Login'),
          ),
          body: Center(
            child: viewModel.isLoading
                ? const LoadingIndicator()
                : ElevatedButton(
                    onPressed: () {
                      viewModel.login('test@example.com', '1234'); // Todo: implement login
                    },
                    child: const Text('Login'),
                  ),
          ),
        );
      },
    );
  }
}

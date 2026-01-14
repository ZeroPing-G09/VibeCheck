import 'package:flutter/material.dart';

/// A simple login button widget
/// Executes [onPressed] callback when tapped
class LoginButton extends StatelessWidget {

  /// Creates a [LoginButton] with the required [onPressed] callback
  const LoginButton({required this.onPressed, super.key});
  /// Callback triggered when the button is pressed
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Login'),
    );
  }
}

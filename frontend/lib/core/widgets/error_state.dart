import 'package:flutter/material.dart';

/// A reusable error state widget with retry functionality
class ErrorState extends StatelessWidget {

  /// Creates an error state widget
  const ErrorState({
    required this.message, super.key,
    this.title,
    this.onRetry,
    this.icon,
  });
  /// Main error message shown to the user
  final String message;

  /// Optional title displayed above the message
  final String? title;

  /// Optional retry callback
  final VoidCallback? onRetry;

  /// Optional icon displayed above the text
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.red[300],
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

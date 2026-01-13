import 'package:flutter/material.dart';

/// A reusable empty state widget
class EmptyState extends StatelessWidget {

  /// Creates an empty state widget
  const EmptyState({
    required this.message, super.key,
    this.title,
    this.icon,
  });
  /// Main message shown to the user
  final String message;

  /// Optional title displayed above the message
  final String? title;

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
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

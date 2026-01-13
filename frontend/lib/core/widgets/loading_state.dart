import 'package:flutter/material.dart';

/// A reusable loading state widget
class LoadingState extends StatelessWidget {

  /// Creates a loading state widget
  const LoadingState({
    super.key,
    this.message,
    this.size,
  });
  /// Optional message displayed below the loading indicator
  final String? message;

  /// Optional size for the loading indicator
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: const CircularProgressIndicator(),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

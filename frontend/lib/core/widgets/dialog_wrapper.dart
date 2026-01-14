import 'package:flutter/material.dart';

/// A reusable dialog wrapper with consistent styling
class DialogWrapper extends StatelessWidget {

  /// Creates a styled dialog wrapper
  const DialogWrapper({
    required this.title, required this.child, super.key,
    this.subtitle,
    this.actions,
    this.maxWidth,
  });
  /// Main title displayed at the top of the dialog
  final String title;

  /// Optional subtitle shown below the title
  final String? subtitle;

  /// Main content of the dialog
  final Widget child;

  /// Optional action buttons displayed at the bottom
  final List<Widget>? actions;

  /// Maximum width constraint for the dialog
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Flexible(child: child),
            if (actions != null) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

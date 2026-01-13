import 'package:flutter/material.dart';

/// A reusable secondary action button
class SecondaryButton extends StatelessWidget {

  /// Creates a secondary action button
  const SecondaryButton({
    required this.label, super.key,
    this.onPressed,
    this.icon,
  });
  /// Text displayed on the button
  final String label;

  /// Callback triggered when the button is pressed
  final VoidCallback? onPressed;

  /// Optional icon displayed alongside the label
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(label),
              ],
            )
          : Text(label),
    );
  }
}

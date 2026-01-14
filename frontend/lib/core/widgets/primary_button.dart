import 'package:flutter/material.dart';

/// A reusable primary action button with optional loading state
class PrimaryButton extends StatelessWidget {

  /// Creates a primary action button
  const PrimaryButton({
    required this.label, super.key,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.padding,
  });
  /// Text displayed on the button
  final String label;

  /// Callback triggered when the button is pressed
  final VoidCallback? onPressed;

  /// Whether the button shows a loading indicator
  final bool isLoading;

  /// Optional icon displayed alongside the label
  final IconData? icon;

  /// Optional padding for the button content
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : icon != null
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

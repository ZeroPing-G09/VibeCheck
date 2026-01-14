import 'package:flutter/material.dart';

/// A custom text field widget that displays a label and its 
/// corresponding value.
class CustomTextField extends StatelessWidget {

  /// Creates a [CustomTextField] widget.
  const CustomTextField({required this.label, required this.value, super.key});
  /// The label for the text field.
  final String label;
  /// The value to be displayed in the text field.
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: theme.colorScheme.onSurface)),
      ],
    );
  }
}

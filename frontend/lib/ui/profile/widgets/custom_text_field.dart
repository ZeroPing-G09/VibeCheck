import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String value;

  const CustomTextField({super.key, required this.label, required this.value});

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

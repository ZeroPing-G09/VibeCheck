import 'package:flutter/material.dart';

/// A button widget that allows users to save changes to their profile.
class SaveButton extends StatelessWidget {

  /// Creates a [SaveButton] widget.
  const SaveButton({
    required this.onSave, required this.enabled, super.key,
  });
  
  /// Callback function to be executed when the button is pressed.
  final VoidCallback onSave;
  /// Indicates whether the button is enabled or disabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: enabled ? onSave : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled
            ? const Color(0xFF2D3748)
            : Colors.grey.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Save Changes',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );

    // Tooltip only when disabled
    if (enabled) {
      return button;
    }

    return Tooltip(
      message: 'Server is offline. Changes cannot be saved.',
      child: button,
    );
  }
}

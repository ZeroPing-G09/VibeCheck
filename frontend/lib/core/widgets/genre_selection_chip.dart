import 'package:flutter/material.dart';

/// A reusable genre selection chip widget
class GenreSelectionChip extends StatelessWidget {

  /// Creates a genre selection chip
  const GenreSelectionChip({
    required this.genre, super.key,
    this.isSelected = false,
    this.isDisabled = false,
    this.onTap,
    this.onDelete,
  });
  /// Genre name displayed on the chip
  final String genre;

  /// Whether the chip is currently selected
  final bool isSelected;

  /// Whether the chip is disabled and non-interactive
  final bool isDisabled;

  /// Callback when the chip is tapped (for selectable chips)
  final VoidCallback? onTap;

  /// Callback when the chip's delete icon is tapped (for deletable chips)
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    if (onDelete != null) {
      // Deletable chip for selected items
      return Chip(
        label: Text(genre),
        onDeleted: onDelete,
        deleteIcon: const Icon(Icons.close, size: 18),
      );
    }

    // Selectable chip
    return FilterChip(
      label: Text(genre),
      selected: isSelected,
      onSelected: isDisabled ? null : (_) => onTap?.call(),
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      disabledColor: Colors.grey[300],
    );
  }
}

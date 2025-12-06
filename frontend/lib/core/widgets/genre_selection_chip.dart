import 'package:flutter/material.dart';

/// A reusable genre selection chip widget
class GenreSelectionChip extends StatelessWidget {
  final String genre;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const GenreSelectionChip({
    super.key,
    required this.genre,
    this.isSelected = false,
    this.isDisabled = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (onDelete != null) {
      // Deletable chip (for selected items)
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


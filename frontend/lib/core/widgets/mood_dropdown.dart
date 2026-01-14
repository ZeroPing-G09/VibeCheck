import 'package:flutter/material.dart';
import 'package:frontend/data/models/mood.dart';

/// A searchable dropdown widget for selecting moods
class MoodDropdown extends StatefulWidget {

  /// Creates a mood dropdown widget
  const MoodDropdown({
    required this.moods, 
    required this.selectedMoods, 
    required this.onMoodSelected, 
    required this.onMoodRemoved, 
    super.key,
  });
  /// List of available moods
  final List<Mood> moods;

  /// List of currently selected moods
  final List<Mood> selectedMoods;

  /// Callback when a mood is selected
  final void Function(Mood) onMoodSelected;

  /// Callback when a mood is removed
  final void Function(Mood) onMoodRemoved;

  @override
  State<MoodDropdown> createState() => _MoodDropdownState();
}

class _MoodDropdownState extends State<MoodDropdown> {
  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  /// Focus node for the search field
  final FocusNode _searchFocusNode = FocusNode();

  /// Whether the dropdown is expanded
  bool _isExpanded = false;

  /// List of moods filtered by the search query
  List<Mood> _filteredMoods = [];

  @override
  void initState() {
    super.initState();
    _filteredMoods = widget.moods;
    _searchController.addListener(_filterMoods);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Filters moods based on the search query
  void _filterMoods() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMoods = widget.moods;
      } else {
        _filteredMoods = widget.moods
            .where((mood) => mood.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  /// Checks if a mood is currently selected
  bool _isMoodSelected(Mood mood) {
    return widget.selectedMoods.any((m) => m.id == mood.id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search bar and dropdown toggle
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
            if (_isExpanded) {
              _searchFocusNode.requestFocus();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]
                  : Colors.grey[100],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: const InputDecoration(
                      hintText: 'Search moods...',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onTap: () {
                      setState(() {
                        _isExpanded = true;
                      });
                    },
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                ),
              ],
            ),
          ),
        ),
        // Dropdown list
        if (_isExpanded) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]
                  : Colors.white,
            ),
            child: _filteredMoods.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No moods found',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredMoods.length,
                    itemBuilder: (context, index) {
                      final mood = _filteredMoods[index];
                      final isSelected = _isMoodSelected(mood);
                      return InkWell(
                        onTap: () {
                          if (isSelected) {
                            widget.onMoodRemoved(mood);
                          } else {
                            widget.onMoodSelected(mood);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withValues(alpha: 0.3)
                                : null,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey..withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  mood.name,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../data/models/mood.dart';

/// A searchable dropdown widget for selecting moods
class MoodDropdown extends StatefulWidget {
  final List<Mood> moods;
  final List<Mood> selectedMoods;
  final void Function(Mood) onMoodSelected;
  final void Function(Mood) onMoodRemoved;

  const MoodDropdown({
    super.key,
    required this.moods,
    required this.selectedMoods,
    required this.onMoodSelected,
    required this.onMoodRemoved,
  });

  @override
  State<MoodDropdown> createState() => _MoodDropdownState();
}

class _MoodDropdownState extends State<MoodDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isExpanded = false;
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

  void _filterMoods() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMoods = widget.moods;
      } else {
        _filteredMoods = widget.moods
            .where((mood) =>
                mood.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

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
                    decoration: InputDecoration(
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
                    padding: const EdgeInsets.all(16.0),
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
                                    .withOpacity(0.3)
                                : null,
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1,
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


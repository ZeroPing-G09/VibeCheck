import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/ui/profile/viewmodel/profile_view_model.dart';
import 'package:provider/provider.dart';

class GenresSection extends StatefulWidget {
  final User user;
  final bool enabled;

  const GenresSection({
    super.key,
    required this.user,
    required this.enabled,
  });

  @override
  State<GenresSection> createState() => _GenresSectionState();
}

class _GenresSectionState extends State<GenresSection> {
  String? _selectedGenre;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final viewModel = context.watch<ProfileViewModel>();
    final availableGenres = viewModel.availableGenres;
    final isOnline = viewModel.isServerAvailable;

    final selectableGenres = availableGenres
        .where((g) => !user.genres.contains(g))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Favorite Genres',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        /// Existing genres
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: user.genres.map((g) {
            final chip = Chip(
              label: Text(g),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: isOnline
                  ? () => setState(() => user.genres.remove(g))
                  : null,
            );

            if (isOnline) return chip;

            return Tooltip(
              message: 'Server is offline. Genres cannot be modified.',
              child: chip,
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        if (user.genres.length < 3)
          Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: isOnline
                      ? ''
                      : 'Server is offline. Cannot add genres.',
                  child: DropdownButtonFormField<String>(
                    hint: const Text('Select genre'),
                    value: _selectedGenre,
                    onChanged: isOnline
                        ? (value) =>
                            setState(() => _selectedGenre = value)
                        : null,
                    items: selectableGenres
                        .map(
                          (g) => DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Tooltip(
                message: isOnline
                    ? ''
                    : 'Server is offline. Cannot add genres.',
                child: ElevatedButton.icon(
                  onPressed: (isOnline && _selectedGenre != null)
                      ? () {
                          setState(() {
                            user.genres.add(_selectedGenre!);
                            _selectedGenre = null;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ),
            ],
          )
        else
          _maxGenresInfo(),
      ],
    );
  }

  Widget _maxGenresInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber[800]),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'You can only select up to 3 genres',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/ui/profile/viewmodel/profile_view_model.dart';
import 'package:provider/provider.dart';

class GenresSection extends StatefulWidget {
  final User user;
  const GenresSection({super.key, required this.user});

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

    // Filter out genres that are already selected
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: user.genres
              .map(
                (g) => Chip(
                  label: Text(g),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => setState(() => user.genres.remove(g)),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        if (user.genres.length < 3)
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  hint: const Text('Select genre'),
                  value: _selectedGenre,
                  onChanged: (value) => setState(() => _selectedGenre = value),
                  items: selectableGenres
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _selectedGenre != null
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
            ],
          )
        else
          Container(
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
          ),
      ],
    );
  }
}

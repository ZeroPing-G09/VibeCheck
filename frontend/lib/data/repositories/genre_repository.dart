import 'dart:convert';

import 'package:frontend/data/services/genre_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository handling genre retrieval and caching
/// Orchestrates [GenreService] and local storage via SharedPreferences
class GenreRepository {

  /// Creates a [GenreRepository] with optional [GenreService]
  /// If none is provided, a default instance is created
  GenreRepository({GenreService? genreService})
      : _service = genreService ?? GenreService();
      
  final GenreService _service;

  /// Fetches all genres from the service and caches them locally
  Future<List<String>> getAllGenres() async {
    final genres = await _service.fetchAllGenres();
    await _cacheGenres(genres);
    return genres;
  }

  /// Stores the list of genres in SharedPreferences
  Future<void> _cacheGenres(List<String> genres) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_genres', jsonEncode(genres));
  }

  /// Retrieves cached genres from SharedPreferences
  /// Returns empty list if none are cached
  Future<List<String>> getCachedGenres() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('cached_genres');
    if (stored != null) {
      return List<String>.from(jsonDecode(stored) as List<dynamic>);
    }
    return [];
  }
}

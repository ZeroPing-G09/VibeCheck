import 'dart:convert';

import 'package:frontend/data/services/genre_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenreRepository {
  final GenreService _service;

  GenreRepository({GenreService? genreService})
      : _service = genreService ?? GenreService();

  Future<List<String>> getAllGenres() async {
    final genres = await _service.fetchAllGenres();
    await _cacheGenres(genres);
    return genres;
  }

  Future<void> _cacheGenres(List<String> genres) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_genres', jsonEncode(genres));
  }

  Future<List<String>> getCachedGenres() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('cached_genres');
    if (stored != null) {
      return List<String>.from(jsonDecode(stored) as List<dynamic>);
    }
    return [];
  }
}

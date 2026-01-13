import 'dart:convert';

import 'package:frontend/data/services/api_service.dart';
import 'package:http/http.dart' as http;

/// Service handling genre-related API operations
/// Provides methods to fetch genres from the backend
class GenreService {
  /// Fetches all available genres from backend API
  /// Returns a list of genre names as [List<String>]
  /// Throws an exception if the API request fails
  Future<List<String>> fetchAllGenres() async {
    final response = await http.get(
      ApiService.buildBackendUrl('/genres'),
      headers: ApiService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      // ignore: avoid_dynamic_calls
      return data.map((g) => g['name'].toString()).toList();
    } else {
      throw Exception('Failed to load genres: ${response.statusCode}');
    }
  }
}

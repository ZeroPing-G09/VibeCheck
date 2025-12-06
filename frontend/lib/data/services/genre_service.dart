import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class GenreService {
  Future<List<String>> fetchAllGenres() async {
    final response = await http.get(
      ApiService.buildBackendUrl('/genres'),
      headers: ApiService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((g) => g['name'].toString()).toList();
    } else {
      throw Exception('Failed to load genres: ${response.statusCode}');
    }
  }
}

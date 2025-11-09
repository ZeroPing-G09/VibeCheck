import 'dart:convert';
import 'package:http/http.dart' as http;

class GenreService {
  final String baseUrl = 'http://localhost:8080'; // change for emulator if needed

  Future<List<String>> fetchAllGenres() async {
    final response = await http.get(Uri.parse('$baseUrl/genres'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((g) => g['name'].toString()).toList();
    } else {
      throw Exception('Failed to load genres: ${response.statusCode}');
    }
  }
}

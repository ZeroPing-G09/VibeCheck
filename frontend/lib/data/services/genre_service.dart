import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_service.dart';

class GenreService {
  String get baseUrl {
    // On Android emulators, use 10.0.2.2 to reach host localhost.
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {}
    return 'http://localhost:8080';
  }

  Future<List<String>> fetchAllGenres() async {
    final response = await http.get(
      Uri.parse('$baseUrl/genres'),
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

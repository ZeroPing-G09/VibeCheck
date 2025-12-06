import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'api_service.dart';

class OnboardingService {
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {}
    return 'http://localhost:8080';
  }

  Future<List<int>> _convertGenreNamesToIds(List<String> genreNames) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/genres'),
        headers: ApiService.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> genres = jsonDecode(response.body) as List<dynamic>;
        final Map<String, int> nameToIdMap = {
          for (var g in genres)
            g['name'] as String: g['id'] as int
        };
        
        return genreNames.map((name) {
          final id = nameToIdMap[name];
          if (id == null) {
            throw Exception('Genre "$name" not found');
          }
          return id;
        }).toList();
      } else {
        throw Exception('Failed to fetch genres: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error converting genre names to IDs: $e');
      rethrow;
    }
  }

  Future<bool> checkOnboardingNeeded(String email) async {
    final url = Uri.parse('$baseUrl/users/by-email?email=${Uri.encodeQueryComponent(email)}');
    final response = await http.get(
      url,
      headers: ApiService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      final user = User.fromJson(json);
      return user.genres.isEmpty || user.genres.length < 3;
    } else {
      throw Exception('Failed to check onboarding status: ${response.statusCode}');
    }
  }

  Future<void> completeOnboarding(String userId, List<String> genreNames) async {
    if (genreNames.length != 3) {
      throw Exception('Exactly 3 genres are required for onboarding');
    }

    final genreIds = await _convertGenreNamesToIds(genreNames);

    final url = Uri.parse('$baseUrl/users/preferences');
    final body = jsonEncode({
      'top1GenreId': genreIds[0],
      'top2GenreId': genreIds[1],
      'top3GenreId': genreIds[2],
    });

    final response = await http.post(
      url,
      headers: ApiService.getAuthHeaders(),
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to complete onboarding: ${response.statusCode}');
    }
  }
}


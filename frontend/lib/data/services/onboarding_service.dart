import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:http/http.dart' as http;

/// Service handling onboarding-related API operations
/// Provides methods to check onboarding status and complete onboarding
class OnboardingService {
  /// Converts a list of genre names [genreNames] to their corresponding IDs
  /// Fetches all genres from the backend and maps names to IDs
  /// Returns a list of genre IDs as [List<int>]
  /// Throws an exception if any genre name is not found or API call fails
  Future<List<int>> _convertGenreNamesToIds(List<String> genreNames) async {
    try {
      final response = await http.get(
        ApiService.buildBackendUrl('/genres'),
        headers: ApiService.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final genres = jsonDecode(response.body) as List<dynamic>;
        final nameToIdMap = <String, int>{
          for (final g in genres)
            // ignore: avoid_dynamic_calls
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

  /// Checks if onboarding is needed for the user with [email]
  /// Returns true if the user has no genres or less than 3 genres selected
  /// Throws an exception if the API call fails
  Future<bool> checkOnboardingNeeded(String email) async {
    final url = ApiService.buildBackendUrl('/users/by-email?email=${Uri.encodeQueryComponent(email)}');
    final response = await http.get(
      url,
      headers: ApiService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final user = User.fromJson(json);
      return user.genres.isEmpty || user.genres.length < 3;
    } else {
      throw Exception(
        'Failed to check onboarding status: ${response.statusCode}');
    }
  }

  /// Completes onboarding for the user with [userId] using exactly 
  /// 3 [genreNames]
  /// Converts genre names to IDs and posts preferences to backend
  /// Throws an exception if genre list is not exactly 3 or API call fails
  Future<void> completeOnboarding(String userId, List<String> genreNames) 
  async {
    if (genreNames.length != 3) {
      throw Exception('Exactly 3 genres are required for onboarding');
    }

    final genreIds = await _convertGenreNamesToIds(genreNames);

    final url = ApiService.buildBackendUrl('/users/preferences');
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

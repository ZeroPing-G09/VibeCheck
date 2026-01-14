import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frontend/data/models/mood.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:http/http.dart' as http;

/// Service handling mood-related API operations
/// Provides methods to fetch moods, create entries, and retrieve mood history
class MoodService {
  /// Fetches all available moods from backend API
  /// Returns a list of [Mood] objects
  /// Throws an exception if the API request fails
  Future<List<Mood>> fetchAllMoods() async {
    final url = ApiService.buildBackendUrl('/moods');

    try {
      final response = await http.get(
        url,
        headers: ApiService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data.map((m) {
          try {
            return Mood.fromJson(m as Map<String, dynamic>);
          } catch (e) {
            debugPrint('Error parsing mood: $m, error: $e');
            rethrow;
          }
        }).toList();
      } else {
        throw Exception
        ('Failed to load moods: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('MoodService.fetchAllMoods error: $e');
      rethrow;
    }
  }

  /// Creates a single mood entry for [userId] with [moodId]
  /// Optional [intensity] (default 50) and [notes] can be provided
  /// Returns the created [MoodEntry] object
  /// Throws an exception if the API request fails
  Future<MoodEntry> createMoodEntry(
    String userId,
    int moodId, {
    int intensity = 50,
    String? notes,
  }) async {
    final url = ApiService.buildBackendUrl('/moods/entries');
    final body = jsonEncode({
      'userId': userId,
      'moodId': moodId,
      'intensity': intensity,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });

    final headers = ApiService.getAuthHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return MoodEntry.fromJson(json);
    } else {
      throw Exception(
      'Failed to create mood entry: ${response.statusCode} - ${response.body}');
    }
  }

  /// Creates multiple mood entries for [userId] with [moodEntries]
  /// Optional [generalNotes] can be provided for the batch
  /// Returns a list of created [MoodEntry] objects
  /// Throws an exception if the API request fails
  Future<List<MoodEntry>> createMultipleMoodEntries(
    String userId,
    List<Map<String, dynamic>> moodEntries,
    String? generalNotes,
  ) async {
    final url = ApiService.buildBackendUrl('/moods/entries/batch');
    final body = jsonEncode({
      'userId': userId,
      'moodEntries': moodEntries,
      if (generalNotes != null && generalNotes.isNotEmpty) 
      'generalNotes': generalNotes,
    });

    final headers = ApiService.getAuthHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
      .toList();
    } else {
      throw Exception(
        'Failed to create mood entries: '
        '${response.statusCode} - ${response.body}');
    }
  }

  /// Fetches all mood entries for the user with [userId]
  /// Returns a list of [MoodEntry] objects
  /// Throws an exception if the API request fails
  Future<List<MoodEntry>> fetchUserMoodEntries(String userId) async {
    final url = ApiService.buildBackendUrl('/moods/entries/user/$userId');
    final response = await http.get(
      url,
      headers: ApiService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
      .toList();
    } else {
      throw Exception('Failed to load mood entries: ${response.statusCode}');
    }
  }

  /// Fetches mood history for the user with [userId]
  /// Returns a list of [MoodHistory] objects
  /// Returns an empty list if no records are found (HTTP 404)
  /// Throws an exception if the API request fails
  Future<List<MoodHistory>> fetchUserMoodHistory(String userId) async {
    final url = ApiService.buildBackendUrl('/users/$userId/moods');

    try {
      final response = await http.get(
        url,
        headers: ApiService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data.map((h) {
          try {
            return MoodHistory.fromJson(h as Map<String, dynamic>);
          } catch (e) {
            debugPrint('Error parsing mood history: $h, error: $e');
            rethrow;
          }
        }).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
      'Failed to load mood history: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('MoodService.fetchUserMoodHistory error: $e');
      rethrow;
    }
  }
}

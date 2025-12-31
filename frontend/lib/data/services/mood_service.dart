import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/mood.dart';
import 'api_service.dart';

class MoodService {
  Future<List<Mood>> fetchAllMoods() async {
    final url = ApiService.buildBackendUrl('/moods');
    
    try {
      final response = await http.get(
        url,
        headers: ApiService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((m) {
          try {
            return Mood.fromJson(m as Map<String, dynamic>);
          } catch (e) {
            debugPrint('Error parsing mood: $m, error: $e');
            rethrow;
          }
        }).toList();
      } else {
        throw Exception('Failed to load moods: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('MoodService.fetchAllMoods error: $e');
      rethrow;
    }
  }

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
      final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      return MoodEntry.fromJson(json);
    } else {
      throw Exception('Failed to create mood entry: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<MoodEntry>> createMultipleMoodEntries(
    String userId,
    List<Map<String, dynamic>> moodEntries,
    String? generalNotes,
  ) async {
    final url = ApiService.buildBackendUrl('/moods/entries/batch');
    final body = jsonEncode({
      'userId': userId,
      'moodEntries': moodEntries,
      if (generalNotes != null && generalNotes.isNotEmpty) 'generalNotes': generalNotes,
    });

    final headers = ApiService.getAuthHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((e) => MoodEntry.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to create mood entries: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<MoodEntry>> fetchUserMoodEntries(String userId) async {
    final url = ApiService.buildBackendUrl('/moods/entries/user/$userId');
    final response = await http.get(
      url,
      headers: ApiService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((e) => MoodEntry.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load mood entries: ${response.statusCode}');
    }
  }

  Future<List<MoodHistory>> fetchUserMoodHistory(String userId) async {
    final url = ApiService.buildBackendUrl('/users/$userId/moods');
    
    try {
      final response = await http.get(
        url,
        headers: ApiService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((h) {
          try {
            return MoodHistory.fromJson(h as Map<String, dynamic>);
          } catch (e) {
            debugPrint('Error parsing mood history: $h, error: $e');
            rethrow;
          }
        }).toList();
      } else if (response.statusCode == 404) {
        // Return empty list if no records found
        return [];
      } else {
        throw Exception('Failed to load mood history: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('MoodService.fetchUserMoodHistory error: $e');
      rethrow;
    }
  }
}


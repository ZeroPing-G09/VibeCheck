import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/mood.dart';
import 'api_service.dart';

class MoodService {
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {}
    return 'http://localhost:8080';
  }

  Future<List<Mood>> fetchAllMoods() async {
    final url = Uri.parse('$baseUrl/moods');
    
    try {
      final response = await http.get(
        url,
        headers: ApiService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        final moods = data.map((m) {
          try {
            return Mood.fromJson(m as Map<String, dynamic>);
          } catch (e) {
            debugPrint('Error parsing mood: $m, error: $e');
            rethrow;
          }
        }).toList();
        return moods;
      } else {
        throw Exception('Failed to load moods: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<MoodEntry> createMoodEntry(String userId, int moodId) async {
    final url = Uri.parse('$baseUrl/moods/entries');
    final body = jsonEncode({
      'userId': userId,
      'moodId': moodId,
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

  Future<List<MoodEntry>> fetchUserMoodEntries(String userId) async {
    final url = Uri.parse('$baseUrl/moods/entries/user/$userId');
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
}


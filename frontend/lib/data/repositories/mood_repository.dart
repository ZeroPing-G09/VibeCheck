import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frontend/data/models/mood.dart';
import 'package:frontend/data/services/mood_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository handling moods and mood entries
/// Orchestrates [MoodService] and local caching via SharedPreferences
class MoodRepository {

  /// Creates a [MoodRepository] with optional [MoodService]
  /// If none is provided, a default instance is used
  MoodRepository({MoodService? moodService})
      : _service = moodService ?? MoodService();
  final MoodService _service;

  /// Fetches all moods from the service
  /// Caches moods locally and falls back to cached data on failure
  Future<List<Mood>> getAllMoods() async {
    try {
      final moods = await _service.fetchAllMoods();
      if (moods.isNotEmpty) {
        await _cacheMoods(moods);
      }
      return moods;
    } catch (e) {
      debugPrint('Error fetching moods from API: $e');
      final cachedMoods = await getCachedMoods();
      if (cachedMoods.isEmpty) {
        throw Exception('Failed to load moods: $e');
      }
      return cachedMoods;
    }
  }

  /// Stores moods in SharedPreferences
  Future<void> _cacheMoods(List<Mood> moods) async {
    final prefs = await SharedPreferences.getInstance();
    final moodsJson = moods.map((m) => m.toJson()).toList();
    await prefs.setString('cached_moods', jsonEncode(moodsJson));
  }

  /// Retrieves cached moods from SharedPreferences
  /// Returns empty list if none are cached
  Future<List<Mood>> getCachedMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('cached_moods');
    if (stored != null) {
      final data = jsonDecode(stored) as List<dynamic>;
      return data.map((m) => Mood.fromJson(m as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// Creates a single mood entry for a user with optional intensity and notes
  Future<MoodEntry> createMoodEntry(
    String userId,
    int moodId, {
    int intensity = 50,
    String? notes,
  }) async {
    return _service.createMoodEntry(
      userId,
      moodId,
      intensity: intensity,
      notes: notes,
    );
  }

  /// Creates multiple mood entries for a user with optional general notes
  Future<List<MoodEntry>> createMultipleMoodEntries(
    String userId,
    List<Map<String, dynamic>> moodEntries,
    String? generalNotes,
  ) async {
    return _service.createMultipleMoodEntries(
      userId,
      moodEntries,
      generalNotes,
    );
  }

  /// Fetches all mood entries for a given user
  Future<List<MoodEntry>> getUserMoodEntries(String userId) async {
    return _service.fetchUserMoodEntries(userId);
  }
}

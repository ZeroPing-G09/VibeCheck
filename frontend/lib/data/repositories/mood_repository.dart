import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mood.dart';
import '../services/mood_service.dart';

class MoodRepository {
  final MoodService _service;

  MoodRepository({MoodService? moodService})
      : _service = moodService ?? MoodService();

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

  Future<void> _cacheMoods(List<Mood> moods) async {
    final prefs = await SharedPreferences.getInstance();
    final moodsJson = moods.map((m) => m.toJson()).toList();
    await prefs.setString('cached_moods', jsonEncode(moodsJson));
  }

  Future<List<Mood>> getCachedMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('cached_moods');
    if (stored != null) {
      final List<dynamic> data = jsonDecode(stored) as List<dynamic>;
      return data.map((m) => Mood.fromJson(m as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<MoodEntry> createMoodEntry(
    String userId,
    int moodId, {
    int intensity = 50,
    String? notes,
  }) async {
    return await _service.createMoodEntry(
      userId,
      moodId,
      intensity: intensity,
      notes: notes,
    );
  }

  Future<List<MoodEntry>> createMultipleMoodEntries(
    String userId,
    List<Map<String, dynamic>> moodEntries,
    String? generalNotes,
  ) async {
    return await _service.createMultipleMoodEntries(
      userId,
      moodEntries,
      generalNotes,
    );
  }

  Future<List<MoodEntry>> getUserMoodEntries(String userId) async {
    return await _service.fetchUserMoodEntries(userId);
  }
}

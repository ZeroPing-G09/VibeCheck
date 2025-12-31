import 'package:flutter/material.dart';
import 'package:frontend/data/models/mood.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/mood_repository.dart';
import 'package:frontend/data/repositories/user_repository.dart';

class MoodViewModel extends ChangeNotifier {
  final MoodRepository _moodRepository;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  MoodViewModel(
    this._moodRepository,
    this._authRepository,
    this._userRepository,
  );

  List<Mood> _availableMoods = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  List<Mood> get availableMoods => _availableMoods;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  /// Command: Loads moods from the API
  Future<void> loadMoods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableMoods = await _moodRepository.getAllMoods();
      debugPrint(
        'MoodViewModel.loadMoods: Loaded ${_availableMoods.length} moods from API',
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('MoodViewModel.loadMoods error: $e');
      _availableMoods = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Command: Saves a mood entry (handles user fetching internally)
  Future<void> saveMoodEntry(
    int moodId, {
    int intensity = 50,
    String? notes,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final email = _authRepository.currentUser?.email;
      if (email == null) {
        throw Exception('User not authenticated');
      }

      final user = await _userRepository.getUserByEmail(email);
      await _moodRepository.createMoodEntry(
        user.id,
        moodId,
        intensity: intensity,
        notes: notes,
      );
      debugPrint(
        'MoodViewModel.saveMoodEntry: Saved mood $moodId with intensity $intensity for user ${user.id}',
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('MoodViewModel.saveMoodEntry error: $e');
      notifyListeners();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Command: Saves multiple mood entries in batch
  Future<void> saveMultipleMoodEntries(
    List<Map<String, dynamic>> moodEntries,
    String? generalNotes,
  ) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final email = _authRepository.currentUser?.email;
      if (email == null) {
        throw Exception('User not authenticated');
      }

      final user = await _userRepository.getUserByEmail(email);
      await _moodRepository.createMultipleMoodEntries(
        user.id,
        moodEntries,
        generalNotes,
      );
      debugPrint(
        'MoodViewModel.saveMultipleMoodEntries: Saved ${moodEntries.length} moods for user ${user.id}',
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('MoodViewModel.saveMultipleMoodEntries error: $e');
      notifyListeners();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Command: Fetches mood entries for a user
  Future<List<MoodEntry>> getUserMoodEntries(String userId) async {
    try {
      return await _moodRepository.getUserMoodEntries(userId);
    } catch (e) {
      debugPrint('MoodViewModel.getUserMoodEntries error: $e');
      rethrow;
    }
  }

  void clear() {
    _error = null;
    notifyListeners();
  }
}

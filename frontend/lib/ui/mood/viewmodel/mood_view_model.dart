import 'package:flutter/material.dart';
import 'package:frontend/data/models/mood.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/mood_repository.dart';
import 'package:frontend/data/repositories/user_repository.dart';

/// ViewModel for managing mood-related state and operations.
class MoodViewModel extends ChangeNotifier {

  /// Creates a [MoodViewModel] with the required repositories.
  MoodViewModel(
    this._moodRepository,
    this._authRepository,
    this._userRepository,
  );
  final MoodRepository _moodRepository;
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  List<Mood> _availableMoods = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  /// Gets the list of available moods.
  List<Mood> get availableMoods => _availableMoods;
  /// Indicates if moods are being loaded.
  bool get isLoading => _isLoading;
  /// Indicates if a mood entry is being saved.
  bool get isSaving => _isSaving;
  /// Gets the current error message, if any.
  String? get error => _error;

  /// Command: Loads moods from the API
  Future<void> loadMoods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableMoods = await _moodRepository.getAllMoods();
      debugPrint(
        'MoodViewModel.loadMoods: Loaded ${_availableMoods.length} moods'
        ' from API',
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
        'MoodViewModel.saveMoodEntry: Saved mood $moodId with intensity'
        ' $intensity for user ${user.id}',
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
        'MoodViewModel.saveMultipleMoodEntries: Saved ${moodEntries.length} '
        'moods for user ${user.id}',
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

  /// Command: Clears the current error state
  void clear() {
    _error = null;
    notifyListeners();
  }
}

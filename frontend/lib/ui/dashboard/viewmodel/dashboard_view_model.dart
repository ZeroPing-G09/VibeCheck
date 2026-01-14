import 'package:flutter/material.dart';
import 'package:frontend/data/models/last_playlist.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/mood_repository.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/data/services/playlist_service.dart';
import 'package:frontend/di/locator.dart';

/// Represents the current state of the playlist section in the dashboard.
enum PlaylistState { 
  /// Playlist is currently being loaded
  loading, 

  /// Playlist loaded successfully
  loaded, 

  /// No playlist available
  empty, 

  /// Error occurred while fetching or generating playlist
  error 
}

/// ViewModel for the Dashboard screen, managing user, playlist, and mood data.
class DashboardViewModel extends ChangeNotifier {

  /// Constructor with optional dependency injection for repositories
  DashboardViewModel({
    UserRepository? userRepository,
    AuthRepository? authRepository,
    MoodRepository? moodRepository,
  })  : _userRepository = userRepository ?? UserRepository(),
        _authRepository = authRepository ?? locator<AuthRepository>(),
        _moodRepository = moodRepository ?? MoodRepository();
        
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  final MoodRepository _moodRepository;
  final PlaylistService _playlistService = locator<PlaylistService>();

  User? _user;
  bool _isLoading = false;
  String? _error;

  // Playlist state
  LastPlaylist? _lastPlaylist;
  PlaylistState _playlistState = PlaylistState.loading;
  String? _playlistError;
  bool _isGeneratingPlaylist = false;

  /// Current authenticated user
  User? get user => _user;

  /// Whether the view model is loading data
  bool get isLoading => _isLoading;

  /// Error message, if any
  String? get error => _error;

  /// Last fetched playlist
  LastPlaylist? get lastPlaylist => _lastPlaylist;

  /// Current state of the playlist section
  PlaylistState get playlistState => _playlistState;

  /// Error message related to playlist operations
  String? get playlistError => _playlistError;

  /// Whether a playlist is currently being generated
  bool get isGeneratingPlaylist => _isGeneratingPlaylist;

  /// Gets the current authenticated user's email
  String? get currentUserEmail => _authRepository.currentUser?.email;

  /// Gets the display name with fallback logic
  String getDisplayName() {
    if (_user != null && _user!.displayName.isNotEmpty) {
      return _user!.displayName;
    }

    final supabaseUser = _authRepository.currentUser;
    if (supabaseUser != null) {
      final fullName = supabaseUser.userMetadata?['full_name'];
      if (fullName is String && fullName.isNotEmpty) {
        return fullName;
      }

      final email = supabaseUser.email;
      if (email != null && email.contains('@')) {
        return email.split('@')[0];
      }
    }

    return 'User';
  }

  /// Gets the avatar URL with fallback logic
  String getAvatarUrl() {
    if (_user != null && _user!.avatarUrl.isNotEmpty) {
      return _user!.avatarUrl;
    }

    final supabaseUser = _authRepository.currentUser;
    if (supabaseUser != null) {
      final avatarUrl = supabaseUser.userMetadata?['avatar_url'];
      if (avatarUrl is String && avatarUrl.isNotEmpty) {
        return avatarUrl;
      }
    }

    return '';
  }

  /// Command: Load user by email
  Future<void> loadUserByEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _userRepository
          .getUserByEmail(email)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Server unreachable');
            },
          );
    } catch (e) {
      debugPrint('DashboardViewModel.loadUserByEmail error: $e');

      _error = 'Server unreachable. You may be offline.';
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Load the last playlist for the authenticated user.
  /// Optionally filters by mood if provided.
  Future<void> loadLastPlaylist({String? mood}) async {
    _playlistState = PlaylistState.loading;
    _playlistError = null;
    notifyListeners();

    try {
      _lastPlaylist = await _playlistService.fetchLastPlaylist(mood: mood);
      _playlistState =
          _lastPlaylist != null ? PlaylistState.loaded : PlaylistState.empty;
    } catch (e) {
      // Only show error for authentication issues, treat other errors as 
      // no playlist
      if (e.toString().contains('Unauthorized')) {
        _playlistError = e.toString();
        _playlistState = PlaylistState.error;
      } else {
        // For other errors (network, server issues), treat as no playlist
        _playlistState = PlaylistState.empty;
        _playlistError = null;
      }
    } finally {
      notifyListeners();
    }
  }

  /// Command: Handle user action (profile, settings, logout)
  Future<void> handleUserAction(String action) async {
    switch (action) {
      case 'profile':
        // Navigation is handled by the view/router
        break;
      case 'settings':
        // Navigation is handled by the view/router
        break;
      case 'logout':
        await _authRepository.signOut();
        clear();
    }
    notifyListeners();
  }

  /// Gets the last saved mood for the current user.
  /// Returns null if no mood entries exist.
  Future<String?> _getLastMoodName() async {
    try {
      if (_user == null) {
        return null;
      }

      final moodEntries = await _moodRepository.getUserMoodEntries(_user!.id);
      if (moodEntries.isEmpty) {
        return null;
      }

      // Entries are sorted by createdAt desc, so first one is the latest
      return moodEntries.first.moodName;
    } catch (e) {
      debugPrint('DashboardViewModel._getLastMoodName error: $e');
      return null;
    }
  }

  /// Generates a new playlist using the last saved mood.
  /// Uses the user's favorite genres if available.
  /// After generation, automatically reloads the last playlist.
  /// Allows multiple simultaneous requests.
  Future<void> generatePlaylist({String? mood}) async {
    _isGeneratingPlaylist = true;
    _playlistError = null;
    notifyListeners();

    try {
      // Use provided mood, or get the last saved mood, fallback to "happy" if 
      //none exists
      final moodName = mood ?? await _getLastMoodName() ?? 'happy';

      // Use user's favorite genres if available, otherwise empty list
      final userGenres = _user?.genres ?? [];

      await _playlistService.generatePlaylist(
        mood: moodName,
        genres: userGenres,
      );

      // After successful generation, reload the last playlist with the 
      //specific mood
      await loadLastPlaylist(mood: moodName);
    } catch (e) {
      _playlistError = e.toString();
      _playlistState = PlaylistState.error;
      notifyListeners();
    } finally {
      _isGeneratingPlaylist = false;
      notifyListeners();
    }
  }

  /// Updates the Spotify playlist ID for the current playlist
  void updateSpotifyPlaylistId(String spotifyPlaylistId) {
    if (_lastPlaylist != null) {
      _lastPlaylist = _lastPlaylist!.copyWith(
        spotifyPlaylistId: spotifyPlaylistId);
      notifyListeners();
    }
  }

  /// Clears all user and playlist state and notifies listeners.
  void clear() {
    _user = null;
    _error = null;
    _lastPlaylist = null;
    _playlistState = PlaylistState.loading;
    _playlistError = null;
    _isGeneratingPlaylist = false;
    notifyListeners();
  }
}

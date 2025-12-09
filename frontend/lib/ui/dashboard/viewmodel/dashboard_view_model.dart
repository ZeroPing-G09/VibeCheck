import 'package:flutter/material.dart';
import 'package:frontend/data/models/last_playlist.dart';
import 'package:frontend/data/services/playlist_service.dart';
import 'package:frontend/di/locator.dart';

import '../../../../data/models/user.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/auth_repository.dart';

/// State for the playlist section of the dashboard.
enum PlaylistState { loading, loaded, empty, error }

class DashboardViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final PlaylistService _playlistService = locator<PlaylistService>();
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  DashboardViewModel(
    this._userRepository,
    this._authRepository,
  );

  User? _user;
  bool _isLoading = false;
  String? _error;

  // Playlist state
  LastPlaylist? _lastPlaylist;
  PlaylistState _playlistState = PlaylistState.loading;
  String? _playlistError;
  bool _isGeneratingPlaylist = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Playlist getters
  LastPlaylist? get lastPlaylist => _lastPlaylist;
  PlaylistState get playlistState => _playlistState;
  String? get playlistError => _playlistError;
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
      _user = await _userRepository.getUserByEmail(email);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load the last playlist for the authenticated user.
  Future<void> loadLastPlaylist() async {
    _playlistState = PlaylistState.loading;
    _playlistError = null;
    notifyListeners();

    try {
      _lastPlaylist = await _playlistService.fetchLastPlaylist();
      _playlistState =
          _lastPlaylist != null ? PlaylistState.loaded : PlaylistState.empty;
    } catch (e) {
      // Only show error for authentication issues, treat other errors as no playlist
      if (e.toString().contains('Unauthorized')) {
        _playlistError = e.toString();
        _playlistState = PlaylistState.error;
      } else {
        // For other errors (network, server issues), treat as no playlist
        _playlistState = PlaylistState.empty;
        _playlistError = null;
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
        break;
    }
    notifyListeners();
  }

  /// Generates a new playlist with the specified mood.
  /// Currently hardcoded to use "happy" mood.
  /// Uses the user's favorite genres if available.
  /// After generation, automatically reloads the last playlist.
  /// Allows multiple simultaneous requests.
  Future<void> generatePlaylist() async {
    _isGeneratingPlaylist = true;
    _playlistError = null;
    notifyListeners();

    try {
      // Hardcoded mood: "happy"
      // Use user's favorite genres if available, otherwise empty list
      final userGenres = _user?.genres ?? [];
      
      await _playlistService.generatePlaylist(
        mood: 'happy',
        genres: userGenres,
      );

      // After successful generation, reload the last playlist
      await loadLastPlaylist();
    } catch (e) {
      _playlistError = e.toString();
      _playlistState = PlaylistState.error;
      notifyListeners();
    } finally {
      _isGeneratingPlaylist = false;
      notifyListeners();
    }
  }

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

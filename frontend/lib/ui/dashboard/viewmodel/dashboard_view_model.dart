import 'package:flutter/material.dart';
import 'package:frontend/data/models/last_playlist.dart';
import 'package:frontend/data/services/playlist_service.dart';
import 'package:frontend/di/locator.dart';

import '../../../../data/models/user.dart';
import '../../../../data/repositories/user_repository.dart';

/// State for the playlist section of the dashboard.
enum PlaylistState { loading, loaded, empty, error }

class DashboardViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final PlaylistService _playlistService = locator<PlaylistService>();

  User? _user;
  bool _isLoading = false;
  String? _error;

  // Playlist state
  LastPlaylist? _lastPlaylist;
  PlaylistState _playlistState = PlaylistState.loading;
  String? _playlistError;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Playlist getters
  LastPlaylist? get lastPlaylist => _lastPlaylist;
  PlaylistState get playlistState => _playlistState;
  String? get playlistError => _playlistError;

  Future<void> loadUserByEmail(String email) async {
    _isLoading = true;
    _error = null;

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
    }
    notifyListeners();
  }

  void clear() {
    _user = null;
    _error = null;
    _lastPlaylist = null;
    _playlistState = PlaylistState.loading;
    _playlistError = null;
    notifyListeners();
  }
}

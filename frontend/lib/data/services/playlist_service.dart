import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:frontend/data/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/data/models/last_playlist.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Needed for providerToken

/// Service for fetching playlist-related data from the backend.
class PlaylistService {
  final AuthService _authService;

  PlaylistService({required AuthService authService})
      : _authService = authService;

  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {}
    return 'http://localhost:8080';
  }

  /// Fetches the last playlist for the authenticated user.
  Future<LastPlaylist?> fetchLastPlaylist({String? mood}) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$baseUrl/users/last-playlist');
    final url = mood != null && mood.isNotEmpty
        ? uri.replace(queryParameters: {'mood': mood})
        : uri;
    debugPrint('PlaylistService.fetchLastPlaylist GET $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('fetchLastPlaylist status: ${response.statusCode}');
    debugPrint('fetchLastPlaylist body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return LastPlaylist.fromJson(json);
    } else if (response.statusCode == 404) {
      return null;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      debugPrint('Error fetching playlist (${response.statusCode}), treating as no playlist');
      return null;
    }
  }

  /// Generates a new playlist for the authenticated user.
  Future<void> generatePlaylist({
    required String mood,
    List<String>? genres,
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse('$baseUrl/playlist/generate');
    debugPrint('PlaylistService.generatePlaylist POST $url');

    final requestBody = jsonEncode({
      'mood': mood,
      'genres': genres ?? [],
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    debugPrint('generatePlaylist status: ${response.statusCode}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception(
          'Failed to generate playlist: ${response.statusCode} - ${response.body}');
    }
  }

  /// Saves an existing internal playlist to the user's Spotify account.
  /// Saves an existing internal playlist to the user's Spotify account.
  Future<Map<String, dynamic>> savePlaylistToSpotify({
    required String playlistId, // String because Backend expects UUID
    required String spotifyPlaylistName,
  }) async {
    // 1. Get the current Supabase session
    final session = Supabase.instance.client.auth.currentSession;
    
    // 2. Extract the Supabase Auth Token (for your API)
    final supabaseToken = session?.accessToken;

    // 3. Extract the Spotify Provider Token (for Spotify API)
    // CRITICAL: This is null if scopes are wrong or session is stale
    final spotifyToken = session?.providerToken;

    // Check 1: User isn't logged into Supabase at all
    if (session == null || supabaseToken == null) {
      throw Exception('Not authenticated. Please log in again.');
    }

    // Check 2: User is logged in, but we lost the connection to Spotify
    if (spotifyToken == null) {
      throw Exception('Spotify permission missing. Please Log Out and Log In again to refresh the connection.');
    }
    
    // 4. Prepare the request
    final userId = session.user.id;
    final url = Uri.parse('$baseUrl/users/playlist/save');
    debugPrint('PlaylistService.savePlaylistToSpotify POST $url');
    
    final body = jsonEncode({
      'playlistId': playlistId,
      'spotifyPlaylistName': spotifyPlaylistName,
    });

    // 5. Send to Backend
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $supabaseToken', // Supabase Auth
        'X-User-Id': userId,                      // User ID
        'X-Spotify-Token': spotifyToken,          // Spotify Token (Pass-through)
        'Content-Type': 'application/json',
      },
      body: body,
    );

    debugPrint('savePlaylistToSpotify status: ${response.statusCode}');
    debugPrint('savePlaylistToSpotify body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorBody['message'] ?? 'Failed to save playlist to Spotify');
    }
  }
}
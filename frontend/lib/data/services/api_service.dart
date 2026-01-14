import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized API configuration and utilities
/// Handles Supabase initialization, backend URL, auth headers, and token access
class ApiService {
  /// Supabase project URL from environment variables
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase anonymous key from environment variables
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Backend API base URL depending on platform
  /// Returns localhost for web, Android emulator, or default
  static String get backendBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080';
      }
    } catch (_) {}
    return 'http://localhost:8080';
  }

  /// Initializes environment and Supabase client
  /// Loads `.env` file and configures Supabase
  static Future<void> init() async {
    await dotenv.load();
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  /// Returns the current Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Returns the current user's access token if available
  /// Returns null if no session exists
  static String? get accessToken {
    final session = client.auth.currentSession;
    return session?.accessToken;
  }

  /// Gets headers with authentication token for backend API requests
  /// [additionalHeaders] can be provided to include extra headers
  /// Returns a [Map<String, String>] with `Content-Type` and 
  /// optional `Authorization`
  static Map<String, String> getAuthHeaders({
    Map<String, String>? additionalHeaders,
  }) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (additionalHeaders != null) ...additionalHeaders,
    };

    final token = accessToken;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      debugPrint(
        'ApiService.getAuthHeaders: WARNING - No access token available',
      );
    }

    return headers;
  }

  /// Builds a full [Uri] for backend API endpoints from [path]
  /// Automatically handles leading slashes to avoid double slashes
  static Uri buildBackendUrl(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$backendBaseUrl/$cleanPath');
  }
}

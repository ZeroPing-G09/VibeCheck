import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized API configuration and utilities
class ApiService {
  // Supabase configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Backend API base URL - centralized to avoid duplication
  static String get backendBaseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {}
    return 'http://localhost:8080';
  }

  static Future<void> init() async {
    // Load .env file
    await dotenv.load(fileName: '.env');

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;

  static String? get accessToken {
    final session = client.auth.currentSession;
    return session?.accessToken;
  }

  /// Gets headers with authentication token for backend API requests
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

  /// Builds a full URL for backend API endpoints
  static Uri buildBackendUrl(String path) {
    // Remove leading slash if present to avoid double slashes
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$backendBaseUrl/$cleanPath');
  }
}

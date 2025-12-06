import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static Future<void> init() async {
    // Load .env file
    await dotenv.load(fileName: '.env');
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static String? get accessToken {
    final session = client.auth.currentSession;
    return session?.accessToken;
  }

  static Map<String, String> getAuthHeaders({Map<String, String>? additionalHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (additionalHeaders != null) ...additionalHeaders,
    };
    
    final token = accessToken;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      debugPrint('ApiService.getAuthHeaders: Token found, length: ${token.length}');
    } else {
      debugPrint('ApiService.getAuthHeaders: WARNING - No access token available');
    }
    
    return headers;
  }
}

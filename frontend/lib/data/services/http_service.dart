import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class HttpService {
  /// Generic secure GET request attaching Supabase access token.
  static Future<http.Response> getSecure(String url) async {
    final session = Supabase.instance.client.auth.currentSession;
    final accessToken = session?.accessToken;

    final resp = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (resp.statusCode == 401) {
      // Token invalid/expired — sign out locally to force AuthGate → Login
      await Supabase.instance.client.auth.signOut();
    }

    return resp;
  }

  /// You can add post/put/delete later with the same pattern.
}

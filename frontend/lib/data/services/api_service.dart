import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static const String supabaseUrl = 'https://gghjarogdbzicwrjmtkw.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdnaGphcm9nZGJ6aWN3cmptdGt3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4Mzg0NTksImV4cCI6MjA3NzQxNDQ1OX0.-bnyn2ovB5ZzWh5pbw80DTY__EuGfXVFzENG0A-Ii_g';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

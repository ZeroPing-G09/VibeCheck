
import 'package:flutter/material.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/di/locator.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();  // Supabase.initialize + dotenv
  setupLocator();
  runApp(const VibeCheckApp());
}

import 'package:flutter/material.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/ui/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  runApp(const VibeCheckApp());
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/di/locator.dart';
import 'app.dart';

// ViewModels
import 'ui/dashboard/viewmodel/dashboard_view_model.dart';
import 'ui/profile/viewmodel/profile_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();   // Supabase.initialize + dotenv
  setupLocator();            // GetIt DI

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: const VibeCheckApp(),   // uses MaterialApp.router
    ),
  );
}
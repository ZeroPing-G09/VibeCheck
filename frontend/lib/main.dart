import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/services/api_service.dart';
import 'ui/dashboard/viewmodel/dashboard_view_model.dart';
import 'ui/profile/viewmodel/profile_view_model.dart';
import 'ui/settings/viewmodel/theme_view_model.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: const VibeCheckApp(),
    ),
  );
}

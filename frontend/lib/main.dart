import 'package:flutter/material.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/di/locator.dart';
import 'package:frontend/ui/app.dart';
import 'package:frontend/ui/auth/viewmodel/auth_view_model.dart';
import 'package:frontend/ui/dashboard/viewmodel/dashboard_view_model.dart';
import 'package:frontend/ui/mood/viewmodel/mood_view_model.dart';
import 'package:frontend/ui/onboarding/viewmodel/onboarding_view_model.dart';
import 'package:frontend/ui/profile/viewmodel/profile_view_model.dart';
import 'package:frontend/ui/settings/viewmodel/theme_view_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  await setupLocator();

  await Hive.initFlutter();
  await Hive.openBox<dynamic>('userBox');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<AuthViewModel>()),
        ChangeNotifierProvider(create: (_) => locator<DashboardViewModel>()),
        ChangeNotifierProvider(create: (_) => locator<ProfileViewModel>()),
        ChangeNotifierProvider(create: (_) => locator<ThemeViewModel>()),
        ChangeNotifierProvider(create: (_) => locator<OnboardingViewModel>()),
        ChangeNotifierProvider(create: (_) => locator<MoodViewModel>()),
        
      ],
      child: const VibeCheckApp(),
    ),
  );
}

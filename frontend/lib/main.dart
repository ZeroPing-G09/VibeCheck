import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/dashboard/view/dashboard_view.dart';
import 'ui/dashboard/viewmodel/dashboard_view_model.dart';
import 'ui/profile/view/profile_view.dart';
import 'ui/profile/viewmodel/profile_view_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZeroPing',
      routes: {
        '/dashboard': (_) => const DashboardView(),
        '/profile': (_) => const ProfileView(),
      },
      initialRoute: '/dashboard',
    );
  }
}

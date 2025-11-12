import 'package:flutter/material.dart';
import 'package:frontend/app_router.dart';

class VibeCheckApp extends StatelessWidget {
  const VibeCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,          
      debugShowCheckedModeBanner: false,
      title: 'VibeCheck',
      theme: ThemeData(useMaterial3: true),
    );
  }
}
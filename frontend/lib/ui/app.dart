import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/routing/app_router.dart';
import '../core/theme/app_theme.dart';
import '../ui/auth/view/login_view.dart';
import '../ui/auth/viewmodel/auth_view_model.dart';
import '../ui/home/view/home_view.dart';
import '../ui/settings/viewmodel/theme_view_model.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'VibeCheck',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeViewModel.isDarkMode 
              ? ThemeMode.dark 
              : ThemeMode.light,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: AppRouter.initialRoute,
            routes: {
              '/login': (_) => const LoginView(),
              '/home': (_) => const HomeView(),
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/core/routing/app_router.dart';
import '../viewmodel/dashboard_view_model.dart';
import '../widgets/user_chip.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardViewModel>().loadUser(1);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Text(
          'ZeroPing',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: viewModel.isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : viewModel.user != null
                    ? UserChip(
                        username: viewModel.user!.username,
                        imageUrl: viewModel.user!.profilePicture,
                        onActionSelected: (value) async {
                          if (value == 'profile') {
                            AppRouter.navigatorKey.currentState
                                ?.pushNamed(AppRouter.profileRoute);
                          } else if (value == 'settings') {
                            AppRouter.navigatorKey.currentState
                                ?.pushNamed(AppRouter.settingsRoute);
                          } else if (value == 'logout') {
                            await AuthRepository().signOut();
                            if (mounted) {
                              context.read<DashboardViewModel>().clear();
                              AppRouter.navigatorKey.currentState
                                  ?.pushNamedAndRemoveUntil(
                                AppRouter.loginRoute,
                                (route) => false,
                              );
                            }
                          }
                        },
                      )
                    : const Icon(Icons.error_outline),
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.error != null
              ? Center(child: Text('Error: ${viewModel.error}'))
              : viewModel.user != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome, ${viewModel.user!.username}! ',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: viewModel.user!.genres
                                .map((g) => Chip(label: Text(g)))
                                .toList(),
                          ),
                        ],
                      ),
                    )
                  : const Center(child: Text('No user loaded')),
    );
  }
}

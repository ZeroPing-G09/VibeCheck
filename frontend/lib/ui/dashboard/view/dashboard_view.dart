import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // Example user id
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
                        onActionSelected: (value) {
                          if (value == 'profile') {
                            Navigator.pushNamed(context, '/profile');
                          } else if (value == 'logout') {
                            Navigator.pushReplacementNamed(context, '/login');
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
                            'Welcome, ${viewModel.user!.username}!',
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

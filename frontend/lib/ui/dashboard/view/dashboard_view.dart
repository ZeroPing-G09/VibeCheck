import 'package:flutter/material.dart';
import 'package:frontend/core/routing/app_router.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/di/locator.dart';
import 'package:frontend/ui/dashboard/viewmodel/dashboard_view_model.dart';
import 'package:frontend/ui/dashboard/widgets/last_playlist_section.dart';
import 'package:frontend/ui/dashboard/widgets/user_chip.dart';
import 'package:frontend/ui/home/view/home_view.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    // The loadUserByEmail method is likely correct if the view model is responsible
    // for fetching the 'public.users' record based on the Supabase user's email.
    final email = locator<AuthRepository>().currentUser?.email;
    if (email != null) {
      context.read<DashboardViewModel>().loadUserByEmail(email);
    }
    // Load the last playlist for the authenticated user
    context.read<DashboardViewModel>().loadLastPlaylist();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final authRepo = locator<AuthRepository>();
    final supabaseUser = authRepo.currentUser;

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
                : supabaseUser != null
                ? UserChip(
                    // 1. UPDATED: Use viewModel.user?.displayName
                    username:
                        viewModel.user?.displayName ??
                        (supabaseUser.userMetadata?['full_name'] as String?) ??
                        (supabaseUser.email != null &&
                                supabaseUser.email!.contains('@')
                            ? supabaseUser.email!.split('@')[0]
                            : 'User'),
                    // 2. UPDATED: Use viewModel.user?.avatarUrl
                    imageUrl:
                        viewModel.user?.avatarUrl ??
                        (supabaseUser.userMetadata?['avatar_url'] as String?) ??
                        '',
                    onActionSelected: (value) async {
                      if (value == 'profile') {
                        final homeViewState = HomeView.of(context);
                        if (homeViewState != null) {
                          homeViewState.switchToTab(0);
                        } else {
                          AppRouter.navigatorKey.currentState?.pushNamed(
                            AppRouter.profileRoute,
                          );
                        }
                      } else if (value == 'settings') {
                        final homeViewState = HomeView.of(context);
                        if (homeViewState != null) {
                          homeViewState.switchToTab(2);
                        } else {
                          AppRouter.navigatorKey.currentState?.pushNamed(
                            AppRouter.settingsRoute,
                          );
                        }
                      } else if (value == 'logout') {
                        await locator<AuthRepository>().signOut();
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
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // 3. UPDATED: Use viewModel.user!.displayName
                    'Welcome, ${viewModel.user!.displayName}!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: viewModel.user!.genres
                        .map((g) => Chip(label: Text(g)))
                        .toList(),
                  ),
                  // Optional: Display last login time
                  if (viewModel.user!.lastLogIn != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Last login: ${viewModel.user!.lastLogIn}'),
                    ),
                  const SizedBox(height: 24),
                  // Last Playlist Section
                  LastPlaylistSection(
                    playlistState: viewModel.playlistState,
                    playlist: viewModel.lastPlaylist,
                    errorMessage: viewModel.playlistError,
                    isGeneratingPlaylist: viewModel.isGeneratingPlaylist,
                    onCreatePlaylist: () {
                      viewModel.generatePlaylist();
                    },
                  ),
                ],
              ),
            )
          : const Center(child: Text('No user loaded')),
    );
  }
}

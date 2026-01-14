// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:frontend/core/routing/app_router.dart';
import 'package:frontend/core/utils/snackbar_helper.dart';
import 'package:frontend/ui/dashboard/viewmodel/dashboard_view_model.dart';
import 'package:frontend/ui/dashboard/widgets/last_playlist_section.dart';
import 'package:frontend/ui/dashboard/widgets/mood_history_widget.dart';
import 'package:frontend/ui/dashboard/widgets/user_chip.dart';
import 'package:frontend/ui/home/view/home_view.dart';
import 'package:frontend/ui/mood/view/mood_selection_dialog.dart';
import 'package:provider/provider.dart';

/// Dashboard screen displaying user info, last playlist, and mood history
/// Handles mood selection and navigation actions
class DashboardView extends StatefulWidget {
  /// Creates a [DashboardView]
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  /// Static flag to prevent multiple mood dialogs from opening
  static bool _isMoodDialogShowing = false;

  /// Flag to prevent reloading the playlist multiple times
  bool _hasLoadedPlaylist = false;

  /// Key to refresh the mood history widget
  final _moodHistoryKey = GlobalKey<MoodHistoryWidgetState>();

  @override
  void initState() {
    super.initState();
    _hasLoadedPlaylist = false;

    // Defer async operations until after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<DashboardViewModel>();
      final email = viewModel.currentUserEmail;
      if (email != null) {
        viewModel.loadUserByEmail(email).then((_) {
          if (mounted && !_hasLoadedPlaylist) {
            _hasLoadedPlaylist = true;
            viewModel.loadLastPlaylist();
          }
        });
      }

      // Open mood selection dialog after short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          openMoodDialog(context: context, 
          viewModel: context.read<DashboardViewModel>());
        }
      });
    });
  }

  @override
  void dispose() {
    _hasLoadedPlaylist = false;
    super.dispose();
  }

  /// Opens the mood selection dialog if not already showing
  /// Updates mood history and generates playlist upon selection
  Future<void> openMoodDialog({
    required BuildContext context,
    required DashboardViewModel viewModel,
  }) async {
    if (_isMoodDialogShowing) {
      return;
    }
    _isMoodDialogShowing = true;

    if (viewModel.isLoading) {
      await Future.doWhile(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return viewModel.isLoading;
      });
    }

    if (viewModel.user == null) {
      _isMoodDialogShowing = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: 
        Text('Server is offline. Cannot select a mood right now')),
      );
      return;
    }

    await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const MoodSelectionDialog(),
    ).then((result) {
      _isMoodDialogShowing = false;

      if (result != null && mounted) {
        final moodSaved = result['saved'] as bool? ?? false;
        final moodName = result['moodName'] as String?;

        if (moodSaved) {
          SnackbarHelper.showSuccess(context, 'Mood saved successfully!');
          _moodHistoryKey.currentState?.refresh();

          if (moodName != null && moodName.isNotEmpty) {
            viewModel.generatePlaylist(mood: moodName);
          }
        }
      }
    }).catchError((_) {
      _isMoodDialogShowing = false;
    });
  }

  /// Handles user action menu selections: profile, settings, logout
  Future<void> _handleActionSelected(String value) async {
    final viewModel = context.read<DashboardViewModel>();

    if (value == 'profile') {
      final homeViewState = HomeView.of(context);
      if (homeViewState != null) {
        homeViewState.switchToTab(0);
      } else {
        await AppRouter.navigatorKey.currentState?.
        pushNamed(AppRouter.profileRoute);
      }
    } else if (value == 'settings') {
      final homeViewState = HomeView.of(context);
      if (homeViewState != null) {
        homeViewState.switchToTab(2);
      } else {
        await AppRouter.navigatorKey.currentState?.
        pushNamed(AppRouter.settingsRoute);
      }
    } else if (value == 'logout') {
      await viewModel.handleUserAction('logout');
      if (mounted) {
        await AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRouter.loginRoute,
          (route) => false,
        );
      }
    }
  }

  /// Builds the user chip with username, avatar, and action menu
  Widget _buildUserChip(DashboardViewModel viewModel) {
    return UserChip(
      username: viewModel.getDisplayName(),
      imageUrl: viewModel.getAvatarUrl(),
      onActionSelected: _handleActionSelected,
    );
  }

  /// Builds the main dashboard body based on [viewModel] state
  Widget _buildBody(DashboardViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.user == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 48),
            SizedBox(height: 12),
            Text('Server unreachable', style: 
            TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('You appear to be offline.\nSome features may be unavailable.'
            , textAlign: TextAlign.center),
          ],
        ),
      );
    }

    final user = viewModel.user!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, ${user.displayName}!', 
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: user.genres.map<Widget>((genre) => 
            Chip(label: Text(genre))).toList(),
          ),
          if (user.lastLogIn != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Last login: ${user.lastLogIn}'),
            ),
          const SizedBox(height: 24),
          LastPlaylistSection(
            playlistState: viewModel.playlistState,
            playlist: viewModel.lastPlaylist,
            errorMessage: viewModel.playlistError,
            isGeneratingPlaylist: viewModel.isGeneratingPlaylist,
            onCreatePlaylist: () => viewModel.generatePlaylist(),
            onSpotifyPlaylistSaved: (spotifyPlaylistId) {
              if (spotifyPlaylistId != null) {
                viewModel.updateSpotifyPlaylistId(spotifyPlaylistId);
              }
            },
          ),
          const SizedBox(height: 24),
          SizedBox(height: 300, child: MoodHistoryWidget(key: _moodHistoryKey)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Text('VibeCheck', style: 
        TextStyle(fontWeight: FontWeight.w700)),
        actions: [Padding(padding: const EdgeInsets.only(right: 12), 
        child: _buildUserChip(viewModel))],
      ),
      body: _buildBody(viewModel),
    );
  }
}

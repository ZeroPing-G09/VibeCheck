import 'package:flutter/material.dart';
import 'package:frontend/core/routing/app_router.dart';
import 'package:frontend/core/utils/snackbar_helper.dart';
import 'package:frontend/core/widgets/error_state.dart';
import 'package:frontend/core/widgets/loading_state.dart';
import 'package:frontend/ui/dashboard/viewmodel/dashboard_view_model.dart';
import 'package:frontend/ui/dashboard/widgets/last_playlist_section.dart';
import 'package:frontend/ui/dashboard/widgets/user_chip.dart';
import 'package:frontend/ui/dashboard/widgets/mood_history_widget.dart';
import 'package:frontend/ui/home/view/home_view.dart';
import 'package:frontend/ui/mood/view/mood_selection_dialog.dart';
import 'package:frontend/core/widgets/loading_state.dart';
import 'package:frontend/core/widgets/error_state.dart';
import 'package:frontend/core/utils/snackbar_helper.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // Static flag shared across all instances to prevent duplicate dialogs
  static bool _isMoodDialogShowing = false;
  bool _hasLoadedPlaylist = false;
  final _moodHistoryKey = GlobalKey<MoodHistoryWidgetState>();

  @override
  void initState() {
    super.initState();
    // Reset playlist flag when widget is recreated
    _hasLoadedPlaylist = false;

    // Defer async operations until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<DashboardViewModel>();
      final email = viewModel.currentUserEmail;
      if (email != null) {
        viewModel.loadUserByEmail(email).then((_) {
          // Load playlist after user is loaded
          if (mounted && !_hasLoadedPlaylist) {
            _hasLoadedPlaylist = true;
            viewModel.loadLastPlaylist();
          }
        });
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isMoodDialogShowing) {
          _showMoodDialog();
        }
      });
    });
  }

  @override
  void dispose() {
    // Reset playlist flag when widget is disposed
    _hasLoadedPlaylist = false;
    super.dispose();
  }

  void _showMoodDialog() {
    // Check multiple conditions to prevent duplicate dialogs
    if (_isMoodDialogShowing || !mounted) {
      return;
    }
    
    _isMoodDialogShowing = true;

    showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const MoodSelectionDialog(),
    ).then((result) {
      // Reset static flag when dialog is closed
      _isMoodDialogShowing = false;
      
      if (result != null && mounted) {
        final moodSaved = result['saved'] as bool? ?? false;
        final moodName = result['moodName'] as String?;
        
        if (moodSaved) {
          SnackbarHelper.showSuccess(context, 'Mood saved successfully!');
          // Refresh mood history when a mood is saved
          _moodHistoryKey.currentState?.refresh();
          
          // Generate playlist automatically with the saved mood
          if (moodName != null && moodName.isNotEmpty) {
            final viewModel = context.read<DashboardViewModel>();
            viewModel.generatePlaylist(mood: moodName);
          }
        }
      }
    }).catchError((error) {
      // Ensure flag is reset even if there's an error
      _isMoodDialogShowing = false;
    });
  }

  void _handleActionSelected(String value) async {
    final viewModel = context.read<DashboardViewModel>();

    if (value == 'profile') {
      final homeViewState = HomeView.of(context);
      if (homeViewState != null) {
        homeViewState.switchToTab(0);
      } else {
        AppRouter.navigatorKey.currentState?.pushNamed(AppRouter.profileRoute);
      }
    } else if (value == 'settings') {
      final homeViewState = HomeView.of(context);
      if (homeViewState != null) {
        homeViewState.switchToTab(2);
      } else {
        AppRouter.navigatorKey.currentState?.pushNamed(AppRouter.settingsRoute);
      }
    } else if (value == 'logout') {
      await viewModel.handleUserAction('logout');
      if (mounted) {
        AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRouter.loginRoute,
          (route) => false,
        );
      }
    }
  }

  Widget _buildUserChip(DashboardViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return UserChip(
      username: viewModel.getDisplayName(),
      imageUrl: viewModel.getAvatarUrl(),
      onActionSelected: _handleActionSelected,
    );
  }

  Widget _buildBody(DashboardViewModel viewModel) {
    if (viewModel.isLoading) {
      return const LoadingState();
    }

    if (viewModel.error != null) {
      return ErrorState(
        message: viewModel.error!,
        onRetry: () {
          final email = viewModel.currentUserEmail;
          if (email != null) {
            viewModel.loadUserByEmail(email);
          }
        },
      );
    }

    final user = viewModel.user;
    if (user == null) {
      return const Center(child: Text('No user loaded'));
    }

return SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Welcome, ${user.displayName}!',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        children: user.genres
            .map<Widget>((String genre) => Chip(label: Text(genre)))
            .toList(),
      ),
      if (user.lastLogIn != null)
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text('Last login: ${user.lastLogIn}'),
        ),

      const SizedBox(height: 24),

      LastPlaylistSection(
        playlistState: viewModel.playlistState,
        playlist: viewModel.lastPlaylist,
        errorMessage: viewModel.playlistError,
        isGeneratingPlaylist: viewModel.isGeneratingPlaylist,
        onCreatePlaylist: () {
          viewModel.generatePlaylist();
        },
      ),

      const SizedBox(height: 24),

      SizedBox(
        height: 300, // adjust as needed
        child: MoodHistoryWidget(key: _moodHistoryKey),
      ),
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
        title: const Text(
          'VibeCheck',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildUserChip(viewModel),
          ),
        ],
      ),
      body: _buildBody(viewModel),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/core/routing/app_router.dart';
import 'package:frontend/ui/dashboard/viewmodel/dashboard_view_model.dart';
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
  bool _hasShownMoodDialog = false;
  final _moodHistoryKey = GlobalKey<MoodHistoryWidgetState>();

  @override
  void initState() {
    super.initState();
    
    // Defer async operations until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<DashboardViewModel>();
      final email = viewModel.currentUserEmail;
      if (email != null) {
        viewModel.loadUserByEmail(email);
      }
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_hasShownMoodDialog) {
          _showMoodDialog();
        }
      });
    });
  }

  void _showMoodDialog() {
    if (_hasShownMoodDialog) return;
    _hasShownMoodDialog = true;
    
    showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const MoodSelectionDialog(),
    ).then((moodSaved) {
      if (moodSaved == true && mounted) {
        SnackbarHelper.showSuccess(context, 'Mood saved successfully!');
        // Refresh mood history when a mood is saved
        _moodHistoryKey.currentState?.refresh();
      }
    });
  }

  void _handleActionSelected(String value) async {
    final viewModel = context.read<DashboardViewModel>();
    
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

    return Column(
      children: [
        // Welcome section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
            ],
          ),
        ),
        // Mood History Widget
        Expanded(
          child: MoodHistoryWidget(key: _moodHistoryKey),
        ),
      ],
    );
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
            child: _buildUserChip(viewModel),
          ),
        ],
      ),
      body: _buildBody(viewModel),
    );
  }
}

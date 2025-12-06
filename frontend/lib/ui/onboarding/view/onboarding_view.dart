import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/routing/app_router.dart';
import 'package:frontend/core/widgets/loading_state.dart';
import 'package:frontend/core/widgets/error_state.dart';
import 'package:frontend/core/widgets/primary_button.dart';
import 'package:frontend/core/widgets/genre_selection_chip.dart';
import 'package:frontend/core/utils/snackbar_helper.dart';
import '../viewmodel/onboarding_view_model.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<OnboardingViewModel>();
    viewModel.loadUser(); // Uses current user email from ViewModel
    viewModel.loadGenres();
  }

  Future<void> _handleComplete() async {
    final viewModel = context.read<OnboardingViewModel>();
    try {
      await viewModel.completeOnboarding();
      if (mounted) {
        AppRouter.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRouter.dashboardRoute,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Failed to save genres: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to VibeCheck!'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<OnboardingViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingState();
          }

          if (viewModel.error != null && viewModel.availableGenres.isEmpty) {
            return ErrorState(
              title: 'Error loading genres',
              message: viewModel.error!,
              onRetry: () => viewModel.loadGenres(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Choose Your Top 3 Music Genres',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select exactly 3 genres that best represent your music taste',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (viewModel.selectedGenres.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected (${viewModel.selectedGenres.length}/3)',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: viewModel.selectedGenres.map((genre) {
                            return GenreSelectionChip(
                              genre: genre,
                              isSelected: true,
                              onDelete: () => viewModel.toggleGenre(genre),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  'Available Genres',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: viewModel.availableGenres.map((genre) {
                    final isSelected = viewModel.selectedGenres.contains(genre);
                    final isDisabled = !isSelected &&
                        viewModel.selectedGenres.length >= 3;
                    return GenreSelectionChip(
                      genre: genre,
                      isSelected: isSelected,
                      isDisabled: isDisabled,
                      onTap: () => viewModel.toggleGenre(genre),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Complete Onboarding',
                  onPressed: viewModel.canComplete && !viewModel.isSaving
                      ? _handleComplete
                      : null,
                  isLoading: viewModel.isSaving,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                if (!viewModel.canComplete && viewModel.selectedGenres.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Please select ${3 - viewModel.selectedGenres.length} more genre(s)',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

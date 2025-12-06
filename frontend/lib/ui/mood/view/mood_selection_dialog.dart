import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/mood_view_model.dart';
import '../../../data/models/mood.dart';
import '../../../core/widgets/dialog_wrapper.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/mood_selection_item.dart';
import '../../../core/utils/snackbar_helper.dart';

class MoodSelectionDialog extends StatefulWidget {
  const MoodSelectionDialog({super.key});

  @override
  State<MoodSelectionDialog> createState() => _MoodSelectionDialogState();
}

class _MoodSelectionDialogState extends State<MoodSelectionDialog> {
  Mood? _selectedMood;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodViewModel>().loadMoods();
    });
  }

  void _handleMoodSelected(Mood mood) async {
    debugPrint('MoodSelectionDialog._handleMoodSelected: Selected mood ${mood.id} (${mood.name})');
    setState(() {
      _selectedMood = mood;
    });
    
    // Auto-save when a mood is selected
    if (!_isSaving) {
      await _handleSave();
    }
  }

  Future<void> _handleSave() async {
    if (_selectedMood == null) {
      debugPrint('MoodSelectionDialog._handleSave: No mood selected');
      return;
    }

    debugPrint('MoodSelectionDialog._handleSave: Saving mood ${_selectedMood!.id} (${_selectedMood!.name})');
    setState(() {
      _isSaving = true;
    });

    try {
      final viewModel = context.read<MoodViewModel>();
      await viewModel.saveMoodEntry(_selectedMood!.id);
      debugPrint('MoodSelectionDialog._handleSave: Successfully saved mood');
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      debugPrint('MoodSelectionDialog._handleSave: Error saving mood: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        SnackbarHelper.showError(context, 'Failed to save mood: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _handleSkip() {
    Navigator.of(context).pop(false);
  }

  Widget _buildMoodContent(MoodViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: LoadingState(),
      );
    }

    if (viewModel.error != null) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: ErrorState(
          title: 'Error loading moods',
          message: viewModel.error!,
          onRetry: () => viewModel.loadMoods(),
        ),
      );
    }

    if (viewModel.availableMoods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: EmptyState(
          title: 'No moods available',
          message: 'Please ensure moods are added to the database',
          icon: Icons.mood_bad,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: viewModel.availableMoods.map((mood) {
          return MoodSelectionItem(
            emoji: mood.emoji,
            name: mood.name,
            colorCode: mood.colorCode,
            isSelected: _selectedMood?.id == mood.id,
            onTap: () => _handleMoodSelected(mood),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodViewModel>(
      builder: (context, viewModel, child) {
        return DialogWrapper(
          title: 'How are you feeling?',
          subtitle: 'Select your current mood',
          actions: [
            SecondaryButton(
              label: 'Skip',
              onPressed: _isSaving ? null : _handleSkip,
            ),
            const SizedBox(width: 8),
            PrimaryButton(
              label: 'Save',
              onPressed: (_selectedMood != null && !_isSaving)
                  ? _handleSave
                  : null,
              isLoading: _isSaving,
            ),
          ],
          child: _buildMoodContent(viewModel),
        );
      },
    );
  }
}

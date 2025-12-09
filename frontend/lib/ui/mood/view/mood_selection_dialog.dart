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
import '../../../core/widgets/mood_dropdown.dart';
import '../../../core/widgets/mood_meter.dart';
import '../../../core/utils/snackbar_helper.dart';

class MoodSelectionDialog extends StatefulWidget {
  const MoodSelectionDialog({super.key});

  @override
  State<MoodSelectionDialog> createState() => _MoodSelectionDialogState();
}

class _MoodSelectionDialogState extends State<MoodSelectionDialog> {
  // Single selected mood
  _SelectedMoodData? _selectedMood;
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;
  bool _showNotes = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoodViewModel>().loadMoods();
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _handleMoodToggled(Mood mood) {
    setState(() {
      if (_selectedMood?.mood.id == mood.id) {
        // Remove if already selected
        _selectedMood = null;
      } else {
        // Replace with new selection (single selection only)
        _selectedMood = _SelectedMoodData(
          mood: mood,
          intensity: 50,
        );
      }
    });
  }

  void _handleIntensityChanged(int moodId, int intensity) {
    setState(() {
      if (_selectedMood?.mood.id == moodId) {
        _selectedMood!.intensity = intensity;
      }
    });
  }

  void _handleRemoveMood(int moodId) {
    setState(() {
      if (_selectedMood?.mood.id == moodId) {
        _selectedMood = null;
      }
    });
  }

  Future<void> _handleSave() async {
    if (_selectedMood == null) {
      SnackbarHelper.showError(context, 'Please select a mood');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final viewModel = context.read<MoodViewModel>();
      
      // Convert selected mood to API format
      final moodEntries = [
        {
          'moodId': _selectedMood!.mood.id,
          'intensity': _selectedMood!.intensity,
        }
      ];

      final generalNotes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      await viewModel.saveMultipleMoodEntries(moodEntries, generalNotes);
      
      if (mounted) {
        Navigator.of(context).pop(true);
        SnackbarHelper.showSuccess(
          context,
          'Mood saved successfully!',
        );
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

  Widget _buildMoodSelector(MoodViewModel viewModel) {
    final selectedMoodsList = _selectedMood != null 
        ? [_selectedMood!.mood]
        : <Mood>[];
    
    return MoodDropdown(
      moods: viewModel.availableMoods,
      selectedMoods: selectedMoodsList,
      onMoodSelected: _handleMoodToggled,
      onMoodRemoved: (mood) => _handleRemoveMood(mood.id),
    );
  }

  Widget _buildSelectedMoodsSection() {
    if (_selectedMood == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Selected Mood',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        MoodMeter(
          moodName: _selectedMood!.mood.name,
          emoji: _selectedMood!.mood.emoji,
          intensity: _selectedMood!.intensity,
          onIntensityChanged: (intensity) {
            _handleIntensityChanged(_selectedMood!.mood.id, intensity);
          },
          onRemove: () => _handleRemoveMood(_selectedMood!.mood.id),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _showNotes = !_showNotes;
            });
          },
          child: Row(
            children: [
              Icon(
                _showNotes ? Icons.expand_less : Icons.expand_more,
              ),
              const SizedBox(width: 8),
              Text(
                'Additional Notes (Optional)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        if (_showNotes) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Tell us more about how you\'re feeling...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]
                  : Colors.grey[100],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContent(MoodViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: LoadingState(),
      );
    }

    if (viewModel.error != null && viewModel.availableMoods.isEmpty) {
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mood selection dropdown with search
          _buildMoodSelector(viewModel),
          const SizedBox(height: 24),
          // Selected mood with meter
          _buildSelectedMoodsSection(),
          if (_selectedMood != null) const SizedBox(height: 24),
          // Notes section
          _buildNotesSection(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodViewModel>(
      builder: (context, viewModel, child) {
        return DialogWrapper(
          title: 'How are you feeling?',
          subtitle: _selectedMood == null
              ? 'Select a mood'
              : 'Adjust intensity',
          actions: [
            SecondaryButton(
              label: 'Skip',
              onPressed: _isSaving ? null : _handleSkip,
            ),
            const SizedBox(width: 8),
            PrimaryButton(
              label: _selectedMood == null ? 'Select a Mood' : 'Save',
              onPressed: (_selectedMood != null && !_isSaving)
                  ? _handleSave
                  : null,
              isLoading: _isSaving,
            ),
          ],
          child: _buildContent(viewModel),
        );
      },
    );
  }
}

// Helper class to store selected mood data
class _SelectedMoodData {
  final Mood mood;
  int intensity;

  _SelectedMoodData({
    required this.mood,
    required this.intensity,
  });
}


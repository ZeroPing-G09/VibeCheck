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
  // Map of selected moods: moodId -> {mood, intensity}
  final Map<int, _SelectedMoodData> _selectedMoods = {};
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
      if (_selectedMoods.containsKey(mood.id)) {
        // Remove if already selected
        _selectedMoods.remove(mood.id);
      } else {
        // Add with default intensity of 50%
        _selectedMoods[mood.id] = _SelectedMoodData(
          mood: mood,
          intensity: 50,
        );
      }
    });
  }

  void _handleIntensityChanged(int moodId, int intensity) {
    setState(() {
      if (_selectedMoods.containsKey(moodId)) {
        _selectedMoods[moodId]!.intensity = intensity;
      }
    });
  }

  void _handleRemoveMood(int moodId) {
    setState(() {
      _selectedMoods.remove(moodId);
    });
  }

  Future<void> _handleSave() async {
    if (_selectedMoods.isEmpty) {
      SnackbarHelper.showError(context, 'Please select at least one mood');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final viewModel = context.read<MoodViewModel>();
      
      // Convert selected moods to API format
      final moodEntries = _selectedMoods.values.map((data) {
        return {
          'moodId': data.mood.id,
          'intensity': data.intensity,
          // Individual notes could be added here if needed
        };
      }).toList();

      final generalNotes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      await viewModel.saveMultipleMoodEntries(moodEntries, generalNotes);
      
      if (mounted) {
        Navigator.of(context).pop(true);
        SnackbarHelper.showSuccess(
          context,
          'Saved ${_selectedMoods.length} mood${_selectedMoods.length > 1 ? 's' : ''}!',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('MoodSelectionDialog._handleSave: Error saving moods: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        SnackbarHelper.showError(context, 'Failed to save moods: $e');
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
    final selectedMoodsList = _selectedMoods.values.map((data) => data.mood).toList();
    
    return MoodDropdown(
      moods: viewModel.availableMoods,
      selectedMoods: selectedMoodsList,
      onMoodSelected: _handleMoodToggled,
      onMoodRemoved: (mood) => _handleRemoveMood(mood.id),
    );
  }

  Widget _buildSelectedMoodsSection() {
    if (_selectedMoods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Selected Moods (${_selectedMoods.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ..._selectedMoods.values.map((data) {
          return MoodMeter(
            moodName: data.mood.name,
            emoji: data.mood.emoji,
            intensity: data.intensity,
            onIntensityChanged: (intensity) {
              _handleIntensityChanged(data.mood.id, intensity);
            },
            onRemove: () => _handleRemoveMood(data.mood.id),
          );
        }).toList(),
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
          // Selected moods with meters
          _buildSelectedMoodsSection(),
          if (_selectedMoods.isNotEmpty) const SizedBox(height: 24),
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
          subtitle: _selectedMoods.isEmpty
              ? 'Select one or more moods'
              : 'Adjust intensity for each mood',
          actions: [
            SecondaryButton(
              label: 'Skip',
              onPressed: _isSaving ? null : _handleSkip,
            ),
            const SizedBox(width: 8),
            PrimaryButton(
              label: _selectedMoods.isEmpty ? 'Select a Mood' : 'Save',
              onPressed: (_selectedMoods.isNotEmpty && !_isSaving)
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


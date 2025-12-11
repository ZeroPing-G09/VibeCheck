import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/mood.dart';
import '../../../data/services/mood_service.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/empty_state.dart';
import '../../dashboard/viewmodel/dashboard_view_model.dart';

class MoodHistoryWidget extends StatefulWidget {
  const MoodHistoryWidget({super.key});

  @override
  State<MoodHistoryWidget> createState() => MoodHistoryWidgetState();
}

class MoodHistoryWidgetState extends State<MoodHistoryWidget> {
  List<MoodHistory>? _moodHistory;
  bool _isLoading = false;
  String? _error;
  final MoodService _moodService = MoodService();
  Timer? _updateTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_moodHistory == null && !_isLoading) {
      _loadMoodHistory();
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  /// Public method to refresh the mood history
  void refresh() {
    _loadMoodHistory();
  }

  void _startUpdateTimer() {
    _updateTimer?.cancel();
    // Update every minute to change "just now" to "1m ago"
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // Force rebuild to update time display
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _loadMoodHistory() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final viewModel = context.read<DashboardViewModel>();
      final user = viewModel.user;
      
      if (user == null) {
        if (mounted) {
          setState(() {
            _error = 'User not loaded';
            _isLoading = false;
          });
        }
        return;
      }

      final history = await _moodService.fetchUserMoodHistory(user.id);
      if (mounted) {
        setState(() {
          // Limit to last 3 moods (already sorted by most recent first)
          _moodHistory = history.take(3).toList();
          _isLoading = false;
        });
        _startUpdateTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: LoadingState(size: 24),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ErrorState(
          message: _error!,
          onRetry: _loadMoodHistory,
        ),
      );
    }

    if (_moodHistory == null || _moodHistory!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: EmptyState(
          message: 'Nu există încă mood-uri înregistrate.',
          icon: Icons.mood_outlined,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Mood History',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _moodHistory!.length,
              itemBuilder: (context, index) {
                final history = _moodHistory![index];
                return _buildMoodHistoryItem(history);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodHistoryItem(MoodHistory history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  history.moodEmoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.moodName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (history.intensity != null)
                        Text(
                          'Intensity: ${history.intensity}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(history.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            if (history.notes != null && history.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                history.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (history.playlists.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Playlists:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...history.playlists.map((playlist) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.music_note, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            playlist.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'just now';
          }
          return '${difference.inMinutes}m ago';
        }
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}


import 'package:flutter/material.dart';

/// A visual mood meter widget that displays a slider for intensity
/// with a color gradient from red (0%) to green (100%)
class MoodMeter extends StatelessWidget {

  /// Creates a mood meter widget
  const MoodMeter({
    required this.moodName,
    required this.emoji,
    required this.intensity,
    required this.onIntensityChanged,
    super.key,
    this.onRemove,
  });
  /// Name of the mood
  final String moodName;

  /// Emoji representing the mood
  final String emoji;

  /// Current intensity of the mood (0-100)
  final int intensity;

  /// Callback when the intensity changes
  final ValueChanged<int> onIntensityChanged;

  /// Optional callback to remove the mood
  final VoidCallback? onRemove;

  /// Returns a color corresponding to the intensity on a gradient 
  /// from red to green
  Color _getColorForIntensity(int intensity) {
    if (intensity <= 25) {
      final ratio = intensity / 25;
      return Color.lerp(
        const Color(0xFFD32F2F),
        const Color(0xFFFF9800),
        ratio,
      )!;
    } else if (intensity <= 50) {
      final ratio = (intensity - 25) / 25;
      return Color.lerp(
        const Color(0xFFFF9800),
        const Color(0xFFFFC107),
        ratio,
      )!;
    } else if (intensity <= 75) {
      final ratio = (intensity - 50) / 25;
      return Color.lerp(
        const Color(0xFFFFC107),
        const Color(0xFF66BB6A),
        ratio,
      )!;
    } else {
      final ratio = (intensity - 75) / 25;
      return Color.lerp(
        const Color(0xFF66BB6A),
        const Color(0xFF2E7D32),
        ratio,
      )!;
    }
  }

  /// Returns a textual label describing the intensity
  String _getIntensityLabel(int intensity) {
    if (intensity == 0) {
      return 'Not at all';
    }
    if (intensity < 25) {
      return 'Slightly';
    }
    if (intensity < 50) {
      return 'Somewhat';
    }
    if (intensity < 75) {
      return 'Quite a bit';
    }
    if (intensity < 100) {
      return 'Very much';
    }
    return 'Completely';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForIntensity(intensity);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with emoji, name, and optional remove button
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  moodName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onRemove,
                  tooltip: 'Remove mood',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Intensity label and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getIntensityLabel(intensity),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '$intensity%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Slider with gradient background
          Stack(
            children: [
              // Gradient track
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD32F2F),
                      Color(0xFFFF9800),
                      Color(0xFFFFC107),
                      Color(0xFF66BB6A),
                      Color(0xFF2E7D32),
                    ],
                    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
              ),
              // Slider overlay
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 8,
                  thumbShape: const RoundSliderThumbShape(),
                  overlayShape: 
                    const RoundSliderOverlayShape(overlayRadius: 16),
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: color,
                  overlayColor: color.withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: intensity.toDouble(),
                  max: 100,
                  divisions: 100,
                  label: '$intensity%',
                  onChanged: (value) {
                    onIntensityChanged(value.round());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

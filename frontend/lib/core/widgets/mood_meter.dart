import 'package:flutter/material.dart';

/// A visual mood meter widget that displays a slider for intensity (0-100%)
/// with a color gradient from red (0%) to green (100%)
class MoodMeter extends StatelessWidget {
  final String moodName;
  final String emoji;
  final int intensity; // 0-100
  final ValueChanged<int> onIntensityChanged;
  final VoidCallback? onRemove;

  const MoodMeter({
    super.key,
    required this.moodName,
    required this.emoji,
    required this.intensity,
    required this.onIntensityChanged,
    this.onRemove,
  });

  Color _getColorForIntensity(int intensity) {
    // Gradient from red (0) -> orange (25) -> yellow (50) -> light green (75) -> green (100)
    if (intensity <= 25) {
      // Red to Orange
      final ratio = intensity / 25;
      return Color.lerp(
        const Color(0xFFD32F2F), // Red
        const Color(0xFFFF9800), // Orange
        ratio,
      )!;
    } else if (intensity <= 50) {
      // Orange to Yellow
      final ratio = (intensity - 25) / 25;
      return Color.lerp(
        const Color(0xFFFF9800), // Orange
        const Color(0xFFFFC107), // Yellow
        ratio,
      )!;
    } else if (intensity <= 75) {
      // Yellow to Light Green
      final ratio = (intensity - 50) / 25;
      return Color.lerp(
        const Color(0xFFFFC107), // Yellow
        const Color(0xFF66BB6A), // Light Green
        ratio,
      )!;
    } else {
      // Light Green to Green
      final ratio = (intensity - 75) / 25;
      return Color.lerp(
        const Color(0xFF66BB6A), // Light Green
        const Color(0xFF2E7D32), // Green
        ratio,
      )!;
    }
  }

  String _getIntensityLabel(int intensity) {
    if (intensity == 0) return 'Not at all';
    if (intensity < 25) return 'Slightly';
    if (intensity < 50) return 'Somewhat';
    if (intensity < 75) return 'Quite a bit';
    if (intensity < 100) return 'Very much';
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
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with emoji, name, and remove button
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
          // Intensity label
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
              // Gradient background bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD32F2F), // Red
                      const Color(0xFFFF9800), // Orange
                      const Color(0xFFFFC107), // Yellow
                      const Color(0xFF66BB6A), // Light Green
                      const Color(0xFF2E7D32), // Green
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
              ),
              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 8,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: color,
                  overlayColor: color.withOpacity(0.2),
                ),
                child: Slider(
                  value: intensity.toDouble(),
                  min: 0,
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


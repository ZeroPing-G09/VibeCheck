import 'package:flutter/material.dart';

/// Stub implementation of SpotifyPlaylistEmbed for non-web platforms.
/// On non-web platforms, this widget shows a placeholder.
class SpotifyPlaylistEmbed extends StatelessWidget {
  final String playlistId;
  final double height;

  const SpotifyPlaylistEmbed({
    required this.playlistId,
    this.height = 380,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1DB954), // Spotify green
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.music_note,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Spotify embed is only available on web',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

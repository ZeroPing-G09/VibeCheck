import 'package:flutter/material.dart';

/// A widget that embeds a Spotify playlist player.
///
/// On web platforms, this would typically render the Spotify embed iframe.
/// On non-web platforms, this stub implementation shows a placeholder.
///
/// [playlistId] is the Spotify playlist ID to embed.
/// [height] defines the height of the widget (default is 380 pixels).
class SpotifyPlaylistEmbed extends StatelessWidget {

  /// Creates a [SpotifyPlaylistEmbed] for the given [playlistId] and 
  /// optional [height].
  const SpotifyPlaylistEmbed({
    required this.playlistId,
    this.height = 380,
    super.key,
  });
  /// The Spotify playlist ID to embed.
  final String playlistId;

  /// The height of the embed widget.
  final double height;

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

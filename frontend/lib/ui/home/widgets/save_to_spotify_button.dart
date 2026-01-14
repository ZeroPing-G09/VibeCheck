import 'package:flutter/material.dart';
import 'package:frontend/ui/home/dialogs/save_to_spotify_dialog.dart';

/// A button that allows users to save a playlist to Spotify.
class SaveToSpotifyButton extends StatelessWidget {
  /// Creates a [SaveToSpotifyButton].
  const SaveToSpotifyButton({
    required this.userId, required this.playlistId, super.key,
    this.exportedToSpotify,
    this.onSaved,
  });

  /// The Spotify user ID.
  final String userId;
  /// The playlist ID to be saved.
  final String playlistId;
  /// Indicates if the playlist has already been exported to Spotify.
  final bool? exportedToSpotify;
  /// Callback when the playlist is successfully saved to Spotify.
  final void Function(String?)? onSaved;

  void _showSaveDialog(BuildContext context) {
    showDialog<String?>(
      context: context,
      builder: (context) => SaveToSpotifyDialog(
        userId: userId,
        playlistId: playlistId,
      ),
    ).then((spotifyPlaylistId) {
      if (spotifyPlaylistId != null && onSaved != null) {
        onSaved!(spotifyPlaylistId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (exportedToSpotify ?? false) {
      return OutlinedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.check_circle, size: 18),
        label: const Text('Saved to Spotify'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey,
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _showSaveDialog(context),
      icon: const Icon(Icons.music_note, size: 18),
      label: const Text('Save to Spotify'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1DB954), // Exact Spotify Green
        foregroundColor: Colors.white,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../dialogs/save_to_spotify_dialog.dart';

class SaveToSpotifyButton extends StatelessWidget {
  final String userId;
  final String playlistId; // <--- FIXED: Now using int
  final bool? exportedToSpotify;

  const SaveToSpotifyButton({
    super.key,
    required this.userId,
    required this.playlistId,
    this.exportedToSpotify,
  });

  void _showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SaveToSpotifyDialog(
        userId: userId,
        playlistId: playlistId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (exportedToSpotify == true) {
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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/data/models/last_playlist.dart';
import 'package:frontend/ui/dashboard/viewmodel/dashboard_view_model.dart';
import 'package:frontend/ui/dashboard/widgets/spotify_playlist_embed_stub.dart'
    if (dart.library.html) 'package:frontend/ui/dashboard/widgets/spotify_playlist_embed.dart';

/// A widget that displays the last playlist section in the dashboard.
/// Handles loading, error, empty, and loaded states.
class LastPlaylistSection extends StatelessWidget {
  final PlaylistState playlistState;
  final LastPlaylist? playlist;
  final String? errorMessage;
  final VoidCallback? onCreatePlaylist;

  const LastPlaylistSection({
    required this.playlistState,
    this.playlist,
    this.errorMessage,
    this.onCreatePlaylist,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Latest Playlist',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (playlistState) {
      case PlaylistState.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );

      case PlaylistState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'No playlist created',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                if (errorMessage != null && errorMessage!.contains('Unauthorized'))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Please log in again',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        );

      case PlaylistState.empty:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.library_music_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nu ai încă un playlist generat.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                if (onCreatePlaylist != null)
                  ElevatedButton.icon(
                    onPressed: onCreatePlaylist,
                    icon: const Icon(Icons.add),
                    label: const Text('Creează unul nou!'),
                  ),
              ],
            ),
          ),
        );

      case PlaylistState.loaded:
        if (playlist == null) {
          return const SizedBox.shrink();
        }

        // Display playlist name
        final content = <Widget>[
          Text(
            playlist!.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
        ];

        // If we have a Spotify playlist ID, show the embed (web only)
        if (playlist!.hasSpotifyId && kIsWeb) {
          content.add(
            SpotifyPlaylistEmbed(playlistId: playlist!.playlistId!),
          );
        } else if (playlist!.hasSpotifyId && !kIsWeb) {
          // On mobile, show a button to open Spotify
          content.add(
            Container(
              height: 200,
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
                      'Playlist disponibil pe Spotify',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          // No Spotify ID - show info message
          content.add(
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Playlist saved locally'),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content,
        );
    }
  }
}

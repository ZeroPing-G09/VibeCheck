import 'package:flutter/material.dart';
import 'package:frontend/data/models/last_playlist.dart';
import 'package:frontend/ui/dashboard/viewmodel/dashboard_view_model.dart';
import 'package:frontend/ui/dashboard/widgets/playlist_songs_dialog.dart';

/// A widget that displays the last playlist section in the dashboard.
/// Handles loading, error, empty, and loaded states.
class LastPlaylistSection extends StatelessWidget {
  final PlaylistState playlistState;
  final LastPlaylist? playlist;
  final String? errorMessage;
  final VoidCallback? onCreatePlaylist;
  final bool isGeneratingPlaylist;

  const LastPlaylistSection({
    required this.playlistState,
    this.playlist,
    this.errorMessage,
    this.onCreatePlaylist,
    this.isGeneratingPlaylist = false,
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
                const SizedBox(height: 8),
                Text(
                  'Something went wrong while generating your playlist.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
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
                if (onCreatePlaylist != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: isGeneratingPlaylist ? null : onCreatePlaylist,
                    icon: isGeneratingPlaylist
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      isGeneratingPlaylist ? 'Retrying...' : 'Try again',
                    ),
                  ),
                ],
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
                if (isGeneratingPlaylist)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  )
                else
                  Icon(
                    Icons.library_music_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                const SizedBox(height: 16),
                Text(
                  isGeneratingPlaylist
                      ? 'Generating your playlist...'
                      : 'You don\'t have any playlists generated yet.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                if (onCreatePlaylist != null)
                  ElevatedButton.icon(
                    onPressed: isGeneratingPlaylist ? null : onCreatePlaylist,
                    icon: isGeneratingPlaylist
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.add),
                    label: Text(
                      isGeneratingPlaylist ? 'Generating...' : 'Create a new one!',
                    ),
                  ),
              ],
            ),
          ),
        );

      case PlaylistState.loaded:
        if (playlist == null) {
          return const SizedBox.shrink();
        }

        // Display playlist name (clickable) and generate button
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => PlaylistSongsDialog(
                    playlistName: playlist!.name,
                    songs: playlist!.songs,
                  ),
                );
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      playlist!.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            if (onCreatePlaylist != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: isGeneratingPlaylist ? null : onCreatePlaylist,
                icon: isGeneratingPlaylist
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.add),
                label: Text(
                  isGeneratingPlaylist ? 'Generating...' : 'Generate new playlist',
                ),
              ),
            ],
          ],
        );
    }
  }
}

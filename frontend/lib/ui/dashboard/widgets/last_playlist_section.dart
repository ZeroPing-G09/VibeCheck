import 'package:flutter/material.dart';
import 'package:frontend/data/models/last_playlist.dart';
import 'package:frontend/ui/dashboard/viewmodel/dashboard_view_model.dart';
import 'package:frontend/ui/dashboard/widgets/playlist_songs_dialog.dart';
import 'package:frontend/ui/dashboard/widgets/spotify_playlist_embed.dart';
import 'package:frontend/ui/home/widgets/save_to_spotify_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Needed for User ID
import 'package:url_launcher/url_launcher.dart';

// Make sure to import your button
// Adjust path if you saved it elsewhere

class LastPlaylistSection extends StatelessWidget {
  final PlaylistState playlistState;
  final LastPlaylist? playlist;
  final String? errorMessage;
  final VoidCallback? onCreatePlaylist;
  final bool isGeneratingPlaylist;
  final Function(String?)? onSpotifyPlaylistSaved; // Callback when Spotify playlist is saved

  const LastPlaylistSection({
    required this.playlistState,
    this.playlist,
    this.errorMessage,
    this.onCreatePlaylist,
    this.isGeneratingPlaylist = false,
    this.onSpotifyPlaylistSaved,
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
        // ... (Error state code remains the same) ...
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
                // ... rest of error content
                if (onCreatePlaylist != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: isGeneratingPlaylist ? null : onCreatePlaylist,
                    icon: isGeneratingPlaylist
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
        // ... (Empty state code remains the same) ...
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
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
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

        // Get Current User ID safely
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. The Clickable Playlist Name
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
            
            const SizedBox(height: 16),

            // 2. THE SAVE BUTTON (Inserted Here)
            if (currentUserId != null)
              Container(
                width: double.infinity, // Make button stretch full width
                margin: const EdgeInsets.only(bottom: 8),
                child: SaveToSpotifyButton(
                  userId: currentUserId,
                  playlistId: playlist!.playlistId!, // Ensure this ID maps to String
                  exportedToSpotify: false, // Defaulting to false as we removed backend check
                  onSaved: onSpotifyPlaylistSaved,
                ),
              ),

            // 2.5. PLAY IN SPOTIFY BUTTON (if playlist was saved to Spotify)
            if (playlist!.spotifyPlaylistId != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      // Try deep link first (spotify:playlist:ID) - opens Spotify app if installed
                      final deepLink = Uri.parse('spotify:playlist:${playlist!.spotifyPlaylistId}');
                      
                      try {
                        // Try to launch directly - LaunchMode.platformDefault will use the best available option
                        await launchUrl(deepLink, mode: LaunchMode.platformDefault);
                        return; // Success, exit early
                      } catch (e) {
                        // Deep link failed (Spotify app not installed), try web URL
                        debugPrint('Deep link failed: $e, trying web URL');
                      }
                      
                      // Fallback to web URL - opens in browser (or Spotify app if it handles web URLs)
                      final webUrl = Uri.parse('https://open.spotify.com/playlist/${playlist!.spotifyPlaylistId}');
                      await launchUrl(webUrl, mode: LaunchMode.platformDefault);
                    } catch (e) {
                      // Show error message if both attempts fail
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not open Spotify. Error: ${e.toString()}'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                      debugPrint('Error opening Spotify: $e');
                    }
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play in Spotify'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // SPOTIFY PLAYER (30-second preview)
              SpotifyPlaylistEmbed(
                playlistId: playlist!.spotifyPlaylistId!,
                height: 380, // Compact size
              ),
            ],

            // 3. The Generate New Button
            if (onCreatePlaylist != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon( // Changed to Outlined for visual hierarchy
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
                    isGeneratingPlaylist ? 'Generating...' : 'Generate new playlist',
                  ),
                ),
              ),
            ],
          ],
        );
    }
  }
}
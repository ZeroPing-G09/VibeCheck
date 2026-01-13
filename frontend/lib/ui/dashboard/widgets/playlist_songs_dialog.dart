import 'package:flutter/material.dart';
import 'package:frontend/data/models/song.dart';
import 'package:url_launcher/url_launcher.dart';

/// A dialog that displays the list of songs in a given playlist.
///
/// Shows the [playlistName] as the title and lists all [songs] in a 
/// scrollable view.
class PlaylistSongsDialog extends StatelessWidget {

  /// Creates a [PlaylistSongsDialog] with the given [playlistName] and [songs].
  const PlaylistSongsDialog({
    required this.playlistName,
    required this.songs,
    super.key,
  });
  /// The name of the playlist being displayed.
  final String playlistName;

  /// The list of songs contained in the playlist.
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      playlistName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Songs list
            Flexible(
              child: songs.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No songs in this playlist',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: InkWell(
                            onTap: () async {
                              final uri = Uri.parse(song.url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: 
                                LaunchMode.externalApplication);
                              }
                            },
                            child: Text(
                              song.name,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          subtitle: Text(song.artistName),
                          trailing: IconButton(
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () async {
                              final uri = Uri.parse(song.url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: 
                                LaunchMode.externalApplication);
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

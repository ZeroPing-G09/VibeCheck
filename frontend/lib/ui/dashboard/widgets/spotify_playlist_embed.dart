import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'spotify_playlist_embed_web_stub.dart'
    if (dart.library.html) 'spotify_playlist_embed_web.dart' as web;
import 'spotify_webview_player.dart';

/// A widget that displays a Spotify playlist embed.
/// On web: shows an iframe embed
/// On mobile: shows WebView with Spotify player embedded
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
    if (kIsWeb) {
      // On web, use the web implementation with iframe
      return web.createWebSpotifyEmbed(playlistId: playlistId, height: height);
    } else {
      // On mobile, use WebView to embed the Spotify player
      return SpotifyWebViewPlayer(
        spotifyPlaylistId: playlistId,
        height: height,
      );
    }
  }
}

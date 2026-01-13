import 'package:flutter/material.dart';

/// Stub factory function for non-web platforms
/// Returns a mobile implementation
Widget createWebSpotifyEmbed({
  required String playlistId,
  required double height,
}) {
  // On non-web platforms, return mobile implementation
  return _MobileSpotifyPlaylistEmbed(
    playlistId: playlistId,
    height: height,
  );
}

/// Mobile implementation - shows button to open Spotify
class _MobileSpotifyPlaylistEmbed extends StatelessWidget {

  const _MobileSpotifyPlaylistEmbed({
    required this.playlistId,
    required this.height,
  });
  final String playlistId;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: const Center(
        child: Text('Spotify embed available on web'),
      ),
    );
  }
}

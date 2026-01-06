import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// Factory function that creates the web implementation with iframe
Widget createWebSpotifyEmbed({
  required String playlistId,
  required double height,
}) {
  return _WebSpotifyPlaylistEmbed(
    playlistId: playlistId,
    height: height,
  );
}

/// Web implementation of Spotify playlist embed using iframe
class _WebSpotifyPlaylistEmbed extends StatefulWidget {
  final String playlistId;
  final double height;

  const _WebSpotifyPlaylistEmbed({
    required this.playlistId,
    required this.height,
  });

  @override
  State<_WebSpotifyPlaylistEmbed> createState() => _WebSpotifyPlaylistEmbedState();
}

class _WebSpotifyPlaylistEmbedState extends State<_WebSpotifyPlaylistEmbed> {
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'spotify-embed-${widget.playlistId}';

    // Register the view factory for this specific playlist
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = 'https://open.spotify.com/embed/playlist/${widget.playlistId}?utm_source=generator'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '${widget.height.toInt()}px'
          ..style.borderRadius = '12px'
          ..allow = 'encrypted-media';
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: HtmlElementView(viewType: _viewType),
      ),
    );
  }
}


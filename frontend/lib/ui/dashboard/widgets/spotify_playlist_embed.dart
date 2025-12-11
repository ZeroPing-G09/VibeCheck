import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// A widget that displays a Spotify playlist embed.
/// Only works on Flutter Web.
class SpotifyPlaylistEmbed extends StatefulWidget {
  final String playlistId;
  final double height;

  const SpotifyPlaylistEmbed({
    required this.playlistId,
    this.height = 380,
    super.key,
  });

  @override
  State<SpotifyPlaylistEmbed> createState() => _SpotifyPlaylistEmbedState();
}

class _SpotifyPlaylistEmbedState extends State<SpotifyPlaylistEmbed> {
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
          ..src =
              'https://open.spotify.com/embed/playlist/${widget.playlistId}'
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
    if (!kIsWeb) {
      // On non-web platforms, show a placeholder
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Spotify embed is only available on web'),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: HtmlElementView(viewType: _viewType),
      ),
    );
  }
}

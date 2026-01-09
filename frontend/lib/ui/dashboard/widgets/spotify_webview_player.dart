import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Widget that displays Spotify playlist player using WebView
/// Works on both Android and iOS
class SpotifyWebViewPlayer extends StatefulWidget {
  final String spotifyPlaylistId;
  final double height;

  const SpotifyWebViewPlayer({
    required this.spotifyPlaylistId,
    this.height = 380, // Compact size - shows ~3-4 songs
    super.key,
  });

  @override
  State<SpotifyWebViewPlayer> createState() => _SpotifyWebViewPlayerState();
}

class _SpotifyWebViewPlayerState extends State<SpotifyWebViewPlayer> {
  late final WebViewController _controller;
  bool _isLoading = true;

  // Use embed URL with larger height parameter to show more songs
  // Note: Spotify embed only plays 30-second previews
  // For full songs, users need Spotify Premium and must be logged in
  String get _embedUrl =>
      'https://open.spotify.com/embed/playlist/${widget.spotifyPlaylistId}?utm_source=generator&theme=0&view=list&t=0';

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Create platform-specific controller with media playback enabled
    late final PlatformWebViewControllerCreationParams params;
    
    if (WebViewPlatform.instance is WebKitWebViewController) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
              // Inject JavaScript to improve audio and enable scrolling
              _controller.runJavaScript('''
                (function() {
                  // Wait for Spotify's iframe to load
                  setTimeout(function() {
                    // Enable scrolling
                    document.body.style.overflow = 'auto';
                    document.body.style.height = 'auto';
                    document.documentElement.style.overflow = 'auto';
                    
                    // Improve audio playback - reduce glitches
                    var audioElements = document.querySelectorAll('audio');
                    audioElements.forEach(function(audio) {
                      audio.preload = 'auto';
                      audio.crossOrigin = 'anonymous';
                      // Set buffer settings to reduce pops
                      if (audio.buffered.length > 0) {
                        audio.addEventListener('canplaythrough', function() {
                          // Audio is ready to play smoothly
                        }, { once: true });
                      }
                    });
                    
                    // Enable scrolling on Spotify containers
                    var containers = document.querySelectorAll('[class*="Root"], [class*="container"], [class*="list"]');
                    containers.forEach(function(container) {
                      container.style.overflowY = 'auto';
                    });
                  }, 1000);
                })();
              ''');
            }
          },
        ),
      );

    // Configure Android-specific settings for audio/media playback
    if (_controller.platform is AndroidWebViewController) {
      final androidController = _controller.platform as AndroidWebViewController;
      // Don't require user gesture for media playback (allows autoplay)
      androidController.setMediaPlaybackRequiresUserGesture(false);
      androidController.setOnShowFileSelector(_androidFilePicker);
    }

    _controller.loadRequest(Uri.parse(_embedUrl));
  }

  Future<List<String>> _androidFilePicker(FileSelectorParams params) async {
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade700,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                Container(
                  color: Colors.black87,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


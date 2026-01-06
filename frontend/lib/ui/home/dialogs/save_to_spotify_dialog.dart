import 'package:flutter/material.dart';
import 'package:frontend/data/services/playlist_service.dart';
import 'package:frontend/di/locator.dart';
import 'package:provider/provider.dart';

class SaveToSpotifyDialog extends StatefulWidget {
  final String userId;
  final String playlistId;

  const SaveToSpotifyDialog({
    super.key,
    required this.userId,
    required this.playlistId,
  });

  @override
  State<SaveToSpotifyDialog> createState() => _SaveToSpotifyDialogState();
}

class _SaveToSpotifyDialogState extends State<SaveToSpotifyDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveToSpotify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final playlistService = locator<PlaylistService>();

      final response = await playlistService.savePlaylistToSpotify(
        playlistId: widget.playlistId,
        spotifyPlaylistName: _nameController.text.trim(),
      );

      if (mounted) {
        // Return the Spotify playlist ID to the caller
        Navigator.of(context).pop(response['spotifyPlaylistId'] as String?);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playlist saved to Spotify successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save to Spotify'),
      // FIX IS HERE: Wrapped Column in SingleChildScrollView
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter a name for your new Spotify playlist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Playlist Name',
                  hintText: 'e.g., My Vibe Mix',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                autofocus: true, // This triggers the keyboard
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveToSpotify,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1DB954), // Spotify Green
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../../data/services/playlist_service.dart';

class SaveToSpotifyDialog extends StatefulWidget {
  final int userId;
  final int playlistId;

  const SaveToSpotifyDialog({
    super.key,
    required this.userId,
    required this.playlistId,
  });

  @override
  State<SaveToSpotifyDialog> createState() => _SaveToSpotifyDialogState();
}

class _SaveToSpotifyDialogState extends State<SaveToSpotifyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _playlistNameController = TextEditingController();
  final _playlistService = PlaylistService();
  bool _isLoading = false;

  @override
  void dispose() {
    _playlistNameController.dispose();
    super.dispose();
  }

  Future<void> _saveToSpotify() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _playlistService.savePlaylistToSpotify(
        userId: widget.userId,
        playlistId: widget.playlistId,
        spotifyPlaylistName: _playlistNameController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playlist saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
      title: const Row(
        children: [
          Icon(Icons.music_note, color: Colors.green),
          SizedBox(width: 8),
          Text('Save to Spotify'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Do you want to save this playlist to your Spotify account?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _playlistNameController,
              decoration: const InputDecoration(
                labelText: 'Playlist Name',
                hintText: 'Enter playlist name',
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a playlist name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveToSpotify,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}


# Save Playlist to Spotify - Integration Guide

## Backend Implementation

### New Files Created:
1. **Playlist Entity** (`entity/Playlist.java`) - Stores playlist data with Spotify export status
2. **PlaylistRepository** (`repository/PlaylistRepository.java`) - Data access layer for playlists
3. **SpotifyService** (`service/SpotifyService.java`) - Handles Spotify API interactions
4. **PlaylistService** (`service/PlaylistService.java`) - Business logic for saving playlists
5. **SavePlaylistToSpotifyRequest DTO** (`dto/SavePlaylistToSpotifyRequest.java`) - Request DTO
6. **SpotifyUriUtil** (`util/SpotifyUriUtil.java`) - Utility for converting Spotify URLs to URIs

### Modified Files:
1. **User Entity** - Added `spotifyAccessToken` field
2. **UserController** - Added `POST /users/playlist/save` endpoint

### Database Schema Changes:
- New `Playlists` table with fields:
  - `id` (Primary Key)
  - `name` (String)
  - `user_id` (Foreign Key to Users)
  - `track_uris` (List of Spotify track URIs)
  - `exported_to_spotify` (Boolean)
  - `spotify_playlist_id` (String, nullable)
  - `created_at` (Timestamp)

- New `PlaylistTracks` table (for @ElementCollection):
  - `playlist_id` (Foreign Key)
  - `track_uri` (String)

- Updated `Users` table:
  - Added `spotify_access_token` (String, nullable)

### Endpoint Details:
- **URL**: `POST /users/playlist/save`
- **Headers**: 
  - `Content-Type: application/json`
  - `X-User-Id: {userId}` (temporary - should be extracted from JWT in production)
- **Request Body**:
```json
{
  "playlistId": 1,
  "spotifyPlaylistName": "My New Playlist"
}
```
- **Response**:
```json
{
  "success": true,
  "message": "Playlist saved to Spotify successfully."
}
```

## Frontend Implementation

### New Files Created:
1. **PlaylistService** (`lib/data/services/playlist_service.dart`) - API service for playlist operations
2. **SaveToSpotifyDialog** (`lib/ui/home/dialogs/save_to_spotify_dialog.dart`) - Dialog for saving playlist
3. **SaveToSpotifyButton** (`lib/ui/home/widgets/save_to_spotify_button.dart`) - Reusable button widget

### Integration Example:

To add the "Save to Spotify" button to your playlist UI:

```dart
import 'package:your_app/ui/home/widgets/save_to_spotify_button.dart';

// In your playlist widget:
SaveToSpotifyButton(
  userId: currentUser.id,
  playlistId: playlist.id,
  exportedToSpotify: playlist.exportedToSpotify,
)
```

### Usage Flow:
1. User clicks "Save to Spotify" button
2. Dialog appears asking for playlist name
3. User enters name and clicks "Save"
4. Loading indicator shows while saving
5. Success/Error snackbar displays result

## Important Notes:

1. **Authentication**: Currently uses `X-User-Id` header. In production, extract `userId` and `spotifyAccessToken` from JWT token.

2. **Spotify Access Token**: Users must have their `spotifyAccessToken` stored in the database. You'll need to implement OAuth flow to obtain and store this token.

3. **Playlist Creation**: Before saving to Spotify, playlists must be created and stored in the database with `trackUris` populated. The track URIs should be in format: `spotify:track:{trackId}`.

4. **Error Handling**: The endpoint handles:
   - Missing user/playlist
   - Already exported playlists
   - Missing Spotify access token
   - Empty playlists
   - Spotify API errors

5. **Database Migration**: Run the application to auto-create the new tables (Hibernate DDL auto-update is enabled).

## Next Steps:

1. Implement JWT authentication to extract userId and spotifyAccessToken from tokens
2. Implement Spotify OAuth flow to obtain and store access tokens
3. Create endpoint to save generated playlists to database with track URIs
4. Integrate the SaveToSpotifyButton in your playlist display UI
5. Test the complete flow end-to-end


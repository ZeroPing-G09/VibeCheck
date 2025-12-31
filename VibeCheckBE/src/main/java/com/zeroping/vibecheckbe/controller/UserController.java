package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.SavePlaylistToSpotifyRequest;
import com.zeroping.vibecheckbe.service.PlaylistService;
import com.zeroping.vibecheckbe.dto.LastPlaylistResponseDTO;
import com.zeroping.vibecheckbe.dto.MoodHistoryDTO;
import com.zeroping.vibecheckbe.dto.UserDTO;
import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.dto.UserUpdateDTO;
import com.zeroping.vibecheckbe.exception.playlist.PlaylistNotFoundException;
import com.zeroping.vibecheckbe.service.MoodService;
import com.zeroping.vibecheckbe.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService userService;
    private final PlaylistService playlistService;
    private final MoodService moodService;

    // Resolved Conflict: Injected both PlaylistService and MoodService
    public UserController(UserService userService, PlaylistService playlistService, MoodService moodService) {
        this.userService = userService;
        this.playlistService = playlistService;
        this.moodService = moodService;
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getUser(@PathVariable UUID id) {
        UserDTO response = userService.getUserById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/by-email")
    public ResponseEntity<UserDTO> getUserByEmail(@RequestParam String email) {
        UserDTO response = userService.getUserByEmail(email);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(
            @PathVariable UUID id,
            @RequestBody UserUpdateDTO updateDTO) {
        // Verify the authenticated user matches the requested user ID
        String authenticatedUserId = SecurityContextHolder.getContext().getAuthentication().getName();
        if (!authenticatedUserId.equals(id.toString())) {
            return ResponseEntity.status(org.springframework.http.HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "You can only update your own profile"));
        }

        UserDTO updatedUser = userService.updateUser(id, updateDTO);
        return ResponseEntity.ok(updatedUser);
    }

    @PostMapping("/preferences")
    public ResponseEntity<Map<String, Object>> savePreferences(@RequestBody UserPreferencesDTO preferences) {
        String userIdString = SecurityContextHolder.getContext().getAuthentication().getName();
        UUID userId = UUID.fromString(userIdString);

        userService.updateUserPreferences(userId, preferences);
        return ResponseEntity.ok()
                .body(Map.of("success", true, "message", "Preferences updated successfully."));
    }

    @GetMapping("/{id}/moods")
    public ResponseEntity<?> getUserMoodHistory(@PathVariable UUID id) {
        // Verify the authenticated user matches the requested user ID
        String authenticatedUserId = SecurityContextHolder.getContext().getAuthentication().getName();
        if (!authenticatedUserId.equals(id.toString())) {
            return ResponseEntity.status(org.springframework.http.HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "You can only access your own mood history"));
        }

        try {
            List<MoodHistoryDTO> moodHistory = moodService.getUserMoodHistory(id);
            if (moodHistory.isEmpty()) {
                return ResponseEntity.status(org.springframework.http.HttpStatus.NOT_FOUND)
                        .body(Map.of("error", "No mood history found for this user"));
            }
            return ResponseEntity.ok(moodHistory);
        } catch (com.zeroping.vibecheckbe.exception.user.UserNotFoundException e) {
            return ResponseEntity.status(org.springframework.http.HttpStatus.NOT_FOUND)
                    .body(Map.of("error", "User not found"));
        }
    }

    /**
     * Get the most recent playlist for the authenticated user.
     * Optionally filters by mood if provided.
     * Returns 404 if the user has no playlists (matching the mood if specified).
     */
    @GetMapping("/last-playlist")
    public ResponseEntity<LastPlaylistResponseDTO> getLastPlaylist(
            @RequestParam(required = false) String mood) {
        String userIdString = SecurityContextHolder.getContext().getAuthentication().getName();
        UUID userId = UUID.fromString(userIdString);

        Optional<LastPlaylistResponseDTO> playlist;
        if (mood != null && !mood.trim().isEmpty()) {
            playlist = userService.getLastPlaylistByMood(userId, mood.trim());
        } else {
            playlist = userService.getLastPlaylist(userId);
        }

        return playlist
                .map(ResponseEntity::ok)
                .orElseThrow(() -> new PlaylistNotFoundException("No playlist found for user"));
    }

    @PostMapping("/playlist/save")
    public ResponseEntity<Map<String, Object>> savePlaylistToSpotify(
            @RequestHeader(value = "X-User-Id", required = false) Long userId,
            @RequestBody SavePlaylistToSpotifyRequest request) {
        
        // For now, we'll get userId from header. In production, extract from JWT
        if (userId == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "message", "User ID is required in X-User-Id header."));
        }

        if (request.getPlaylistId() == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "message", "Playlist ID is required."));
        }

        if (request.getSpotifyPlaylistName() == null || request.getSpotifyPlaylistName().trim().isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "message", "Spotify playlist name is required."));
        }

        try {
            playlistService.savePlaylistToSpotify(userId, request);
            return ResponseEntity.ok()
                    .body(Map.of("success", true, "message", "Playlist saved to Spotify successfully."));
        } catch (IllegalStateException e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "message", e.getMessage()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "message", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body(Map.of("success", false, "message", "Failed to save playlist to Spotify: " + e.getMessage()));
        }
    }
}
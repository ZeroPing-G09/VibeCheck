package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.PlaylistDTO;
import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.service.PlaylistService;
import com.zeroping.vibecheckbe.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService userService;
    private final PlaylistService playlistService;
    public UserController(UserService userService, PlaylistService playlistService) {
        this.userService = userService;
        this.playlistService = playlistService;
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getUser(@PathVariable UUID id) {
        Map<String, Object> response = userService.getUserById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/by-email")
    public ResponseEntity<Map<String, Object>> getUserByEmail(@RequestParam String email) {
        Map<String, Object> response = userService.getUserByEmail(email);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateUser(@PathVariable UUID id, @RequestBody Map<String, Object> payload) {
        Map<String, Object> response = userService.updateUser(id, payload);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/preferences")
    public ResponseEntity<Map<String, Object>> savePreferences(@RequestBody UserPreferencesDTO preferences) {
        // Check if user id is present
        if (preferences.getUserId() == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "message", "User ID is required."));
        }

        try {
            userService.updateUserPreferences(preferences);
            return ResponseEntity.ok()
                    .body(Map.of("success", true, "message", "Preferences updated successfully."));
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body(Map.of("success", false, "message", "Internal error updating preferences."));
        }
    }

    // Get all distinct moods of authenticated user, sorted by createdAt ascending
    @GetMapping("/moods")
    public List<String> getUserMoods() {
        String userIdString = SecurityContextHolder.getContext().getAuthentication().getName();
        UUID userId = UUID.fromString(userIdString);
        return playlistService.getUserMoods(userId);
    }

    // Get total number of playlists of authenticated user
    @GetMapping("/playlist-count")
    public Map<String, Long> getUserPlaylistCount() {
        String userIdString = SecurityContextHolder.getContext().getAuthentication().getName();
        UUID userId = UUID.fromString(userIdString);
        long count = playlistService.getNumberOfPlaylists(userId);
        return Map.of("playlistCount", count);
    }

    // Get all the user's playlists
    @GetMapping("/{userId}/playlists")
    public List<PlaylistDTO> getUserPlaylists(@PathVariable UUID userId) {
        return playlistService.getUserPlaylists(userId);
    }

    // Get the latest playlist for the user
    @GetMapping("/{userId}/last-playlist")
    public PlaylistDTO getLastPlaylist(@PathVariable UUID userId) {
        return playlistService.getLastPlaylist(userId);
    }
}

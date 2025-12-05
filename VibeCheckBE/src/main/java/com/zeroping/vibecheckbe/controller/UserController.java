package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.LastPlaylistResponseDTO;
import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.exception.playlist.PlaylistNotFoundException;
import com.zeroping.vibecheckbe.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
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

    @PostMapping("/preferences")
    public ResponseEntity<Map<String, Object>> savePreferences(@RequestBody UserPreferencesDTO preferences) {
        String userIdString = SecurityContextHolder.getContext().getAuthentication().getName();
        UUID userId = UUID.fromString(userIdString);

        try {
            userService.updateUserPreferences(userId, preferences);
            return ResponseEntity.ok()
                    .body(Map.of("success", true, "message", "Preferences updated successfully."));
        } catch (Exception e) {
            return ResponseEntity.internalServerError()
                    .body(Map.of("success", false, "message", "Internal error updating preferences."));
        }
    }

    /**
     * Get the most recent playlist for the authenticated user.
     * Returns 404 if the user has no playlists.
     */
    @GetMapping("/last-playlist")
    public ResponseEntity<LastPlaylistResponseDTO> getLastPlaylist() {
        String userIdString = SecurityContextHolder.getContext().getAuthentication().getName();
        UUID userId = UUID.fromString(userIdString);

        return userService.getLastPlaylist(userId)
                .map(ResponseEntity::ok)
                .orElseThrow(() -> new PlaylistNotFoundException("No playlist found for user"));
    }
}

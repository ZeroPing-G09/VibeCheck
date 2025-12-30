package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.SavePlaylistToSpotifyRequest;
import com.zeroping.vibecheckbe.service.PlaylistService;
import com.zeroping.vibecheckbe.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

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
    public ResponseEntity<Map<String, Object>> getUser(@PathVariable Long id) {
        Map<String, Object> response = userService.getUserById(id);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/by-email")
    public ResponseEntity<Map<String, Object>> getUserByEmail(@RequestParam String email) {
        Map<String, Object> response = userService.getUserByEmail(email);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateUser(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        Map<String, Object> response = userService.updateUser(id, payload);
        return ResponseEntity.ok(response);
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

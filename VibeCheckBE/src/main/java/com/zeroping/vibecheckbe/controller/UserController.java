package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.PlaylistDTO;
import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.dto.UserUpdateDTO;
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
    public ResponseEntity<?> updateUser(
            @PathVariable UUID id,
            @RequestBody UserUpdateDTO payload) {
        return ResponseEntity.ok(userService.updateUser(id, payload));
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
}

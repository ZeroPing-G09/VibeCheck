package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.MoodHistoryDTO;
import com.zeroping.vibecheckbe.dto.UserDTO;
import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.dto.UserUpdateDTO;
import com.zeroping.vibecheckbe.service.MoodService;
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
    private final MoodService moodService;

    public UserController(UserService userService, MoodService moodService) {
        this.userService = userService;
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
}

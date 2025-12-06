package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.service.MoodService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/moods")
public class MoodController {

    private final MoodService moodService;

    public MoodController(MoodService moodService) {
        System.out.println("MoodController: Constructor called, moodService = " + (moodService != null ? "not null" : "NULL"));
        this.moodService = moodService;
    }

    @GetMapping("/test")
    public ResponseEntity<Map<String, String>> test() {
        System.out.println("MoodController.test: Test endpoint called");
        Map<String, String> response = new HashMap<>();
        response.put("status", "ok");
        response.put("message", "MoodController is working");
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getAllMoods() {
        try {
            System.out.println("MoodController.getAllMoods: Request received");
            List<Map<String, Object>> moods = moodService.getAllMoods();
            System.out.println("MoodController.getAllMoods: Returning " + moods.size() + " moods");
            return ResponseEntity.ok(moods);
        } catch (Exception e) {
            System.err.println("MoodController.getAllMoods: Exception caught: " + e.getMessage());
            e.printStackTrace();
            throw e; // Re-throw to let exception handler deal with it
        }
    }

    @PostMapping("/entries")
    public ResponseEntity<Map<String, Object>> createMoodEntry(
            @RequestBody Map<String, Object> payload) {
        UUID userId = UUID.fromString(payload.get("userId").toString());
        Long moodId = Long.valueOf(payload.get("moodId").toString());
        Map<String, Object> response = moodService.createMoodEntry(userId, moodId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/entries/user/{userId}")
    public ResponseEntity<List<Map<String, Object>>> getUserMoodEntries(@PathVariable UUID userId) {
        List<Map<String, Object>> entries = moodService.getUserMoodEntries(userId);
        return ResponseEntity.ok(entries);
    }
}


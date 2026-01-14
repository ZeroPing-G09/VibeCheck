package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.CreateMoodEntryDTO;
import com.zeroping.vibecheckbe.dto.CreateBatchMoodEntriesDTO;
import com.zeroping.vibecheckbe.dto.MoodEntryResponseDTO;
import com.zeroping.vibecheckbe.service.MoodService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

// Controller for handling mood-related endpoints
@RestController
@RequestMapping("/moods")
public class MoodController {
    // Logger for debugging
    private static final Logger log = LoggerFactory.getLogger(MoodController.class);

    // Dependency injection of MoodService
    private final MoodService moodService;

    public MoodController(MoodService moodService) {
        log.debug("MoodController initialized");
        this.moodService = moodService;
    }

    // Endpoint to get all moods
    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getAllMoods() {
        log.debug("getAllMoods: Request received");
        List<Map<String, Object>> moods = moodService.getAllMoods();
        log.debug("getAllMoods: Returning {} moods", moods.size());
        return ResponseEntity.ok(moods);
    }

    // Endpoint to create a single mood entry
    @PostMapping("/entries")
    public ResponseEntity<MoodEntryResponseDTO> createMoodEntry(
            @Valid @RequestBody CreateMoodEntryDTO dto) {
        log.debug("createMoodEntry: userId={}, moodId={}, intensity={}", 
                dto.userId(), dto.moodId(), dto.intensity());
        
        MoodEntryResponseDTO response = moodService.createMoodEntry(dto);
        return ResponseEntity.ok(response);
    }

    // Endpoint to create multiple mood entries in batch
    @PostMapping("/entries/batch")
    public ResponseEntity<List<MoodEntryResponseDTO>> createMultipleMoodEntries(
            @Valid @RequestBody CreateBatchMoodEntriesDTO dto) {
        log.debug("createMultipleMoodEntries: userId={}, entries={}", 
                dto.userId(), dto.moodEntries().size());
        
        List<MoodEntryResponseDTO> responses = moodService.createMultipleMoodEntries(dto);
        return ResponseEntity.ok(responses);
    }

    // Endpoint to get mood entries for a specific user
    @GetMapping("/entries/user/{userId}")
    public ResponseEntity<List<MoodEntryResponseDTO>> getUserMoodEntries(@PathVariable UUID userId) {
        log.debug("getUserMoodEntries: userId={}", userId);
        List<MoodEntryResponseDTO> entries = moodService.getUserMoodEntries(userId);
        return ResponseEntity.ok(entries);
    }
}

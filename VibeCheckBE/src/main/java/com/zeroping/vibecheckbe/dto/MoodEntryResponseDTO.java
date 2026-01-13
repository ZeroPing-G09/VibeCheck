package com.zeroping.vibecheckbe.dto;

import java.time.LocalDateTime;
import java.util.UUID;

// DTO for returning mood entry details
public record MoodEntryResponseDTO(
        Long id,
        UUID userId,
        Long moodId,
        String moodName,
        String moodEmoji,
        Integer intensity,
        String notes,
        LocalDateTime createdAt
) {}


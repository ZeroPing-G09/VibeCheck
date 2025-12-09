package com.zeroping.vibecheckbe.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record CreateMoodEntryDTO(
        @NotNull(message = "userId is required")
        UUID userId,

        @NotNull(message = "moodId is required")
        Long moodId,

        @Min(value = 0, message = "intensity must be between 0 and 100")
        @Max(value = 100, message = "intensity must be between 0 and 100")
        Integer intensity,

        String notes
) {
    public CreateMoodEntryDTO {
        // Default intensity to 50 if not provided
        if (intensity == null) {
            intensity = 50;
        }
    }
}


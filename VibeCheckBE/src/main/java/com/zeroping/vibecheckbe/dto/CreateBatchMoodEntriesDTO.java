package com.zeroping.vibecheckbe.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;
import java.util.UUID;

// DTO for creating batch mood entries
public record CreateBatchMoodEntriesDTO(
        @NotNull(message = "userId is required")
        UUID userId,

        @NotEmpty(message = "moodEntries cannot be empty")
        @Valid
        List<BatchMoodEntryDTO> moodEntries,

        String generalNotes
) {}


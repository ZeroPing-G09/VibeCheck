package com.zeroping.vibecheckbe.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MoodHistoryDTO {
    private Long id;
    private UUID userId;
    private Long moodId;
    private String moodName;
    private String moodEmoji;
    private Integer intensity;
    private String notes;
    private LocalDateTime createdAt;
    private List<PlaylistDTO> playlists;
}


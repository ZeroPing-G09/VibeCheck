package com.zeroping.vibecheckbe.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.Instant;
import java.util.UUID;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PlaylistDTO {
    private Long id;
    private String name;
    private String mood;
    private UUID userId;
    private Instant createdAt;
}
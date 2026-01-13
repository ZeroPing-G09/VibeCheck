package com.zeroping.vibecheckbe.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.Set;

// DTO for returning the last created playlist details
@Data
@AllArgsConstructor
@NoArgsConstructor
public class LastPlaylistResponseDTO {
    private String playlistId;        // Database ID (as String)
    private String name;              // Playlist name
    private Instant createdAt;        // Creation timestamp
    private Set<SongDTO> songs;       // Songs in the playlist
}

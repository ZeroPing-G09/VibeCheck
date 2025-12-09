package com.zeroping.vibecheckbe.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

/**
 * DTO for the last playlist endpoint response.
 * Returns the minimal information needed to display the playlist.
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class LastPlaylistResponseDTO {
    private String playlistId;        // Database ID (as String)
    private String name;              // Playlist name
    private Instant createdAt;        // Creation timestamp
}

package com.zeroping.vibecheckbe.dto;

import lombok.Data;

// DTO for saving a playlist to Spotify
@Data
public class SavePlaylistToSpotifyRequest {
    private Long playlistId;
    private String spotifyPlaylistName;
}


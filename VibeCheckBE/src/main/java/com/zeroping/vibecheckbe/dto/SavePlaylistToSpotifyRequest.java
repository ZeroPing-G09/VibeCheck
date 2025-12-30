package com.zeroping.vibecheckbe.dto;

import lombok.Data;

@Data
public class SavePlaylistToSpotifyRequest {
    private Long playlistId;
    private String spotifyPlaylistName;
}


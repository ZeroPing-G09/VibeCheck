package com.zeroping.vibecheckbe.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

// DTO for Spotify playlist request
@Data
@AllArgsConstructor
public class PlaylistSpotifyRequest {
    private List<TrackSpotifyRequest> tracks;
}

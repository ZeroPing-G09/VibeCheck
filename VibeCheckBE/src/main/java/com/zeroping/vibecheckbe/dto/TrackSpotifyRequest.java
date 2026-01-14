package com.zeroping.vibecheckbe.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

// DTO for Track Spotify Request
@Data
@AllArgsConstructor
public class TrackSpotifyRequest {
    private String title;
    private String artist;
}

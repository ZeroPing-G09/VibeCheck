package com.zeroping.vibecheckbe.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class TrackSpotifyRequest {
    private String title;
    private String artist;
}

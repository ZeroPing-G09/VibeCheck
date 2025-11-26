package com.zeroping.vibecheckbe.dto;

import lombok.Data;

import java.util.List;

@Data
public class PlaylistSpotifyRequest {
    private List<TrackSpotifyRequest> tracks;
}

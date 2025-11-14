package com.zeroping.vibecheckbe.dto;

import lombok.Data;

import java.util.List;

@Data
public class PlaylistRequest {
    private String playlist_name;
    private List<TrackRequest> tracks;
}

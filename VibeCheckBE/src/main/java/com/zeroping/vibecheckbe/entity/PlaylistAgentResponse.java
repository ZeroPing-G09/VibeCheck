package com.zeroping.vibecheckbe.entity;

import lombok.Data;

import java.util.List;

@Data
public class PlaylistAgentResponse {
    private String playlist_name;
    private List<TrackAgentResponse> tracks;
}

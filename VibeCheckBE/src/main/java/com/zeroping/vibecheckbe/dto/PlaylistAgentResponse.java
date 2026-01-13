package com.zeroping.vibecheckbe.dto;

import lombok.Data;

import java.util.List;

// DTO for returning playlist details from the agent
@Data
public class PlaylistAgentResponse {
    private String playlist_name;
    private List<TrackAgentResponse> tracks;
}

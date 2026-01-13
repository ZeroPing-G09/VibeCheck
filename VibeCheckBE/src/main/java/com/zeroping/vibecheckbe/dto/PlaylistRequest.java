package com.zeroping.vibecheckbe.dto;

import lombok.*;
import java.util.List;

// DTO for playlist creation request
@Data
public class PlaylistRequest {
    private String mood;
    private List<String> genres;
}

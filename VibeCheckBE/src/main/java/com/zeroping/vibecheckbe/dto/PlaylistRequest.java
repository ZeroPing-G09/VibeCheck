package com.zeroping.vibecheckbe.dto;

import lombok.*;
import java.util.List;

@Data
public class PlaylistRequest {
    private String mood;
    private List<String> genres;

}

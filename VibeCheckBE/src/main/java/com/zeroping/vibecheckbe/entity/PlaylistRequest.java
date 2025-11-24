package com.zeroping.vibecheckbe.entity;

import lombok.*;
import java.util.List;

@Data
public class PlaylistRequest {
    private String mood;
    private List<String> genres;

}

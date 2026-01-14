package com.zeroping.vibecheckbe.dto;

import com.zeroping.vibecheckbe.entity.Song;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

// DTO for Spotify playlist response
@Data
@AllArgsConstructor
public class PlaylistSpotifyResponse {
    private List<Song> songs;
}

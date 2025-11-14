package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.entity.Playlist;
import com.zeroping.vibecheckbe.dto.PlaylistRequest;
import com.zeroping.vibecheckbe.service.PlaylistService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/playlists")
public class PlaylistController {

    private final PlaylistService playlistService;

    public PlaylistController(PlaylistService playlistService) {
        this.playlistService = playlistService;
    }

    @PostMapping("/create-from-ai")
    public ResponseEntity<Playlist> createPlaylistFromAI(
            @RequestBody PlaylistRequest request
    ) {
        try {
            Playlist newPlaylist = playlistService.createPlaylistFromAI(request);

            return ResponseEntity.status(201).body(newPlaylist);

        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }
}
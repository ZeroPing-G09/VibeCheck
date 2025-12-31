package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.*;
import com.zeroping.vibecheckbe.service.GeminiPlaylistService;
import com.zeroping.vibecheckbe.service.PlaylistMetadataService;
import com.zeroping.vibecheckbe.service.PlaylistService;
import com.zeroping.vibecheckbe.service.SpotifyPlaylistService;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.UUID;


@RestController
@RequestMapping("/playlist")
public class PlaylistController {

    private final GeminiPlaylistService geminiPlaylistService;
    private final SpotifyPlaylistService spotifyPlaylistService;
    private final PlaylistMetadataService playlistMetadataService;
    private final PlaylistService playlistService;

    public PlaylistController(GeminiPlaylistService service, SpotifyPlaylistService spotifyPlaylistService,
                              PlaylistMetadataService playlistMetadataService, PlaylistService playlistService) {
        this.geminiPlaylistService = service;
        this.spotifyPlaylistService = spotifyPlaylistService;
        this.playlistMetadataService = playlistMetadataService;
        this.playlistService = playlistService;
    }

    @PostMapping("/generate")
    public PlaylistDTO generate(@RequestBody PlaylistRequest req) throws Exception {
        UUID authenticatedUserId = getAuthenticatedUserId();

        PlaylistAgentResponse playlistAgentResponse = geminiPlaylistService.generatePlaylist(req.getMood(), req.getGenres());

        System.out.println("Gemini returned this playlist:" + playlistAgentResponse);

        PlaylistSpotifyRequest playlistSpotifyRequest = new PlaylistSpotifyRequest(
                playlistAgentResponse.getTracks().stream().map(
                        track -> new TrackSpotifyRequest(track.getTitle(), track.getArtist())
                ).toList()
        );

        PlaylistSpotifyResponse spotifyResponse = spotifyPlaylistService.searchAndSaveSongsFromPlaylist(playlistSpotifyRequest);

        return playlistMetadataService.savePlaylistMetadata(
                spotifyResponse.getSongs(),
                playlistAgentResponse.getPlaylist_name(),
                req.getMood(),
                authenticatedUserId
        );
    }

    // Get all distinct moods of authenticated user, sorted by createdAt ascending
    @GetMapping("/moods")
    public List<String> getUserMoods() {
        UUID userId = getAuthenticatedUserId();
        return playlistService.getUserMoods(userId);
    }

    // Get total number of playlists of authenticated user
    @GetMapping("/playlist-count")
    public Map<String, Long> getUserPlaylistCount() {
        UUID userId = getAuthenticatedUserId();
        long count = playlistService.getNumberOfPlaylists(userId);
        return Map.of("playlistCount", count);
    }

    // Get all the user's playlists
    @GetMapping("/playlists")
    public List<PlaylistDTO> getUserPlaylists() {
        UUID userId = getAuthenticatedUserId();
        return playlistService.getUserPlaylists(userId);
    }

    // Get the latest playlist for the user
    @GetMapping("/last-playlist")
    public PlaylistDTO getLastPlaylist() {
        UUID userId = getAuthenticatedUserId();
        return playlistService.getLastPlaylist(userId);
    }

    // Get timestamp of the latest playlist generation
    @GetMapping("/last-playlist-timestamp")
    public Map<String, Instant> getLastGenerationTimestamp() {
        UUID userId = getAuthenticatedUserId();
        Instant timestamp = playlistService.getLastPlaylistTimestamp(userId);

        return Collections.singletonMap("lastGeneration", timestamp);
    }

    private UUID getAuthenticatedUserId() {
        String userIdString = SecurityContextHolder.getContext().getAuthentication().getName();
        return UUID.fromString(userIdString);
    }
}
package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.*;
import com.zeroping.vibecheckbe.service.GeminiPlaylistService;
import com.zeroping.vibecheckbe.service.PlaylistMetadataService;
import com.zeroping.vibecheckbe.service.PlaylistService;
import com.zeroping.vibecheckbe.service.SpotifyPlaylistService;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/*
POST EXAMPLE FROM FE

{
  "mood": "happy",
  "genres": ["pop", "indie", "electronic"]
}

 */

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
    public PlaylistResponse generate(@RequestBody PlaylistRequest req) throws Exception {

        String userIdString = SecurityContextHolder.getContext().getAuthentication().getName();
        UUID authenticatedUserId = UUID.fromString(userIdString);

        PlaylistAgentResponse playlistAgentResponse = geminiPlaylistService.generatePlaylist(req.getMood(), req.getGenres());

        System.out.println("Gemini returned this playlist:" + playlistAgentResponse);

        PlaylistSpotifyRequest playlistSpotifyRequest = new PlaylistSpotifyRequest(
                playlistAgentResponse.getTracks().stream().map(
                        track -> new TrackSpotifyRequest(track.getTitle(), track.getArtist())
                ).toList()
        );

        PlaylistSpotifyResponse spotifyResponse = spotifyPlaylistService.searchAndSaveSongsFromPlaylist(playlistSpotifyRequest);

        PlaylistDTO playlist = playlistMetadataService.savePlaylistMetadata(
                spotifyResponse.getSongs(),
                playlistAgentResponse.getPlaylist_name(),
                req.getMood(),
                authenticatedUserId
        );

        return new PlaylistResponse(
                playlist,
                spotifyResponse.getSongs()
        );
    }

    // Get all distinct moods of authenticated user, sorted by createdAt ascending
    @GetMapping("/moods")
    public List<String> getUserMoods() {
        String userIdString = SecurityContextHolder.getContext().getAuthentication().getName();
        UUID userId = UUID.fromString(userIdString);
        return playlistService.getUserMoods(userId);
    }

    // Get total number of playlists of authenticated user
    @GetMapping("/playlist-count")
    public Map<String, Long> getUserPlaylistCount() {
        String userIdString = SecurityContextHolder.getContext().getAuthentication().getName();
        UUID userId = UUID.fromString(userIdString);
        long count = playlistService.getNumberOfPlaylists(userId);
        return Map.of("playlistCount", count);
    }

    // Get all the user's playlists
    @GetMapping("/playlists")
    public List<PlaylistDTO> getUserPlaylists() {
        String userIdString = SecurityContextHolder.getContext().getAuthentication().getName();
        UUID userId = UUID.fromString(userIdString);
        return playlistService.getUserPlaylists(userId);
    }

    // Get the latest playlist for the user
    @GetMapping("/last-playlist")
    public PlaylistDTO getLastPlaylist() {
        String userIdString = SecurityContextHolder.getContext().getAuthentication().getName();
        UUID userId = UUID.fromString(userIdString);
        return playlistService.getLastPlaylist(userId);
    }

    // Get timestamp of the latest playlist generation
    @GetMapping("/last-playlist-timestamp")
    public Map<String, Instant> getLastGenerationTimestamp() {
        String userIdString = SecurityContextHolder.getContext().getAuthentication().getName();
        UUID userId = UUID.fromString(userIdString);
        Instant timestamp = playlistService.getLastPlaylistTimestamp(userId);

        return Map.of("lastGeneration", timestamp);
    }
}


/*
JSON RESPONSE FROM AI

{
  "playlist_name": "Happy Vibes",
  "tracks": [
    {
      "title": "Sunroof",
      "artist": "Nicky Youre",
      "spotify_url": "https://open.spotify.com/track/..."
    },
    {
      "title": "Electric Feel",
      "artist": "MGMT",
      "spotify_url": "https://open.spotify.com/track/..."
    }
  ]
}


 */
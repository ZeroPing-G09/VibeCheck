package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.*;
import com.zeroping.vibecheckbe.service.GeminiPlaylistService;
import com.zeroping.vibecheckbe.service.PlaylistMetadataService;
import com.zeroping.vibecheckbe.service.SpotifyPlaylistService;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

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

    public PlaylistController(GeminiPlaylistService service, SpotifyPlaylistService spotifyPlaylistService, PlaylistMetadataService playlistMetadataService) {
        this.geminiPlaylistService = service;
        this.spotifyPlaylistService = spotifyPlaylistService;
        this.playlistMetadataService = playlistMetadataService;
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
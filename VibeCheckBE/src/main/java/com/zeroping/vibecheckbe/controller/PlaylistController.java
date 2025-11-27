package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.*;
import com.zeroping.vibecheckbe.service.GeminiPlaylistService;
import com.zeroping.vibecheckbe.service.SpotifyPlaylistService;
import org.springframework.web.bind.annotation.*;

/*
POST EXAMPLE FROM FE

{
  "mood": "happy",
  "genres": ["pop", "indie", "electronic"]
}

 */

@RestController
@RequestMapping("/api/playlist")
public class PlaylistController {

    private final GeminiPlaylistService geminiPlaylistService;
    private final SpotifyPlaylistService spotifyPlaylistService;

    public PlaylistController(GeminiPlaylistService service, SpotifyPlaylistService spotifyPlaylistService) {
        this.geminiPlaylistService = service;
        this.spotifyPlaylistService = spotifyPlaylistService;
    }

    @PostMapping("/generate")
    public PlaylistSpotifyResponse generate(@RequestBody PlaylistRequest req) throws Exception {
        PlaylistAgentResponse playlistAgentResponse = geminiPlaylistService.generatePlaylist(req.getMood(), req.getGenres());

        System.out.println("Gemini returned this playlist:" + playlistAgentResponse);

        PlaylistSpotifyRequest playlistSpotifyRequest = new PlaylistSpotifyRequest(
                playlistAgentResponse.getTracks().stream().map(
                        track -> new TrackSpotifyRequest(track.getTitle(), track.getArtist())
                ).toList()
        );
        return spotifyPlaylistService.searchAndSaveSongsFromPlaylist(playlistSpotifyRequest);
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
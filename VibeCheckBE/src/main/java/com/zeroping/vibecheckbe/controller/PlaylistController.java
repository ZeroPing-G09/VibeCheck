package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.service.GenreService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;
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

    private final GeminiPlaylistService playlistService;

    public PlaylistController(GeminiPlaylistService service) {
        this.playlistService = service;
    }

    @PostMapping("/generate")
    public Playlist generate(@RequestBody PlaylistRequest req) throws Exception {
        return playlistService.generatePlaylist(req.getMood(), req.getGenres());
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
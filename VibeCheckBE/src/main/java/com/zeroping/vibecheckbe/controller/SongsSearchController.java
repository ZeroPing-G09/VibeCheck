package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.service.SpotifyService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/songs")
public class SongsSearchController {
    private final SpotifyService spotifyService;
    // field for JSON input from AI agent

    SongsSearchController(SpotifyService spotifyService){
        this.spotifyService = spotifyService;
    }

    // parse input
    // extract tracks list
    // for each (artist, name) pair, call the searchSong() function from the service
    // function should return a Track object
    // Track has a field names external_urls
    // external_urls has a field spotify which is the track url
    // save in the database the new Song object(name, artist, url)

}

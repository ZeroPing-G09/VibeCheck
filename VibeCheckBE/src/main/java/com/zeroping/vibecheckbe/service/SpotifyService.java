package com.zeroping.vibecheckbe.service;

import org.springframework.stereotype.Service;
import se.michaelthelin.spotify.SpotifyApi;

@Service
public class SpotifyService {
    private final SpotifyApi spotifyApi;

    private String accessToken;

    public SpotifyService(SpotifyApi spotifyApi) {
        this.spotifyApi = spotifyApi;
        // logic for accessToken
    }

    // logic for search song
}

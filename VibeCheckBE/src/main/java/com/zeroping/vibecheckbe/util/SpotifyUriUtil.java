package com.zeroping.vibecheckbe.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class SpotifyUriUtil {
    
    private static final Pattern SPOTIFY_URL_PATTERN = Pattern.compile(
        "https://open\\.spotify\\.com/track/([a-zA-Z0-9]+)"
    );
    
    /**
     * Converts a Spotify URL to a Spotify URI format (spotify:track:id)
     * @param spotifyUrl The Spotify URL (e.g., https://open.spotify.com/track/4iV5W9uYEdYUVa79Axb7Rh)
     * @return The Spotify URI (e.g., spotify:track:4iV5W9uYEdYUVa79Axb7Rh) or null if invalid
     */
    public static String urlToUri(String spotifyUrl) {
        if (spotifyUrl == null || spotifyUrl.isEmpty()) {
            return null;
        }
        
        // If already in URI format, return as is
        if (spotifyUrl.startsWith("spotify:track:")) {
            return spotifyUrl;
        }
        
        // Extract track ID from URL
        Matcher matcher = SPOTIFY_URL_PATTERN.matcher(spotifyUrl);
        if (matcher.find()) {
            String trackId = matcher.group(1);
            return "spotify:track:" + trackId;
        }
        
        return null;
    }
}


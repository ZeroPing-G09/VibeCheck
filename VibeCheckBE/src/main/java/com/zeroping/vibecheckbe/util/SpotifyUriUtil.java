package com.zeroping.vibecheckbe.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

// Utility class for converting Spotify URLs to Spotify URI format
public class SpotifyUriUtil {
    private static final Pattern SPOTIFY_URL_PATTERN = Pattern.compile(
        "https://open\\.spotify\\.com/track/([a-zA-Z0-9]+)"
    );
    
    // Converts a Spotify track URL to Spotify URI format
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


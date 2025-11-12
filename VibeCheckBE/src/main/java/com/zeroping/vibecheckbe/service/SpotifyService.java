package com.zeroping.vibecheckbe.service;

import org.springframework.stereotype.Service;
import org.apache.hc.core5.http.ParseException;
import se.michaelthelin.spotify.SpotifyApi;

import se.michaelthelin.spotify.exceptions.SpotifyWebApiException;
import se.michaelthelin.spotify.model_objects.specification.ArtistSimplified;
import se.michaelthelin.spotify.model_objects.specification.Paging;
import se.michaelthelin.spotify.model_objects.specification.Track;

import java.io.IOException;
import java.time.Instant;
import java.util.Optional;

@Service
public class SpotifyService {
    private final SpotifyApi spotifyApi;

    // Access token + its absolute expiration moment (to refresh before it expires)
    private String accessToken;
    private Instant tokenExpiresAt;


    public SpotifyService(SpotifyApi spotifyApi) {
        this.spotifyApi = spotifyApi;  // injected bean from AppConfig (already has clientId & clientSecret)
    }

    public Optional<Track> searchSong(String title, String artist) {
        ensureAccessToken(); // make sure we have a valid token
        spotifyApi.setAccessToken(accessToken);

        // Build the query in Spotify's recommended format
        String q = "track: " + title + " artist: " + artist;

        try {
            // Ask for only the first result
            Paging<Track> page = spotifyApi.searchTracks(q)
                    .limit(10)
                    .build()
                    .execute();

            Track[] items = page.getItems();
            if (items == null || items.length == 0) {
                return Optional.empty();
            }
            for (Track track : items) {
                // Check if the track name contains the title
                boolean titleMatch = track.getName().toLowerCase().contains(title.toLowerCase());

                // Check if any of the artists match
                boolean artistMatch = false;
                for (ArtistSimplified trackArtist : track.getArtists()) {
                    if (trackArtist.getName().toLowerCase().contains(artist.toLowerCase())) {
                        artistMatch = true;
                        break; // Found a match, stop looping artists
                    }
                }

                // If both are a good match, return it
                if (titleMatch && artistMatch) {
                    return Optional.of(track);
                }
            }

            // If looped through all 10 and found no good match, the first one as a fallback
            return Optional.of(items[0]);

        } catch (IOException | SpotifyWebApiException | ParseException e) {
            throw new RuntimeException("Error calling Spotify Search API!", e);
        }
    }

    private void ensureAccessToken() {
        boolean needsRefresh = accessToken == null
                || tokenExpiresAt == null
                || Instant.now().isAfter(tokenExpiresAt.minusSeconds(60));

        if (needsRefresh) {
            try {
                var creds = spotifyApi.clientCredentials().build().execute();
                this.accessToken = creds.getAccessToken();
                this.tokenExpiresAt = Instant.now().plusSeconds(creds.getExpiresIn());
            } catch (IOException | SpotifyWebApiException | ParseException e) {
                throw new RuntimeException("Failed to obtain Spotify access token.", e);
            }
        }
    }
}

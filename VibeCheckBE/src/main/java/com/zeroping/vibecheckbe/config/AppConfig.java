package com.zeroping.vibecheckbe.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import se.michaelthelin.spotify.SpotifyApi;

// Configuration class to set up Spotify API client
@Configuration
public class AppConfig {
    // Inject Spotify client ID and secret from application properties
    @Value("${spotify.client-id}")
    private String clientId;

    // Inject Spotify client secret from application properties
    @Value("${spotify.client-secret}")
    private String clientSecret;

    // Define a bean for SpotifyApi to be used throughout the application
    @Bean
    public SpotifyApi spotifyApi() {
        return new SpotifyApi.Builder()
                .setClientId(clientId)
                .setClientSecret(clientSecret)
                .build();
    }
}

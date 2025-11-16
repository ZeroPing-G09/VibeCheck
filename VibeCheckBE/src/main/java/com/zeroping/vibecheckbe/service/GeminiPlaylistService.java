package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.entity.User;
import com.zeroping.vibecheckbe.entity.Genre;
import com.zeroping.vibecheckbe.exception.user.GenreNotFoundForUserException;
import com.zeroping.vibecheckbe.exception.user.UserNotFoundException;
import com.zeroping.vibecheckbe.repository.UserRepository;
import com.zeroping.vibecheckbe.repository.GenreRepository;
import org.springframework.stereotype.Service;
import java.util.*;

import com.fasterxml.jackson.databind.ObjectMapper;
import okhttp3.*;
import org.springframework.stereotype.Service;

@Service
public class GeminiPlaylistService {

    @Value("${gemini.api.key}")
    private String apiKey;

    private static final String GEMINI_URL_TEMPLATE =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=%s";

    private final OkHttpClient client = new OkHttpClient();
    private final ObjectMapper mapper = new ObjectMapper();

    @PostConstruct
    public void validateKey() {
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("Missing GEMINI_API_KEY in environment variables!");
        }
    }


    public Playlist generatePlaylist(String mood, List<String> genres) throws Exception {
      
        String geminiUrl = String.format(GEMINI_URL_TEMPLATE, apiKey);
        // Prompt generat dinamic
        String prompt = """
            You are a music recommendation assistant.
            Generate a JSON playlist based on the user preferences.

            Input:
            { mood: "%s", genres: %s }

            Return ONLY valid JSON in this structure:
            {
              "playlist_name": "string",
              "tracks": [
                { "title": "string", "artist": "string", "spotify_url": "string" }
              ]
            }
            """.formatted(mood, mapper.writeValueAsString(genres));

        // Structura cererii pentru Gemini
        String jsonBody = """
            {
              "contents": [{
                "parts": [{
                  "text": %s
                }]
              }]
            }
            """.formatted(mapper.writeValueAsString(prompt));

        Request request = new Request.Builder()
                .url(geminiUrl)
                .post(RequestBody.create(jsonBody, MediaType.parse("application/json")))
                .build();

        Response response = client.newCall(request).execute();
        String responseBody = response.body().string();

        // Extragem doar textul generat de AI
        String aiText = mapper.readTree(responseBody)
                .get("candidates").get(0)
                .get("content").get("parts").get(0)
                .get("text").asText();

        // Validare JSON
        return validatePlaylist(aiText);
    }

    private Playlist validatePlaylist(String json) throws Exception {
        try {
            Playlist playlist = mapper.readValue(json, Playlist.class);

            if (playlist.getPlaylist_name() == null || playlist.getTracks() == null) {
                throw new Exception("Invalid JSON structure.");
            }

            for (Track t : playlist.getTracks()) {
                if (t.getTitle() == null || t.getArtist() == null || t.getSpotify_url() == null) {
                    throw new Exception("A track contains missing fields.");
                }
            }

            return playlist;

        } catch (Exception e) {
            throw new Exception("JSON parse/validation error: " + e.getMessage());
        }
    }
}

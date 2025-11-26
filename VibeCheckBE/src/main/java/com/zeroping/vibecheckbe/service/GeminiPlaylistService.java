package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.dto.PlaylistAgentResponse;
import com.zeroping.vibecheckbe.dto.TrackAgentResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

import java.io.IOException;
import java.util.List;

@Service
public class GeminiPlaylistService {

    @Value("${gemini.api.key}")
    private String apiKey;

    private static final String GEMINI_URL_TEMPLATE =
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=%s";

    private final OkHttpClient client = new OkHttpClient();
    private final ObjectMapper mapper = new ObjectMapper();

    @PostConstruct
    public void validateKey() {
        if (apiKey == null || apiKey.isBlank()) {
            throw new IllegalStateException("Missing gemini.api.key in properties or environment!");
        }
    }

    public PlaylistAgentResponse generatePlaylist(String mood, List<String> genres) throws Exception {
        String geminiUrl = String.format(GEMINI_URL_TEMPLATE, apiKey);

        String prompt = """
            You are a music recommendation assistant.
            Generate a JSON playlist based on the user preferences.
            Return the JSON as a plain string.

            Input:
            { mood: "%s", genres: %s }

            Return ONLY valid JSON in this structure:
            {
              "playlist_name": "string",
              "tracks": [
                { "title": "string", "artist": "string" }
              ]
            }
            """.formatted(mood, mapper.writeValueAsString(genres));

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

        try (Response response = client.newCall(request).execute()) {
            if (response.body() == null) {
                throw new IllegalStateException("Empty response body from Gemini API");
            }
            String responseBody = response.body().string();

            String aiText = mapper.readTree(responseBody)
                    .get("candidates").get(0)
                    .get("content").get("parts").get(0)
                    .get("text").asText();

            return validatePlaylist(aiText);
        }
    }

    private PlaylistAgentResponse validatePlaylist(String json) throws IOException {
        PlaylistAgentResponse playlist = mapper.readValue(json, PlaylistAgentResponse.class);

        if (playlist.getPlaylist_name() == null || playlist.getTracks() == null) {
            throw new IllegalArgumentException("Invalid JSON structure.");
        }

        for (TrackAgentResponse t : playlist.getTracks()) {
            if (t.getTitle() == null || t.getArtist() == null) {
                throw new IllegalArgumentException("A track contains missing fields.");
            }
        }

        return playlist;
    }
}

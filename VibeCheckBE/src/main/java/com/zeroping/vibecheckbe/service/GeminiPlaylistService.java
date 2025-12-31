package com.zeroping.vibecheckbe.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.zeroping.vibecheckbe.dto.PlaylistAgentResponse;
import com.zeroping.vibecheckbe.dto.TrackAgentResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import okhttp3.Dns;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

import java.io.IOException;
import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.List;
import java.util.concurrent.TimeUnit;

@Service
public class GeminiPlaylistService {

    @Value("${gemini.api.key}")
    private String apiKey;

    private static final String GEMINI_URL_TEMPLATE =
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=%s";

    // Configure OkHttpClient to prefer IPv4 and handle DNS resolution better
    private final OkHttpClient client = new OkHttpClient.Builder()
            .dns(new Dns() {
                @Override
                public List<InetAddress> lookup(String hostname) throws UnknownHostException {
                    try {
                        // Get all addresses
                        InetAddress[] addresses = InetAddress.getAllByName(hostname);
                        // Prefer IPv4 addresses
                        List<InetAddress> ipv4Addresses = java.util.Arrays.stream(addresses)
                                .filter(addr -> addr instanceof Inet4Address)
                                .collect(java.util.stream.Collectors.toList());
                        
                        // If we have IPv4 addresses, use them; otherwise use all addresses
                        return ipv4Addresses.isEmpty() 
                                ? java.util.Arrays.asList(addresses)
                                : ipv4Addresses;
                    } catch (UnknownHostException e) {
                        throw e;
                    }
                }
            })
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(60, TimeUnit.SECONDS)
            .writeTimeout(60, TimeUnit.SECONDS)
            .build();
    
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

            JsonNode rootNode = mapper.readTree(responseBody);

            if (rootNode.has("error")) {
                String msg = rootNode.get("error").get("message").asText();
                throw new RuntimeException("Gemini API Error: " + msg);
            }

            if (rootNode.has("promptFeedback") && rootNode.get("promptFeedback").has("blockReason")) {
                throw new RuntimeException("Blocked by Safety Filter");
            }

            if (rootNode.has("candidates")) {

                String aiText = mapper.readTree(responseBody)
                        .get("candidates").get(0)
                        .get("content").get("parts").get(0)
                        .get("text").asText();

                return validatePlaylist(aiText);
            } else {
                throw new RuntimeException("Gemini did not return a candidate. Check logs for safety blocks or errors.");
            }
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

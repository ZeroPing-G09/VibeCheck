package com.zeroping.vibecheckbe.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InOrder;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import se.michaelthelin.spotify.SpotifyApi;
import se.michaelthelin.spotify.model_objects.credentials.ClientCredentials;
import se.michaelthelin.spotify.model_objects.specification.Paging;
import se.michaelthelin.spotify.model_objects.specification.Track;
import se.michaelthelin.spotify.requests.authorization.client_credentials.ClientCredentialsRequest;
import se.michaelthelin.spotify.requests.data.search.simplified.SearchTracksRequest;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class SpotifyServiceTest {

    @Mock
    private SpotifyApi spotifyApi;

    @InjectMocks
    private SpotifyService spotifyService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    // Helper to mock the Search builder chain
    // spotifyApi.searchTracks(q) -> SearchTracksRequest.Builder
    //   .limit(1) -> Builder
    //   .build()  -> SearchTracksRequest
    //   .execute() -> Paging<Track> (with items[])
    private void mockSearchFlow(String expectedQuery, Track[] items) throws Exception {
        SearchTracksRequest.Builder sBuilder = mock(SearchTracksRequest.Builder.class);
        SearchTracksRequest sRequest = mock(SearchTracksRequest.class);
        Paging<Track> page = mock(Paging.class);

        when(spotifyApi.searchTracks(expectedQuery)).thenReturn(sBuilder);
        when(sBuilder.limit(1)).thenReturn(sBuilder);
        when(sBuilder.build()).thenReturn(sRequest);
        when(sRequest.execute()).thenReturn(page);
        when(page.getItems()).thenReturn(items);
    }

    // Tests

    @Test
    @DisplayName("""
            Given a valid token and an existing song
            When searchSong is called
            Then the first Track is returned
            """)
    void givenExistingSong_whenSearchSong_thenReturnsFirstTrack() throws Exception {
        // Mock the token flow (builder -> request -> credentials)
        ClientCredentialsRequest.Builder cBuilder = mock(ClientCredentialsRequest.Builder.class);
        ClientCredentialsRequest cRequest = mock(ClientCredentialsRequest.class);
        ClientCredentials creds = mock(ClientCredentials.class);

        when(spotifyApi.clientCredentials()).thenReturn(cBuilder);
        when(cBuilder.build()).thenReturn(cRequest);
        when(cRequest.execute()).thenReturn(creds);
        when(creds.getAccessToken()).thenReturn("TOKEN");
        when(creds.getExpiresIn()).thenReturn(3600);

        // Mock a successful search with one result
        Track first = mock(Track.class);
        String q = "track: " + "Yellow" + " artist: " + "Coldplay"; // must match service format
        mockSearchFlow(q, new Track[]{ first });

        Optional<Track> result = spotifyService.searchSong("Yellow", "Coldplay");

        assertTrue(result.isPresent());
        assertEquals(first, result.get());
        verify(spotifyApi).setAccessToken("TOKEN");
    }

    @Test
    @DisplayName("""
            Given a valid token and no search results
            When searchSong is called
            Then Optional.empty() is returned
            """)
    void givenNoResults_whenSearchSong_thenReturnsEmpty() throws Exception {
        // Token OK
        ClientCredentialsRequest.Builder cBuilder = mock(ClientCredentialsRequest.Builder.class);
        ClientCredentialsRequest cRequest = mock(ClientCredentialsRequest.class);
        ClientCredentials creds = mock(ClientCredentials.class);

        when(spotifyApi.clientCredentials()).thenReturn(cBuilder);
        when(cBuilder.build()).thenReturn(cRequest);
        when(cRequest.execute()).thenReturn(creds);
        when(creds.getAccessToken()).thenReturn("TOKEN");
        when(creds.getExpiresIn()).thenReturn(3600);

        // No tracks found
        String q = "track: " + "Unknown" + " artist: " + "Nobody";
        mockSearchFlow(q, new Track[]{}); // empty array

        Optional<Track> result = spotifyService.searchSong("Unknown", "Nobody");

        assertTrue(result.isEmpty());
    }

    @Test
    @DisplayName("""
            Given a token that is near expiry
            When searchSong is called twice
            Then the service refreshes the token and uses a new access token
            """)
    void givenNearExpiryToken_whenSearchTwice_thenRefreshesToken() throws Exception {
        // Mock first token (expires immediately) and second token (valid)
        ClientCredentialsRequest.Builder cBuilder = mock(ClientCredentialsRequest.Builder.class);
        ClientCredentialsRequest cRequest = mock(ClientCredentialsRequest.class);
        when(spotifyApi.clientCredentials()).thenReturn(cBuilder);
        when(cBuilder.build()).thenReturn(cRequest);

        ClientCredentials creds1 = mock(ClientCredentials.class);
        when(creds1.getAccessToken()).thenReturn("TOKEN1");
        when(creds1.getExpiresIn()).thenReturn(1); // will trigger refresh

        ClientCredentials creds2 = mock(ClientCredentials.class);
        when(creds2.getAccessToken()).thenReturn("TOKEN2");
        when(creds2.getExpiresIn()).thenReturn(3600);

        // Return creds1 on first execute(), creds2 on second execute()
        when(cRequest.execute()).thenReturn(creds1, creds2);

        // Mock two searches (one per call)
        mockSearchFlow("track: A artist: B", new Track[]{ mock(Track.class) });
        mockSearchFlow("track: C artist: D", new Track[]{ mock(Track.class) });

        // Call service twice
        spotifyService.searchSong("A", "B");
        spotifyService.searchSong("C", "D");

        // Assert the order of tokens used: first TOKEN1, then TOKEN2 (after refresh)
        InOrder inOrder = inOrder(spotifyApi);
        inOrder.verify(spotifyApi).setAccessToken("TOKEN1");
        inOrder.verify(spotifyApi).setAccessToken("TOKEN2");
    }
}

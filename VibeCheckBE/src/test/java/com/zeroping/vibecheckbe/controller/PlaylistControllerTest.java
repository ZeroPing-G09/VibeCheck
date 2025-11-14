package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.PlaylistRequest;
import com.zeroping.vibecheckbe.dto.TrackRequest;
import com.zeroping.vibecheckbe.entity.Playlist;
import com.zeroping.vibecheckbe.service.PlaylistService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class PlaylistControllerTest {

    @Mock
    private PlaylistService playlistService;

    @InjectMocks
    private PlaylistController playlistController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    @DisplayName("""
            Given a valid playlist request
            When createPlaylistFromAI is called
            Then the service is called and it returns 201 Created
            """)
    void givenValidPlaylistRequest_WhenCreateFromAI_ThenReturns201Created() {
        // --- Given ---

        TrackRequest trackRequest = new TrackRequest();
        trackRequest.setTitle("Sunroof");
        trackRequest.setArtist("Nicky Youre");
        PlaylistRequest requestBody = new PlaylistRequest();
        requestBody.setPlaylist_name("Happy Vibes");
        requestBody.setTracks(List.of(trackRequest));

        Playlist savedPlaylist = new Playlist();
        savedPlaylist.setId(1L);
        savedPlaylist.setName("Happy Vibes");

        when(playlistService.createPlaylistFromAI(requestBody))
                .thenReturn(savedPlaylist);

        // --- When ---
        ResponseEntity<Playlist> response = playlistController.createPlaylistFromAI(requestBody);

        // --- Then ---
        assertNotNull(response);
        assertEquals(HttpStatus.CREATED, response.getStatusCode()); // Check for 201
        assertNotNull(response.getBody());
        assertEquals(1L, response.getBody().getId());
        assertEquals("Happy Vibes", response.getBody().getName());

        verify(playlistService, times(1)).createPlaylistFromAI(requestBody);
    }

    @Test
    @DisplayName("""
            Given the service throws an exception
            When createPlaylistFromAI is called
            Then it returns 500 Internal Server Error
            """)
    void givenServiceThrowsException_WhenCreateFromAI_ThenReturns500() {

        // --- Given ---
        TrackRequest trackRequest = new TrackRequest();
        trackRequest.setTitle("Sunroof");
        PlaylistRequest requestBody = new PlaylistRequest();
        requestBody.setPlaylist_name("Happy Vibes");
        requestBody.setTracks(List.of(trackRequest));

        when(playlistService.createPlaylistFromAI(requestBody))
                .thenThrow(new RuntimeException("Database not responding!"));

        // --- When ---
        ResponseEntity<Playlist> response = playlistController.createPlaylistFromAI(requestBody);

        // --- Then ---
        assertNotNull(response);
        assertEquals(HttpStatus.INTERNAL_SERVER_ERROR, response.getStatusCode());
        assertNull(response.getBody());

        verify(playlistService, times(1)).createPlaylistFromAI(requestBody);
    }
}
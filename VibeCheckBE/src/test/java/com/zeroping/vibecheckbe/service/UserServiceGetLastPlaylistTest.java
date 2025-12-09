package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.dto.LastPlaylistResponseDTO;
import com.zeroping.vibecheckbe.entity.Playlist;
import com.zeroping.vibecheckbe.repository.GenreRepository;
import com.zeroping.vibecheckbe.repository.PlaylistRepository;
import com.zeroping.vibecheckbe.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceGetLastPlaylistTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private GenreRepository genreRepository;

    @Mock
    private PlaylistRepository playlistRepository;

    @InjectMocks
    private UserService userService;

    @Test
    @DisplayName("""
            Given a user with an existing playlist
            When getLastPlaylist is called
            Then it returns the playlist DTO with correct values
            """)
    void givenExistingPlaylist_WhenGetLastPlaylist_ThenReturnsPlaylistDTO() {
        // Given
        UUID userId = UUID.randomUUID();
        Instant createdAt = Instant.now();
        
        Playlist playlist = new Playlist();
        playlist.setId(1L);
        playlist.setName("My Awesome Playlist");
        playlist.setCreatedAt(createdAt);
        playlist.setUserId(userId);

        when(playlistRepository.findFirstByUserIdOrderByCreatedAtDesc(userId))
                .thenReturn(Optional.of(playlist));

        // When
        Optional<LastPlaylistResponseDTO> result = userService.getLastPlaylist(userId);

        // Then
        assertTrue(result.isPresent());
        LastPlaylistResponseDTO dto = result.get();
        assertEquals("1", dto.getPlaylistId()); // Database ID as String
        assertEquals("My Awesome Playlist", dto.getName());
        assertEquals(createdAt, dto.getCreatedAt());

        verify(playlistRepository, times(1)).findFirstByUserIdOrderByCreatedAtDesc(userId);
    }

    @Test
    @DisplayName("""
            Given a user with no playlists
            When getLastPlaylist is called
            Then it returns empty Optional
            """)
    void givenNoPlaylist_WhenGetLastPlaylist_ThenReturnsEmptyOptional() {
        // Given
        UUID userId = UUID.randomUUID();

        when(playlistRepository.findFirstByUserIdOrderByCreatedAtDesc(userId))
                .thenReturn(Optional.empty());

        // When
        Optional<LastPlaylistResponseDTO> result = userService.getLastPlaylist(userId);

        // Then
        assertFalse(result.isPresent());
        verify(playlistRepository, times(1)).findFirstByUserIdOrderByCreatedAtDesc(userId);
    }

    @Test
    @DisplayName("""
            Given a playlist
            When getLastPlaylist is called
            Then it returns the playlist DTO with correct values
            """)
    void givenPlaylist_WhenGetLastPlaylist_ThenReturnsPlaylistDTO() {
        // Given
        UUID userId = UUID.randomUUID();
        Instant createdAt = Instant.now();
        
        Playlist playlist = new Playlist();
        playlist.setId(2L);
        playlist.setName("Local Playlist");
        playlist.setCreatedAt(createdAt);
        playlist.setUserId(userId);

        when(playlistRepository.findFirstByUserIdOrderByCreatedAtDesc(userId))
                .thenReturn(Optional.of(playlist));

        // When
        Optional<LastPlaylistResponseDTO> result = userService.getLastPlaylist(userId);

        // Then
        assertTrue(result.isPresent());
        LastPlaylistResponseDTO dto = result.get();
        assertEquals("2", dto.getPlaylistId()); // Database ID as String
        assertEquals("Local Playlist", dto.getName());
        assertEquals(createdAt, dto.getCreatedAt());
    }
}

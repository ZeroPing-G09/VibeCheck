package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.dto.PlaylistSpotifyRequest;
import com.zeroping.vibecheckbe.dto.PlaylistSpotifyResponse;
import com.zeroping.vibecheckbe.dto.TrackSpotifyRequest;
import com.zeroping.vibecheckbe.entity.Song;
import com.zeroping.vibecheckbe.repository.SongRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import se.michaelthelin.spotify.model_objects.specification.ArtistSimplified;
import se.michaelthelin.spotify.model_objects.specification.ExternalUrl;
import se.michaelthelin.spotify.model_objects.specification.Track;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

// Test class for SpotifyPlaylistService
@ExtendWith(MockitoExtension.class)
class SpotifyPlaylistServiceTest {

    @Mock
    private SongRepository songRepository;
    @Mock
    private SpotifyService spotifyService;

    @InjectMocks
    private SpotifyPlaylistService playlistService;

    // Helper to Create Mocks
    private Track createMockTrack(String name, String artistName, String url) {
        Track mockTrack = mock(Track.class);
        ArtistSimplified mockArtist = mock(ArtistSimplified.class);
        ExternalUrl mockUrls = mock(ExternalUrl.class);

        // FIX: Use lenient() here because 'Existing Song' tests won't read these fields
        lenient().when(mockTrack.getName()).thenReturn(name);
        lenient().when(mockArtist.getName()).thenReturn(artistName);
        lenient().when(mockTrack.getArtists()).thenReturn(new ArtistSimplified[]{mockArtist});

        // These are always read (to check the URL), so they don't strictly need lenient(),
        // but adding it doesn't hurt.
        when(mockTrack.getExternalUrls()).thenReturn(mockUrls);
        when(mockUrls.get("spotify")).thenReturn(url);

        return mockTrack;
    }

    @Test
    @DisplayName("Given a playlist request with a NEW song, it is saved and returned")
    void givenRequestWithNewSong_WhenSearchAndSave_ThenSongIsSaved() {
        // Given
        String songName = "Sunroof";
        String artist = "Nicky Youre";
        String url = "http://spotify.com/0";

        PlaylistSpotifyRequest request = new PlaylistSpotifyRequest(
                List.of(new TrackSpotifyRequest(songName, artist))
        );

        Track mockTrack = createMockTrack(songName, artist, url);
        Song savedSong = new Song();
        savedSong.setId(1L);
        savedSong.setUrl(url);
        savedSong.setName(songName);

        // Mocks
        when(spotifyService.searchSong(songName, artist)).thenReturn(Optional.of(mockTrack));

        // FIX: Mock findFirstByUrl (matches Service implementation)
        lenient().when(songRepository.findFirstByUrl(url)).thenReturn(Optional.empty());

        when(songRepository.save(any(Song.class))).thenReturn(savedSong);

        // When
        PlaylistSpotifyResponse response = playlistService.searchAndSaveSongsFromPlaylist(request);

        // Then
        assertNotNull(response);
        assertEquals(1, response.getSongs().size());
        assertEquals(url, response.getSongs().getFirst().getUrl());

        verify(songRepository, times(1)).save(any(Song.class));
    }

    @Test
    @DisplayName("Given a playlist request with an EXISTING song, it is returned but NOT saved")
    void givenRequestWithExistingSong_WhenSearchAndSave_ThenSongIsReturnedFromDB() {
        // Given
        String songName = "Sunroof";
        String artist = "Nicky Youre";
        String url = "http://spotify.com/0";

        PlaylistSpotifyRequest request = new PlaylistSpotifyRequest(
                List.of(new TrackSpotifyRequest(songName, artist))
        );

        Track mockTrack = createMockTrack(songName, artist, url);
        Song existingSong = new Song();
        existingSong.setId(1L);
        existingSong.setUrl(url);
        existingSong.setName(songName);

        // Mocks
        when(spotifyService.searchSong(songName, artist)).thenReturn(Optional.of(mockTrack));

        // FIX: Mock findFirstByUrl so it returns the existing song
        lenient().when(songRepository.findFirstByUrl(url)).thenReturn(Optional.of(existingSong));

        // When
        PlaylistSpotifyResponse response = playlistService.searchAndSaveSongsFromPlaylist(request);

        // Then
        assertNotNull(response);
        assertEquals(1, response.getSongs().size());
        assertEquals(1L, response.getSongs().getFirst().getId());

        // This should pass now because the service will see the existing song and SKIP save()
        verify(songRepository, times(0)).save(any(Song.class));
    }

    @Test
    @DisplayName("Given a request where song is NOT found by Spotify, nothing is saved")
    void givenRequestWithSongNotFound_WhenSearchAndSave_ThenNothingSaved() {
        // Given
        PlaylistSpotifyRequest request = new PlaylistSpotifyRequest(
                List.of(new TrackSpotifyRequest("Ghost", "Unknown"))
        );

        when(spotifyService.searchSong("Ghost", "Unknown")).thenReturn(Optional.empty());

        // When
        PlaylistSpotifyResponse response = playlistService.searchAndSaveSongsFromPlaylist(request);

        // Then
        assertTrue(response.getSongs().isEmpty());
        verify(songRepository, times(0)).findFirstByUrl(anyString());
        verify(songRepository, times(0)).save(any(Song.class));
    }

    @Test
    @DisplayName("Given mixed tracks (new, existing, not found), handles all correctly")
    void givenRequestWithMixedTracks_WhenSearchAndSave_ThenHandlesAll() {
        // Given
        TrackSpotifyRequest reqNew = new TrackSpotifyRequest("New", "Artist1");
        TrackSpotifyRequest reqExist = new TrackSpotifyRequest("Existing", "Artist2");
        TrackSpotifyRequest reqMiss = new TrackSpotifyRequest("Missing", "Artist3");

        PlaylistSpotifyRequest request = new PlaylistSpotifyRequest(List.of(reqNew, reqExist, reqMiss));

        Track trackNew = createMockTrack("New", "Artist1", "http://url/1");
        Track trackExist = createMockTrack("Existing", "Artist2", "http://url/2");

        Song songNew = new Song(); songNew.setId(10L); songNew.setUrl("http://url/1");
        Song songExist = new Song(); songExist.setId(20L); songExist.setUrl("http://url/2");

        when(spotifyService.searchSong("New", "Artist1")).thenReturn(Optional.of(trackNew));
        when(spotifyService.searchSong("Existing", "Artist2")).thenReturn(Optional.of(trackExist));
        when(spotifyService.searchSong("Missing", "Artist3")).thenReturn(Optional.empty());

        // FIX: Mock findFirstByUrl correctly
        lenient().when(songRepository.findFirstByUrl("http://url/1")).thenReturn(Optional.empty());
        lenient().when(songRepository.findFirstByUrl("http://url/2")).thenReturn(Optional.of(songExist));

        when(songRepository.save(any(Song.class))).thenReturn(songNew);

        // When
        PlaylistSpotifyResponse response = playlistService.searchAndSaveSongsFromPlaylist(request);

        // Then
        assertEquals(2, response.getSongs().size());
        verify(songRepository, times(1)).save(any(Song.class));
    }
}
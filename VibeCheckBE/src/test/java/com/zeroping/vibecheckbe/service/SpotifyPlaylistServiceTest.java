package com.zeroping.vibecheckbe.service;
import com.zeroping.vibecheckbe.dto.PlaylistSpotifyRequest;
import com.zeroping.vibecheckbe.dto.PlaylistSpotifyResponse;
import com.zeroping.vibecheckbe.dto.TrackSpotifyRequest;
import com.zeroping.vibecheckbe.entity.Song;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import com.zeroping.vibecheckbe.repository.SongRepository;
import se.michaelthelin.spotify.model_objects.specification.ArtistSimplified;
import se.michaelthelin.spotify.model_objects.specification.Track;
import se.michaelthelin.spotify.model_objects.specification.ExternalUrl;

import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class SpotifyPlaylistServiceTest {
    @Mock
    private SongRepository songRepository;
    @Mock
    private SpotifyService spotifyService;

    @InjectMocks
    private SpotifyPlaylistService playlistService;

    @BeforeEach
    void setUp() {
    }

    @Test
    @DisplayName("""
            Given a playlist request with a NEW song
            When searchAndSaveSongsFromPlaylist is called
            Then the new song is saved and returned
            """)
    void givenRequestWithNewSong_WhenSearchAndSaveSongsFromPlaylist_ThenSongIsFoundAndSavedToDB() {

        // Given
        TrackSpotifyRequest trackRequest = new TrackSpotifyRequest();
        trackRequest.setTitle("Sunroof");
        trackRequest.setArtist("Nicky Youre");

        // test data
        PlaylistSpotifyRequest playlistSpotifyRequest = new PlaylistSpotifyRequest();
        playlistSpotifyRequest.setTracks(List.of(trackRequest));

        Track mockSpotifyTrack = mock(Track.class);
        ArtistSimplified mockArtist = mock(ArtistSimplified.class);
        ExternalUrl mockUrls = mock(ExternalUrl.class);

        Song mockSongEntity = new Song();
        mockSongEntity.setId(1L);
        mockSongEntity.setUrl("https://open.spotify.com/track/123");
        mockSongEntity.setName("Sunroof");

        when(mockSpotifyTrack.getName()).thenReturn("Sunroof");
        when(mockSpotifyTrack.getArtists()).thenReturn(new ArtistSimplified[]{mockArtist});
        when(mockArtist.getName()).thenReturn("Nicky Youre");
        when(mockSpotifyTrack.getExternalUrls()).thenReturn(mockUrls);
        when(mockUrls.get("spotify")).thenReturn("https://open.spotify.com/track/123");

        when(spotifyService.searchSong("Sunroof", "Nicky Youre"))
                .thenReturn(Optional.of(mockSpotifyTrack));

        when(songRepository.findByUrl("https://open.spotify.com/track/123"))
                .thenReturn(Optional.empty());

        when(songRepository.save(any(Song.class)))
                .thenReturn(mockSongEntity);

        // When
        PlaylistSpotifyResponse resultPlaylist = playlistService.searchAndSaveSongsFromPlaylist(playlistSpotifyRequest);

        // Then
        assertNotNull(resultPlaylist);
        assertEquals(1, resultPlaylist.getSongs().size());
        assertEquals("https://open.spotify.com/track/123", resultPlaylist.getSongs().getFirst().getUrl());

        verify(spotifyService, times(1)).searchSong("Sunroof", "Nicky Youre");
        verify(songRepository, times(1)).findByUrl("https://open.spotify.com/track/123");
        verify(songRepository, times(1)).save(any(Song.class));
    }

    @Test
    @DisplayName("""
            Given a playlist request with an EXISTING song
            When searchAndSaveSongsFromPlaylist is called
            Then the song is returned, but not saved in the db
            """)
    void givenRequestWithExistingSong_WhenSearchAndSaveSongsFromPlaylist_ThenSongIsFoundAndReturnedFromDB() {

        // Given
        TrackSpotifyRequest trackRequest = new TrackSpotifyRequest();
        trackRequest.setTitle("Sunroof");
        trackRequest.setArtist("Nicky Youre");

        PlaylistSpotifyRequest playlistRequest = new PlaylistSpotifyRequest();
        playlistRequest.setTracks(List.of(trackRequest));
        ExternalUrl mockUrls = mock(ExternalUrl.class);

        Track mockSpotifyTrack = mock(Track.class);
        when(mockSpotifyTrack.getExternalUrls()).thenReturn(mockUrls);
        when(mockUrls.get("spotify")).thenReturn("https://open.spotify.com/track/123");

        Song existingSongEntity = new Song(); // This song already exists in DB
        existingSongEntity.setId(1L);
        existingSongEntity.setUrl("https://open.spotify.com/track/123");
        existingSongEntity.setName("Sunroof");


        when(spotifyService.searchSong("Sunroof", "Nicky Youre"))
                .thenReturn(Optional.of(mockSpotifyTrack));
        when(songRepository.findByUrl("https://open.spotify.com/track/123"))
                .thenReturn(Optional.of(existingSongEntity));

        // When
        PlaylistSpotifyResponse resultPlaylist = playlistService.searchAndSaveSongsFromPlaylist(playlistRequest);

        // Then
        assertNotNull(resultPlaylist);
        assertEquals(1, resultPlaylist.getSongs().size()); // Link is still created
        assertEquals(1L, resultPlaylist.getSongs().getFirst().getId());

        verify(spotifyService, times(1)).searchSong("Sunroof", "Nicky Youre");
        verify(songRepository, times(1)).findByUrl("https://open.spotify.com/track/123");
        verify(songRepository, times(0)).save(any(Song.class)); // Verifies that a new song was NOT created
    }

    @Test
    @DisplayName("""
            Given a playlist request where song is NOT found by Spotify
            When searchAndSaveSongsFromPlaylist is called
            Then nothing is saved to db and the response list is empty
            """)
    void givenRequestWithSongNotFound_WhenSearchAndSaveSongsFromPlaylist_ThenNothingIsReturnedAndSavedToDB() {

        // Given
        TrackSpotifyRequest trackRequest = new TrackSpotifyRequest();
        trackRequest.setTitle("NonExistentSong");
        trackRequest.setArtist("Nobody");
        PlaylistSpotifyRequest playlistRequest = new PlaylistSpotifyRequest();
        playlistRequest.setTracks(List.of(trackRequest));


        when(spotifyService.searchSong("NonExistentSong", "Nobody"))
                .thenReturn(Optional.empty()); // Spotify finds NOTHING


        // When
        PlaylistSpotifyResponse resultPlaylist = playlistService.searchAndSaveSongsFromPlaylist(playlistRequest);

        // Then
        assertNotNull(resultPlaylist);

        verify(spotifyService, times(1)).searchSong("NonExistentSong", "Nobody");
        verify(songRepository, times(0)).findByUrl(anyString()); // Never checked DB
        verify(songRepository, times(0)).save(any(Song.class)); // Never saved a song
    }

    @Test
    @DisplayName("""
            Given a playlist request with mixed tracks (new, existing, not found)
            When searchAndSaveSongsFromPlaylist is called
            Then it correctly processes all three cases
            """)
    void givenRequestWithMixedTracks_WhenSearchAndSaveSongsFromPlaylist_ThenHandlesAllCasesCorrectly() {

        // Given
        TrackSpotifyRequest newTrackReq = new TrackSpotifyRequest();
        newTrackReq.setTitle("Sunroof");
        newTrackReq.setArtist("Nicky Youre");

        TrackSpotifyRequest existingTrackReq = new TrackSpotifyRequest();
        existingTrackReq.setTitle("As It Was");
        existingTrackReq.setArtist("Harry Styles");

        TrackSpotifyRequest notFoundTrackReq = new TrackSpotifyRequest();
        notFoundTrackReq.setTitle("NonExistentSong");
        notFoundTrackReq.setArtist("Nobody");

        PlaylistSpotifyRequest playlistRequest = new PlaylistSpotifyRequest();
        playlistRequest.setTracks(List.of(newTrackReq, existingTrackReq, notFoundTrackReq));

        Track mockSpotifyTrackNew = mock(Track.class);
        when(mockSpotifyTrackNew.getName()).thenReturn("Sunroof");
        ArtistSimplified mockArtistNew = mock(ArtistSimplified.class);
        when(mockArtistNew.getName()).thenReturn("Nicky Youre");
        when(mockSpotifyTrackNew.getArtists()).thenReturn(new ArtistSimplified[]{mockArtistNew});

        ExternalUrl mockUrlsNew = mock(ExternalUrl.class);
        when(mockSpotifyTrackNew.getExternalUrls()).thenReturn(mockUrlsNew);
        when(mockUrlsNew.get("spotify")).thenReturn("https://open.spotify.com/track/123");

        Track mockSpotifyTrackExisting = mock(Track.class);
        ExternalUrl mockSpotifyTrackExistingUrls = mock(ExternalUrl.class);
        when(mockSpotifyTrackExistingUrls.get("spotify")).thenReturn("https://open.spotify.com/track/456");
        when(mockSpotifyTrackExisting.getExternalUrls()).thenReturn(mockSpotifyTrackExistingUrls);

        Song mockSongEntityNew = new Song();
        mockSongEntityNew.setId(1L);
        mockSongEntityNew.setUrl("https://open.spotify.com/track/123");

        Song mockSongEntityExisting = new Song();
        mockSongEntityExisting.setId(2L);
        mockSongEntityExisting.setUrl("https://open.spotify.com/track/456");

        when(spotifyService.searchSong("Sunroof", "Nicky Youre")).thenReturn(Optional.of(mockSpotifyTrackNew));
        when(spotifyService.searchSong("As It Was", "Harry Styles")).thenReturn(Optional.of(mockSpotifyTrackExisting));
        when(spotifyService.searchSong("NonExistentSong", "Nobody")).thenReturn(Optional.empty());

        when(songRepository.findByUrl("https://open.spotify.com/track/123")).thenReturn(Optional.empty()); // New
        when(songRepository.findByUrl("https://open.spotify.com/track/456")).thenReturn(Optional.of(mockSongEntityExisting)); // Existing
        when(songRepository.save(any(Song.class))).thenReturn(mockSongEntityNew); // Return the new song when saved

        // When
        PlaylistSpotifyResponse resultPlaylist = playlistService.searchAndSaveSongsFromPlaylist(playlistRequest);

        // Then
        assertNotNull(resultPlaylist);

        verify(spotifyService, times(1)).searchSong("Sunroof", "Nicky Youre");
        verify(spotifyService, times(1)).searchSong("As It Was", "Harry Styles");
        verify(spotifyService, times(1)).searchSong("NonExistentSong", "Nobody");


        verify(songRepository, times(1)).findByUrl("https://open.spotify.com/track/123");
        verify(songRepository, times(1)).findByUrl("https://open.spotify.com/track/456");
        verify(songRepository, never()).findByUrl(null);

        verify(songRepository, times(1)).save(any(Song.class));

        assertEquals(2, resultPlaylist.getSongs().size());
    }
}
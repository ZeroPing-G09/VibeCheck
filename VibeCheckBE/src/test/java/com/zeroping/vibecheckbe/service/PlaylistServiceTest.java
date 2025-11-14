package com.zeroping.vibecheckbe.service;
import com.zeroping.vibecheckbe.dto.PlaylistRequest;
import com.zeroping.vibecheckbe.dto.TrackRequest;
import com.zeroping.vibecheckbe.entity.Playlist;
import com.zeroping.vibecheckbe.entity.PlaylistSong;
import com.zeroping.vibecheckbe.entity.Song;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.stubbing.Answer;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import com.zeroping.vibecheckbe.repository.PlaylistRepository;
import com.zeroping.vibecheckbe.repository.SongRepository;
import com.zeroping.vibecheckbe.repository.PlaylistSongRepository;
import se.michaelthelin.spotify.model_objects.specification.ArtistSimplified;
import se.michaelthelin.spotify.model_objects.specification.Track;
import se.michaelthelin.spotify.model_objects.specification.ExternalUrl;

import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

@ExtendWith(MockitoExtension.class)
class PlaylistServiceTest {
    @Mock
    private PlaylistRepository playlistRepository;
    @Mock
    private SongRepository songRepository;
    @Mock
    private PlaylistSongRepository playlistSongRepository;
    @Mock
    private SpotifyService spotifyService;

    @InjectMocks
    private PlaylistService playlistService;

    @BeforeEach
    void setUp() {
    }

    @Test
    @DisplayName("""
            Given a playlist request with a NEW song
            When createPlaylistFromAI is called
            Then the new playlist, new song, and link are saved
            """)
    void givenRequestWithNewSong_WhenCreatePlaylistFromAI_ThenAllEntitiesAreSavedToDB() {

        // Given
        TrackRequest trackRequest = new TrackRequest();
        trackRequest.setTitle("Sunroof");
        trackRequest.setArtist("Nicky Youre");

        // test data
        PlaylistRequest playlistRequest = new PlaylistRequest();
        playlistRequest.setPlaylist_name("Happy Vibes");
        playlistRequest.setTracks(List.of(trackRequest));

        Track mockSpotifyTrack = mock(Track.class);
        ArtistSimplified mockArtist = mock(ArtistSimplified.class);
        ExternalUrl mockUrls = mock(ExternalUrl.class);

        Song mockSongEntity = new Song();
        mockSongEntity.setId(1L);
        mockSongEntity.setUrl("https://open.spotify.com/track/123");
        mockSongEntity.setName("Sunroof");

        Playlist mockPlaylist = new Playlist();
        mockPlaylist.setId(10L);
        mockPlaylist.setName("Happy Vibes");

        when(mockSpotifyTrack.getName()).thenReturn("Sunroof");
        when(mockSpotifyTrack.getArtists()).thenReturn(new ArtistSimplified[]{mockArtist});
        when(mockArtist.getName()).thenReturn("Nicky Youre");
        when(mockSpotifyTrack.getExternalUrls()).thenReturn(mockUrls);
        when(mockUrls.get("spotify")).thenReturn("https://open.spotify.com/track/123");

        when(spotifyService.searchSong("Sunroof", "Nicky Youre"))
                .thenReturn(Optional.of(mockSpotifyTrack));

        when(songRepository.findByUrl("https://open.spotify.com/track/123"))
                .thenReturn(Optional.empty());

        when(playlistRepository.save(any(Playlist.class)))
                .thenReturn(mockPlaylist);

        when(songRepository.save(any(Song.class)))
                .thenReturn(mockSongEntity);

        when(playlistSongRepository.saveAll(anyList()))
                .thenAnswer((Answer<List<PlaylistSong>>) invocation -> invocation.getArgument(0));

        // When
        Playlist resultPlaylist = playlistService.createPlaylistFromAI(playlistRequest);

        // Then
        assertNotNull(resultPlaylist);
        assertEquals("Happy Vibes", resultPlaylist.getName());
        assertEquals(1, resultPlaylist.getPlaylistSongs().size());
        assertEquals("https://open.spotify.com/track/123", resultPlaylist.getPlaylistSongs().getFirst().getSong().getUrl());

        verify(spotifyService, times(1)).searchSong("Sunroof", "Nicky Youre");
        verify(playlistRepository, times(1)).save(any(Playlist.class));
        verify(songRepository, times(1)).findByUrl("https://open.spotify.com/track/123");
        verify(songRepository, times(1)).save(any(Song.class));
        verify(playlistSongRepository, times(1)).saveAll(anyList());
    }

    @Test
    @DisplayName("""
            Given a playlist request with an EXISTING song
            When createPlaylistFromAI is called
            Then the playlist and link are saved, but NOT the song
            """)
    void givenRequestWithExistingSong_WhenCreatePlaylistFromAI_ThenOnlyPlaylistAndLinkAreSavedToDB() {

        // Given
        TrackRequest trackRequest = new TrackRequest();
        trackRequest.setTitle("Sunroof");
        trackRequest.setArtist("Nicky Youre");
        PlaylistRequest playlistRequest = new PlaylistRequest();
        playlistRequest.setPlaylist_name("Happy Vibes");
        playlistRequest.setTracks(List.of(trackRequest));
        ExternalUrl mockUrls = mock(ExternalUrl.class);

        Track mockSpotifyTrack = mock(Track.class);
        when(mockSpotifyTrack.getExternalUrls()).thenReturn(mockUrls);
        when(mockUrls.get("spotify")).thenReturn("https://open.spotify.com/track/123");

        Song existingSongEntity = new Song(); // This song already exists in DB
        existingSongEntity.setId(1L);
        existingSongEntity.setUrl("https://open.spotify.com/track/123");
        existingSongEntity.setName("Sunroof");

        Playlist mockPlaylist = new Playlist();
        mockPlaylist.setId(10L);
        mockPlaylist.setName("Happy Vibes");
        mockPlaylist.setPlaylistSongs(new ArrayList<>());

        when(spotifyService.searchSong("Sunroof", "Nicky Youre"))
                .thenReturn(Optional.of(mockSpotifyTrack));
        when(songRepository.findByUrl("https://open.spotify.com/track/123"))
                .thenReturn(Optional.of(existingSongEntity));
        when(playlistRepository.save(any(Playlist.class)))
                .thenReturn(mockPlaylist);
        when(playlistSongRepository.saveAll(anyList()))
                .thenAnswer((Answer<List<PlaylistSong>>) invocation -> {
                    List<PlaylistSong> links = invocation.getArgument(0);
                    mockPlaylist.setPlaylistSongs(links);
                    return links;
                });

        // When
        Playlist resultPlaylist = playlistService.createPlaylistFromAI(playlistRequest);

        // Then
        assertNotNull(resultPlaylist);
        assertEquals("Happy Vibes", resultPlaylist.getName());
        assertEquals(1, resultPlaylist.getPlaylistSongs().size()); // Link is still created
        assertEquals(1L, resultPlaylist.getPlaylistSongs().getFirst().getSong().getId());

        verify(spotifyService, times(1)).searchSong("Sunroof", "Nicky Youre");
        verify(playlistRepository, times(1)).save(any(Playlist.class));
        verify(songRepository, times(1)).findByUrl("https://open.spotify.com/track/123");
        verify(songRepository, times(0)).save(any(Song.class)); // Verifies that a new song was NOT created
        verify(playlistSongRepository, times(1)).saveAll(anyList());
    }

    @Test
    @DisplayName("""
            Given a playlist request where song is NOT found by Spotify
            When createPlaylistFromAI is called
            Then only the playlist is saved, no song or link
            """)
    void givenRequestWithSongNotFound_WhenCreatePlaylistFromAI_ThenOnlyPlaylistIsSavedToDB() {

        // Given
        TrackRequest trackRequest = new TrackRequest();
        trackRequest.setTitle("NonExistentSong");
        trackRequest.setArtist("Nobody");
        PlaylistRequest playlistRequest = new PlaylistRequest();
        playlistRequest.setPlaylist_name("Empty Playlist");
        playlistRequest.setTracks(List.of(trackRequest));

        Playlist mockPlaylist = new Playlist();
        mockPlaylist.setId(10L);
        mockPlaylist.setName("Empty Playlist");

        when(spotifyService.searchSong("NonExistentSong", "Nobody"))
                .thenReturn(Optional.empty()); // Spotify finds NOTHING
        when(playlistRepository.save(any(Playlist.class)))
                .thenReturn(mockPlaylist);

        ArgumentCaptor<List<PlaylistSong>> captor = ArgumentCaptor.forClass(List.class);

        // When
        Playlist resultPlaylist = playlistService.createPlaylistFromAI(playlistRequest);

        // Then
        assertNotNull(resultPlaylist);
        assertEquals("Empty Playlist", resultPlaylist.getName());

        verify(spotifyService, times(1)).searchSong("NonExistentSong", "Nobody");
        verify(playlistRepository, times(1)).save(any(Playlist.class));
        verify(songRepository, times(0)).findByUrl(anyString()); // Never checked DB
        verify(songRepository, times(0)).save(any(Song.class)); // Never saved a song

        verify(playlistSongRepository, times(1)).saveAll(captor.capture());
        assertTrue(captor.getValue().isEmpty());
    }

    @Test
    @DisplayName("""
            Given a playlist request with mixed tracks (new, existing, not found)
            When createPlaylistFromAI is called
            Then it correctly processes all three cases
            """)
    void givenRequestWithMixedTracks_WhenCreatePlaylistFromAI_ThenHandlesAllCasesCorrectly() {

        // Given
        TrackRequest newTrackReq = new TrackRequest();
        newTrackReq.setTitle("Sunroof");
        newTrackReq.setArtist("Nicky Youre");

        TrackRequest existingTrackReq = new TrackRequest();
        existingTrackReq.setTitle("As It Was");
        existingTrackReq.setArtist("Harry Styles");

        TrackRequest notFoundTrackReq = new TrackRequest();
        notFoundTrackReq.setTitle("NonExistentSong");
        notFoundTrackReq.setArtist("Nobody");

        PlaylistRequest playlistRequest = new PlaylistRequest();
        playlistRequest.setPlaylist_name("Mixed Bag");
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

        Playlist mockPlaylist = new Playlist();
        mockPlaylist.setId(10L);
        mockPlaylist.setName("Mixed Bag");
        mockPlaylist.setPlaylistSongs(new ArrayList<>());

        when(spotifyService.searchSong("Sunroof", "Nicky Youre")).thenReturn(Optional.of(mockSpotifyTrackNew));
        when(spotifyService.searchSong("As It Was", "Harry Styles")).thenReturn(Optional.of(mockSpotifyTrackExisting));
        when(spotifyService.searchSong("NonExistentSong", "Nobody")).thenReturn(Optional.empty());

        when(songRepository.findByUrl("https://open.spotify.com/track/123")).thenReturn(Optional.empty()); // New
        when(songRepository.findByUrl("https://open.spotify.com/track/456")).thenReturn(Optional.of(mockSongEntityExisting)); // Existing
        when(songRepository.save(any(Song.class))).thenReturn(mockSongEntityNew); // Return the new song when saved

        when(playlistRepository.save(any(Playlist.class))).thenReturn(mockPlaylist);

        ArgumentCaptor<List<PlaylistSong>> captor = ArgumentCaptor.forClass(List.class);
        when(playlistSongRepository.saveAll(anyList()))
                .thenAnswer((Answer<List<PlaylistSong>>) invocation -> {
                    List<PlaylistSong> links = invocation.getArgument(0);
                    mockPlaylist.setPlaylistSongs(links);
                    return links;
                });

        // When
        Playlist resultPlaylist = playlistService.createPlaylistFromAI(playlistRequest);

        // Then
        assertNotNull(resultPlaylist);
        assertEquals("Mixed Bag", resultPlaylist.getName());

        verify(spotifyService, times(1)).searchSong("Sunroof", "Nicky Youre");
        verify(spotifyService, times(1)).searchSong("As It Was", "Harry Styles");
        verify(spotifyService, times(1)).searchSong("NonExistentSong", "Nobody");

        verify(playlistRepository, times(1)).save(any(Playlist.class));

        verify(songRepository, times(1)).findByUrl("https://open.spotify.com/track/123");
        verify(songRepository, times(1)).findByUrl("https://open.spotify.com/track/456");
        verify(songRepository, never()).findByUrl(null);

        verify(songRepository, times(1)).save(any(Song.class));

        verify(playlistSongRepository, times(1)).saveAll(captor.capture());

        List<PlaylistSong> savedLinks = captor.getValue();
        assertEquals(2, savedLinks.size()); // Should only have 2 links
        // Check that the saved links correspond to the correct song entities
        assertTrue(savedLinks.stream().anyMatch(link -> link.getSong().getId().equals(1L))); // New song
        assertTrue(savedLinks.stream().anyMatch(link -> link.getSong().getId().equals(2L))); // Existing song

        assertEquals(2, resultPlaylist.getPlaylistSongs().size());
    }
}
package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.entity.Playlist;
import com.zeroping.vibecheckbe.entity.PlaylistSong;
import com.zeroping.vibecheckbe.entity.Song;
import com.zeroping.vibecheckbe.repository.PlaylistRepository;
import com.zeroping.vibecheckbe.repository.PlaylistSongRepository;
import com.zeroping.vibecheckbe.repository.SongRepository;
import com.zeroping.vibecheckbe.dto.PlaylistRequest;
import com.zeroping.vibecheckbe.dto.TrackRequest;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import se.michaelthelin.spotify.model_objects.specification.Track;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class PlaylistService {
    private final PlaylistRepository playlistRepository;
    private final SongRepository songRepository;
    private final PlaylistSongRepository playlistSongRepository;
    private final SpotifyService spotifyService;

    public PlaylistService(PlaylistRepository playlistRepository,
                           SongRepository songRepository,
                           PlaylistSongRepository playlistSongRepository,
                           SpotifyService spotifyService) {
        this.playlistRepository = playlistRepository;
        this.songRepository = songRepository;
        this.playlistSongRepository = playlistSongRepository;
        this.spotifyService = spotifyService;
    }

    @Transactional
    public Playlist createPlaylistFromAI(PlaylistRequest request) {

        // add playlist to db
        Playlist newPlaylist = new Playlist();
        newPlaylist.setName(request.getPlaylist_name());
        Playlist savedPlaylist = playlistRepository.save(newPlaylist);

        List<Song> savedSongs = new ArrayList<>();

        // search the songs
        for (TrackRequest trackRequest : request.getTracks()) {

            // Call Spotify service
            Optional<Track> spotifyTrackOpt = spotifyService.searchSong(
                    trackRequest.getTitle(),
                    trackRequest.getArtist()
            );

            if (spotifyTrackOpt.isPresent()) {
                Track spotifyTrack = spotifyTrackOpt.get();

                // Check if this song is already in db with the unique Spotify ID
                String spotifyId = spotifyTrack.getId();

                Optional<Song> existingSongOpt = songRepository.findBySpotifyTrackId(spotifyId);

                Song songEntity;
                if (existingSongOpt.isPresent()) {
                    // It's already in db, just use that one
                    songEntity = existingSongOpt.get();
                } else {
                    // new song, create and add it to db
                    songEntity = new Song();

                    songEntity.setArtist_name(spotifyTrack.getArtists()[0].getName());
                    songEntity.setTitle(spotifyTrack.getName());
                    songEntity.setUrl(spotifyTrack.getExternalUrls().get("spotify"));

                    songEntity = songRepository.save(songEntity);
                }

                savedSongs.add(songEntity);
            }
            // If search fails (Optional is empty), skip this track.
        }

        // add pairs to the join table
        List<PlaylistSong> pairsToSave = new ArrayList<>();
        for (Song song : savedSongs) {
            PlaylistSong pair = new PlaylistSong(savedPlaylist, song);
            pairsToSave.add(pair);
        }

        // Save ALL the pairs to the PlaylistSongs table in one batch
        playlistSongRepository.saveAll(pairsToSave);

        // Update the playlist object with the links before returning
        savedPlaylist.setPlaylistSongs(pairsToSave);
        return savedPlaylist;
    }
}

package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.dto.PlaylistSpotifyRequest;
import com.zeroping.vibecheckbe.dto.PlaylistSpotifyResponse;
import com.zeroping.vibecheckbe.dto.TrackSpotifyRequest;
import com.zeroping.vibecheckbe.entity.Song;
import com.zeroping.vibecheckbe.repository.SongRepository;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;
import se.michaelthelin.spotify.model_objects.specification.Track;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class SpotifyPlaylistService {
    private final SongRepository songRepository;
    private final SpotifyService spotifyService;


    public SpotifyPlaylistService(SongRepository songRepository,
                                  SpotifyService spotifyService) {
        this.songRepository = songRepository;
        this.spotifyService = spotifyService;
    }

    @Transactional
    public PlaylistSpotifyResponse searchAndSaveSongsFromPlaylist(PlaylistSpotifyRequest request) {
        List<Song> savedSongs = new ArrayList<>();

        // search the songs
        for (TrackSpotifyRequest trackSpotifyRequest : request.getTracks()) {

            // Call Spotify service
            Optional<Track> spotifyTrackOpt = spotifyService.searchSong(
                    trackSpotifyRequest.getTitle(),
                    trackSpotifyRequest.getArtist()
            );

            if (spotifyTrackOpt.isPresent()) {
                Track spotifyTrack = spotifyTrackOpt.get();

                if(spotifyTrack.getExternalUrls() == null) {
                    continue;
                }
                // Check if this song is already in db with the url
                String spotifyURL = spotifyTrack.getExternalUrls().get("spotify");

                // Use findFirstByUrl to handle potential duplicates in the database
                Optional<Song> existingSongOpt = songRepository.findFirstByUrl(spotifyURL);

                Song songEntity;
                if (existingSongOpt.isPresent()) {
                    // It's already in db, just use that one
                    songEntity = existingSongOpt.get();
                } else {
                    // new song, create and add it to db
                    songEntity = new Song();

                    songEntity.setArtistName(spotifyTrack.getArtists()[0].getName());
                    songEntity.setName(spotifyTrack.getName());
                    songEntity.setUrl(spotifyTrack.getExternalUrls().get("spotify"));

                    songEntity = songRepository.save(songEntity);
                }

                savedSongs.add(songEntity);
            }
            // If search fails (Optional is empty), skip this track.
        }
        return new PlaylistSpotifyResponse(savedSongs);
    }
}

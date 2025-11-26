package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.entity.Song;
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
    private final SongRepository songRepository;
    private final SpotifyService spotifyService;

    public PlaylistService(SongRepository songRepository,
                           SpotifyService spotifyService) {
        this.songRepository = songRepository;
        this.spotifyService = spotifyService;
    }

    @Transactional
    public void createPlaylistFromAI(PlaylistRequest request) {

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

                if(spotifyTrack.getExternalUrls() == null) {
                    continue;
                }
                // Check if this song is already in db with the url
                String spotifyURL = spotifyTrack.getExternalUrls().get("spotify");

                Optional<Song> existingSongOpt = songRepository.findByUrl(spotifyURL);

                Song songEntity;
                if (existingSongOpt.isPresent()) {
                    // It's already in db, just use that one
                    songEntity = existingSongOpt.get();
                } else {
                    // new song, create and add it to db
                    songEntity = new Song();

                    songEntity.setArtist_name(spotifyTrack.getArtists()[0].getName());
                    songEntity.setName(spotifyTrack.getName());
                    songEntity.setUrl(spotifyTrack.getExternalUrls().get("spotify"));

                    songEntity = songRepository.save(songEntity);
                }

                savedSongs.add(songEntity);
            }
            // If search fails (Optional is empty), skip this track.
        }
    }
}

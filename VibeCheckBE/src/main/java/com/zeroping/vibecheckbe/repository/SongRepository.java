package com.zeroping.vibecheckbe.repository;

import com.zeroping.vibecheckbe.entity.Song;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SongRepository extends JpaRepository<Song, Long> {
    Optional<Song> findBySpotifyTrackId(String spotifyId);
}

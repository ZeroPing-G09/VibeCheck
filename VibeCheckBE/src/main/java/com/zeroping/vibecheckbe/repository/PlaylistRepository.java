package com.zeroping.vibecheckbe.repository;

import com.zeroping.vibecheckbe.entity.Playlist;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;
import java.util.List;

public interface PlaylistRepository extends JpaRepository<Playlist, Long> {
    // Allows retrieving all playlists created by a specific user
    List<Playlist> findByUserId(UUID userId);

    // Allows retrieving the playlists of a user sorted by creation date descending
    List<Playlist> findByUserIdOrderByCreatedAtDesc(UUID userId);

    // Returns the latest playlist for a user, if it exists
    Optional<Playlist> findFirstByUserIdOrderByCreatedAtDesc(UUID userId);

    // Count the number of playlists for a specific user
    long countByUserId(UUID userId);

    // Get distinct moods for a user
    List<String> findDistinctMoodByUserIdOrderByCreatedAtDesc(UUID userId);
}
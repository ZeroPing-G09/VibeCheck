package com.zeroping.vibecheckbe.repository;

import com.zeroping.vibecheckbe.entity.Playlist;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;
import java.util.List;

public interface PlaylistRepository extends JpaRepository<Playlist, Long> {
    // Allows retrieving all playlists created by a specific user
    List<Playlist> findByUserId(UUID userId);

    // Allows retrieving the playlists of a user sorted by creation date descending
    List<Playlist> findByUserIdOrderByCreatedAtDesc(UUID userId);
}
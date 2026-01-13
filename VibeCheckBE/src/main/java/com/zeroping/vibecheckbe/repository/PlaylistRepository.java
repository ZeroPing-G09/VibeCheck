package com.zeroping.vibecheckbe.repository;

import com.zeroping.vibecheckbe.entity.Playlist;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

// Repository interface for managing Playlist entities
@Repository
public interface PlaylistRepository extends JpaRepository<Playlist, Long> {
    // Allows retrieving the playlists of a user sorted by creation date descending
    List<Playlist> findByUserIdOrderByCreatedAtDesc(UUID userId);

    // Returns the latest playlist for a user, if it exists
    Optional<Playlist> findFirstByUserIdOrderByCreatedAtDesc(UUID userId);

    // Count the number of playlists for a specific user
    long countByUserId(UUID userId);

    // Get top distinct moods for a user
    @Query("SELECT DISTINCT p.mood FROM Playlist p WHERE p.userId = :userId ORDER BY p.createdAt DESC")
    List<String> findDistinctMoodByUserIdOrderByCreatedAtDesc(@Param("userId") UUID userId, Pageable pageable);

    @Query("SELECT p.createdAt FROM Playlist p WHERE p.userId = :userId ORDER BY p.createdAt DESC LIMIT 1")
    Optional<Instant> findLatestTimestamp(UUID userId);

    // Find playlists by userId and mood name
    List<Playlist> findByUserIdAndMood(UUID userId, String mood);

    // Returns the latest playlist for a user with a specific mood, if it exists
    Optional<Playlist> findFirstByUserIdAndMoodOrderByCreatedAtDesc(UUID userId, String mood);
    
    // Validates that a specific playlist belongs to a specific user
    Optional<Playlist> findByIdAndUserId(Long id, UUID userId);
}
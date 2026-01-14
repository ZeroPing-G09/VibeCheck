package com.zeroping.vibecheckbe.repository;

import com.zeroping.vibecheckbe.entity.Song;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

// Repository interface for managing Song entities
@Repository
public interface SongRepository extends JpaRepository<Song, Long> {
    // Returns the first song found with the given URL (handles duplicates)
    Optional<Song> findFirstByUrl(String url);
}

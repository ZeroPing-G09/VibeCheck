package com.zeroping.vibecheckbe.repository;

import com.zeroping.vibecheckbe.entity.Playlist;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlaylistRepository extends JpaRepository<Playlist,Long> {
}

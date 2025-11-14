package com.zeroping.vibecheckbe.repository;

import com.zeroping.vibecheckbe.entity.PlaylistSong;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlaylistSongRepository extends JpaRepository<PlaylistSong,Long> {
}

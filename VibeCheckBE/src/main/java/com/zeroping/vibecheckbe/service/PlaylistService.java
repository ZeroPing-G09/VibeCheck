package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.dto.PlaylistDTO;
import com.zeroping.vibecheckbe.entity.Playlist;
import com.zeroping.vibecheckbe.repository.PlaylistRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class PlaylistService {
    private final PlaylistRepository playlistRepository;

    public PlaylistService(PlaylistRepository playlistRepository) {
        this.playlistRepository = playlistRepository;
    }

    public List<String> getUserMoods(UUID userId) {
        // Returns the user moods sorted from newest to oldest
        return playlistRepository.findDistinctMoodByUserIdOrderByCreatedAtDesc(userId);
    }

    public long getNumberOfPlaylists(UUID userId) {
        return playlistRepository.countByUserId(userId);
    }

    public List<PlaylistDTO> getUserPlaylists(UUID userId) {
        List<Playlist> playlists = playlistRepository.findByUserIdOrderByCreatedAtDesc(userId);
        return playlists.stream()
                .map(this::mapToDTO)
                .toList();
    }

    public PlaylistDTO getLastPlaylist(UUID userId) {
        return playlistRepository.findFirstByUserIdOrderByCreatedAtDesc(userId)
                .map(this::mapToDTO)
                .orElse(null); // Or can throw exception
    }

    private PlaylistDTO mapToDTO(Playlist playlist) {
        PlaylistDTO dto = new PlaylistDTO();
        dto.setId(playlist.getId());
        dto.setName(playlist.getName());
        dto.setMood(playlist.getMood());
        dto.setCreatedAt(playlist.getCreatedAt());
        return dto;
    }
}

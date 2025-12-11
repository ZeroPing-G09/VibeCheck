package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.dto.PlaylistDTO;
import com.zeroping.vibecheckbe.dto.SongDTO;
import com.zeroping.vibecheckbe.entity.Playlist;
import com.zeroping.vibecheckbe.entity.Song;
import com.zeroping.vibecheckbe.repository.PlaylistRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class PlaylistService {
    private final PlaylistRepository playlistRepository;

    public PlaylistService(PlaylistRepository playlistRepository) {
        this.playlistRepository = playlistRepository;
    }

    public List<String> getUserMoods(UUID userId) {
        Pageable topThree = PageRequest.of(0, 3);
        return playlistRepository.findDistinctMoodByUserIdOrderByCreatedAtDesc(userId, topThree);
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

    public Instant getLastPlaylistTimestamp(UUID userId) {
        return playlistRepository.findLatestTimestamp(userId)
                .orElse(null); // return null if no playlists exist
    }

    public List<PlaylistDTO> getPlaylistsByMood(UUID userId, String mood) {
        List<Playlist> playlists = playlistRepository.findByUserIdAndMood(userId, mood);
        return playlists.stream()
                .map(this::mapToDTO)
                .toList();
    }

    private PlaylistDTO mapToDTO(Playlist playlist) {
        PlaylistDTO dto = new PlaylistDTO();
        dto.setId(playlist.getId());
        dto.setName(playlist.getName());
        dto.setMood(playlist.getMood());
        dto.setCreatedAt(playlist.getCreatedAt());
        dto.setUserId(playlist.getUserId());

        // Map songs if available
        if (playlist.getSongs() != null) {
            Set<SongDTO> songDTOs = playlist.getSongs().stream()
                    .map(this::mapToSongDTO)
                    .collect(Collectors.toSet());
            dto.setSongs(songDTOs);
        }

        return dto;
    }

    private SongDTO mapToSongDTO(Song song) {
        return new SongDTO(
                song.getId(),
                song.getName(),
                song.getUrl(),
                song.getArtistName()
        );
    }
}

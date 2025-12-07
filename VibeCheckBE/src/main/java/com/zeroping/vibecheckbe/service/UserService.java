package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.dto.LastPlaylistResponseDTO;
import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.entity.Playlist;
import com.zeroping.vibecheckbe.entity.User;
import com.zeroping.vibecheckbe.entity.Genre;
import com.zeroping.vibecheckbe.exception.genre.GenreNotFoundException;
import com.zeroping.vibecheckbe.exception.user.UserNotFoundException;
import com.zeroping.vibecheckbe.repository.PlaylistRepository;
import com.zeroping.vibecheckbe.repository.UserRepository;
import com.zeroping.vibecheckbe.repository.GenreRepository;
import org.springframework.dao.InvalidDataAccessResourceUsageException;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;
import java.util.UUID;
import java.util.stream.Stream;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final GenreRepository genreRepository;
    private final PlaylistRepository playlistRepository;

    public UserService(UserRepository userRepository, GenreRepository genreRepository, 
                       PlaylistRepository playlistRepository) {
        this.userRepository = userRepository;
        this.genreRepository = genreRepository;
        this.playlistRepository = playlistRepository;
    }

    public Map<String, Object> getUserById(UUID id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + id));

        return toUserResponse(user);
    }

    public Map<String, Object> getUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UserNotFoundException("User not found for email: " + email));

        return toUserResponse(user);
    }

    private Map<String, Object> toUserResponse(User user) {
        Map<String, Object> response = new HashMap<>();
        response.put("id", user.getId());
        response.put("email", user.getEmail());
        response.put("display_name", user.getDisplayName());
        response.put("avatar_url", user.getAvatarUrl());
        response.put("genres", extractGenres(user));
        return response;
    }

    private List<String> extractGenres(User user) {
        if (user.getGenres() == null || user.getGenres().isEmpty()) {
            return Collections.emptyList();
        }

        return user.getGenres()
                .stream()
                .map(Genre::getName)
                .limit(3)  // keep only top 3
                .collect(Collectors.toList());
    }

    private Genre resolveGenreOrNull(Long genreId) {
        if (genreId == null) return null;
        return genreRepository.findById(genreId)
                .orElseThrow(() -> new GenreNotFoundException("Genre not found: " + genreId));
    }

    public User updateUserPreferences(UUID userId, UserPreferencesDTO dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));

        // Collect the three genre IDs
        // Do this using streams or array as list
        List<Long> genreIds = Stream.of(
                        dto.getTop1GenreId(),
                        dto.getTop2GenreId(),
                        dto.getTop3GenreId()
                )
                .filter(Objects::nonNull)
                .toList();

        // Convert them to Genre entities, skip nulls, max 3
        Set<Genre> newGenres = genreIds.stream()
                .filter(Objects::nonNull)
                .map(this::resolveGenreOrNull)
                .filter(Objects::nonNull)
                .limit(3)
                .collect(Collectors.toCollection(LinkedHashSet::new));

        // Replace user genres
        user.setGenres(newGenres);

        return userRepository.save(user);
    }

    /**
     * Get the most recent playlist for a user.
     * 
     * @param userId The user's UUID
     * @return LastPlaylistResponseDTO with playlist info, or empty Optional if no playlist exists
     */
    public Optional<LastPlaylistResponseDTO> getLastPlaylist(UUID userId) {
        try {
            return playlistRepository.findFirstByUserIdOrderByCreatedAtDesc(userId)
                    .map(this::toLastPlaylistResponse);
        } catch (InvalidDataAccessResourceUsageException e) {
            // If database schema issue (e.g., missing column), treat as no playlist exists
            // This allows the app to work even if the database schema is incomplete
            return Optional.empty();
        }
    }

    private LastPlaylistResponseDTO toLastPlaylistResponse(Playlist playlist) {
        return new LastPlaylistResponseDTO(
                playlist.getSpotifyPlaylistId(),
                playlist.getName(),
                playlist.getCreatedAt()
        );
    }
}

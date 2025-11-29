package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.dto.UserUpdateDTO;
import com.zeroping.vibecheckbe.entity.User;
import com.zeroping.vibecheckbe.entity.Genre;
import com.zeroping.vibecheckbe.exception.genre.GenreNotFoundException;
import com.zeroping.vibecheckbe.exception.user.UserNotFoundException;
import com.zeroping.vibecheckbe.repository.UserRepository;
import com.zeroping.vibecheckbe.repository.GenreRepository;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;
import java.util.UUID;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final GenreRepository genreRepository;

    public UserService(UserRepository userRepository, GenreRepository genreRepository) {
        this.userRepository = userRepository;
        this.genreRepository = genreRepository;
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
        response.put("username", user.getDisplay_name());
        response.put("profile_picture", user.getAvatarUrl());
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
        List<Long> genreIds = List.of(
                dto.getTop1GenreId(),
                dto.getTop2GenreId(),
                dto.getTop3GenreId()
        );

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
}

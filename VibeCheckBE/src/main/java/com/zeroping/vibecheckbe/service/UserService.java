package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.entity.User;
import com.zeroping.vibecheckbe.entity.Genre;
import com.zeroping.vibecheckbe.exception.genre.GenreNotFoundException;
import com.zeroping.vibecheckbe.exception.user.GenreNotFoundForUserException;
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

    private static final int MAX_TOP_GENRES = 3;

    public UserService(UserRepository userRepository, GenreRepository genreRepository) {
        this.userRepository = userRepository;
        this.genreRepository = genreRepository;
    }

    public Map<String, Object> getUserById(UUID id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException(id.toString()));

        return toUserResponse(user);
    }

    public Map<String, Object> getUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UserNotFoundException("User not found for email: " + email));

        return toUserResponse(user);
    }

    public Map<String, Object> updateUser(UUID id, Map<String, Object> payload) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException(id.toString()));

        if (payload.containsKey("display_name")) {
            user.setDisplay_name((String) payload.get("display_name"));
        }
        if (payload.containsKey("email")) {
            user.setEmail((String) payload.get("email"));
        }

        if (payload.containsKey("genres")) {
            Object genresObj = payload.get("genres");
            List<String> genreNames;
            if (genresObj instanceof List<?>) {
                genreNames = ((List<?>) genresObj).stream()
                        .map(Object::toString)
                        .limit(MAX_TOP_GENRES)
                        .collect(Collectors.toList());
            } else {
                throw new IllegalArgumentException("`genres` must be a list of strings");
            }
            updateUserGenres(user, genreNames);
        }

        User saved = userRepository.save(user);
        return toUserResponse(saved);
    }

    private Map<String, Object> toUserResponse(User user) {
        List<String> genres = extractGenres(user);
        Map<String, Object> response = new HashMap<>();
        response.put("id", user.getId());
        response.put("email", user.getEmail());
        response.put("display_name", user.getDisplay_name());
        response.put("avatar_url", user.getAvatarUrl());
        response.put("genres", genres);
        return response;
    }

    private void updateUserGenres(User user, List<String> genreNames) {
        Set<Genre> genres = new LinkedHashSet<>();
        for (int genreIndex = 0; genreIndex < genreNames.size() && genreIndex < MAX_TOP_GENRES; genreIndex++) {
            String name = genreNames.get(genreIndex);
            Genre genre = genreRepository.findByNameIgnoreCase(name)
                    .orElseThrow(() -> new GenreNotFoundForUserException(name));
            genres.add(genre);
        }
        user.setGenres(genres);
    }

    private List<String> extractGenres(User user) {
        if (user.getGenres() == null || user.getGenres().isEmpty()) {
            return Collections.emptyList();
        }
        return user.getGenres().stream()
                .limit(MAX_TOP_GENRES)
                .map(Genre::getName)
                .collect(Collectors.toList());
    }

    private Genre resolveGenreOrNull(Long genreId) {
        if (genreId == null) return null;
        return genreRepository.findById(genreId)
                .orElseThrow(() -> new GenreNotFoundException("Genre not found: " + genreId));
    }

    public void updateUserPreferences(UserPreferencesDTO userPreferencesDTO) {
        UUID userId = userPreferencesDTO.getUserId();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));

        Genre top1 = resolveGenreOrNull(userPreferencesDTO.getTop1GenreId());
        Genre top2 = resolveGenreOrNull(userPreferencesDTO.getTop2GenreId());
        Genre top3 = resolveGenreOrNull(userPreferencesDTO.getTop3GenreId());

        Set<Genre> genres = new LinkedHashSet<>();
        if (top1 != null) genres.add(top1);
        if (top2 != null) genres.add(top2);
        if (top3 != null) genres.add(top3);

        // Ensure limit
        Set<Genre> limited = genres.stream().limit(MAX_TOP_GENRES).collect(Collectors.toCollection(LinkedHashSet::new));

        user.setGenres(limited);
        userRepository.save(user);
    }
}

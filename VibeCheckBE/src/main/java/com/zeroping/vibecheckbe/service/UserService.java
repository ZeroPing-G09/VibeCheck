package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.dto.UserDTO;
import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.dto.UserUpdateDTO;
import com.zeroping.vibecheckbe.entity.User;
import com.zeroping.vibecheckbe.entity.Genre;
import com.zeroping.vibecheckbe.exception.genre.GenreNotFoundException;
import com.zeroping.vibecheckbe.exception.user.UserNotFoundException;
import com.zeroping.vibecheckbe.repository.UserRepository;
import com.zeroping.vibecheckbe.repository.GenreRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;
import java.util.UUID;
import java.util.stream.Stream;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final GenreRepository genreRepository;

    public UserService(UserRepository userRepository, GenreRepository genreRepository) {
        this.userRepository = userRepository;
        this.genreRepository = genreRepository;
    }

    @Transactional(readOnly = true)
    public UserDTO getUserById(UUID id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + id));

        return toUserDTO(user);
    }

    @Transactional(readOnly = true)
    public UserDTO getUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UserNotFoundException("User not found for email: " + email));

        return toUserDTO(user);
    }

    private UserDTO toUserDTO(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setEmail(user.getEmail());
        dto.setDisplay_name(user.getDisplayName());
        dto.setAvatar_url(user.getAvatarUrl());
        dto.setGenres(extractGenres(user));
        return dto;
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

    @Transactional
    public User updateUserPreferences(UUID userId, UserPreferencesDTO dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));

        // Collect the three genre IDs
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

        // Replace user genres (this will update the user_genres junction table)
        user.setGenres(newGenres);

        return userRepository.save(user);
    }

    @Transactional
    public UserDTO updateUser(UUID userId, UserUpdateDTO updateDTO) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));

        // Update display name if provided
        if (updateDTO.getDisplay_name() != null && !updateDTO.getDisplay_name().trim().isEmpty()) {
            user.setDisplayName(updateDTO.getDisplay_name());
        }

        // Update avatar URL if provided
        if (updateDTO.getAvatar_url() != null) {
            // Allow empty string to clear avatar
            user.setAvatarUrl(updateDTO.getAvatar_url().trim().isEmpty() ? null : updateDTO.getAvatar_url());
        }

        // Update genres if provided (expecting list of genre names)
        if (updateDTO.getGenres() != null) {
            if (!updateDTO.getGenres().isEmpty()) {
                // Convert genre names to Genre entities
                Set<Genre> newGenres = updateDTO.getGenres().stream()
                        .map(name -> genreRepository.findByNameIgnoreCase(name)
                                .orElseThrow(() -> new GenreNotFoundException("Genre not found: " + name)))
                        .limit(3)
                        .collect(Collectors.toCollection(LinkedHashSet::new));
                user.setGenres(newGenres);
            } else {
                // Clear genres if empty list
                user.setGenres(new LinkedHashSet<>());
            }
        }

        User savedUser = userRepository.save(user);
        return toUserDTO(savedUser);
    }
}

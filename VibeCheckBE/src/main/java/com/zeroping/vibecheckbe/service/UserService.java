package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.dto.UserUpdateDTO;
import com.zeroping.vibecheckbe.entity.User;
import com.zeroping.vibecheckbe.entity.Genre;
import com.zeroping.vibecheckbe.exception.genre.GenreNotFoundException;
import com.zeroping.vibecheckbe.exception.user.GenreNotFoundForUserException;
import com.zeroping.vibecheckbe.exception.user.UserNotFoundException;
import com.zeroping.vibecheckbe.repository.UserRepository;
import com.zeroping.vibecheckbe.repository.GenreRepository;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final GenreRepository genreRepository;

    private static final int MAX_TOP_GENRES = 3;

    public UserService(UserRepository userRepository, GenreRepository genreRepository) {
        this.userRepository = userRepository;
        this.genreRepository = genreRepository;
    }

    public Map<String, Object> getUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException(id));

        return toUserResponse(user);
    }

    public Map<String, Object> getUserByEmail(String email) {
        Optional<User> userOpt = userRepository.findByEmail(email);
        User user;

        if (userOpt.isPresent()) {
            user = userOpt.get();
        } else {
            // Create new user if doesn't exist (for OAuth users)
            user = new User();
            user.setEmail(email);
            user.setUsername(email.contains("@") ? email.substring(0, email.indexOf("@")) : email); // Use email prefix as default username
            user.setPassword(""); // OAuth users don't have passwords
            user.setProfilePicture("");
            user = userRepository.save(user);
        }

        return toUserResponse(user);
    }

    public Map<String, Object> updateUser(Long id, UserUpdateDTO payload) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException(id));

        if (payload.getUsername() != null) {
            user.setUsername(payload.getUsername());
        }

        if (payload.getProfilePicture() != null) {
            user.setProfilePicture(payload.getProfilePicture());
        }

        User saved;

        if (payload.getPreferences() != null) {
            saved = updateUserPreferences(payload.getPreferences());
        } else {
            saved = userRepository.save(user);
        }

        return toUserResponse(saved);
    }


    private Map<String, Object> toUserResponse(User user) {
        List<String> genres = extractGenres(user);
        Map<String, Object> response = new HashMap<>();
        response.put("id", user.getId());
        response.put("email", user.getEmail());
        response.put("username", user.getUsername());
        response.put("profile_picture", user.getProfilePicture());
        response.put("genres", genres);
        return response;
    }

    private List<String> extractGenres(User user) {
        List<String> genres = new ArrayList<>();
        if (user.getTop1Genre() != null) genres.add(user.getTop1Genre().getName());
        if (user.getTop2Genre() != null) genres.add(user.getTop2Genre().getName());
        if (user.getTop3Genre() != null) genres.add(user.getTop3Genre().getName());
        return genres;
    }

    private Genre resolveGenreOrNull(Long genreId) {
        if (genreId == null) return null; // allow null genre
        return genreRepository.findById(genreId)
                .orElseThrow(() -> new GenreNotFoundException("Genre not found: " + genreId));
    }

    public User updateUserPreferences(UserPreferencesDTO userPreferencesDTO) {
        User user = userRepository.findById(userPreferencesDTO.getUserId())
                .orElseThrow(() -> new UserNotFoundException("User not found"));

        var top1Genre = resolveGenreOrNull(userPreferencesDTO.getTop1GenreId());
        var top2Genre = resolveGenreOrNull(userPreferencesDTO.getTop2GenreId());
        var top3Genre = resolveGenreOrNull(userPreferencesDTO.getTop3GenreId());

        user.setTop1Genre(top1Genre);
        user.setTop2Genre(top2Genre);
        user.setTop3Genre(top3Genre);

        return userRepository.save(user);
    }
}

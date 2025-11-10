package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.entity.User;
import com.zeroping.vibecheckbe.entity.Genre;
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

        List<String> genres = extractGenres(user);
        return Map.of(
                "username", user.getUsername(),
                "profile_picture", user.getProfilePicture(),
                "genres", genres
        );
    }

    public Map<String, Object> updateUser(Long id, Map<String, Object> payload) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException(id));

        if (payload.containsKey("username")) {
            user.setUsername((String) payload.get("username"));
        }
        if (payload.containsKey("profile_picture")) {
            user.setProfilePicture((String) payload.get("profile_picture"));
        }

        if (payload.containsKey("genres")) {
            List<String> genreNames = (List<String>) payload.get("genres");
            updateUserGenres(user, genreNames);
        }

        User saved = userRepository.save(user);
        List<String> genres = extractGenres(saved);

        return Map.of(
                "id", saved.getId(),
                "username", saved.getUsername(),
                "profile_picture", saved.getProfilePicture(),
                "genres", genres
        );
    }

    private void updateUserGenres(User user, List<String> genreNames) {
        user.setTop1Genre(null);
        user.setTop2Genre(null);
        user.setTop3Genre(null);

       for (int genreIndex = 0; genreIndex < genreNames.size() && genreIndex < MAX_TOP_GENRES; genreIndex++) {
            String name = genreNames.get(genreIndex);
            Genre genre = genreRepository.findByNameIgnoreCase(name)
                    .orElseThrow(() -> new GenreNotFoundForUserException(name));

            switch (genreIndex) {
                case 0 -> user.setTop1Genre(genre);
                case 1 -> user.setTop2Genre(genre);
                case 2 -> user.setTop3Genre(genre);
            }
        }
    }

    private List<String> extractGenres(User user) {
        List<String> genres = new ArrayList<>();
        if (user.getTop1Genre() != null) genres.add(user.getTop1Genre().getName());
        if (user.getTop2Genre() != null) genres.add(user.getTop2Genre().getName());
        if (user.getTop3Genre() != null) genres.add(user.getTop3Genre().getName());
        return genres;
    }
}

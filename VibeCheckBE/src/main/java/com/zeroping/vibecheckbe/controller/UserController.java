package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.entity.User;
import com.zeroping.vibecheckbe.repository.GenreRepository;
import com.zeroping.vibecheckbe.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;
import java.util.stream.Stream;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserRepository userRepository;
    private final GenreRepository genreRepository;

    public UserController(UserRepository userRepository, GenreRepository genreRepository) {
        this.userRepository = userRepository;
        this.genreRepository = genreRepository;
    }
    @GetMapping("/{id}")
    public ResponseEntity<?> getUser(@PathVariable Long id) {
        return userRepository.findById(id)
                .<ResponseEntity<?>>map(user -> {
                    List<String> topGenres = new ArrayList<>();
                    if (user.getTop1Genre() != null) topGenres.add(user.getTop1Genre().getName());
                    if (user.getTop2Genre() != null) topGenres.add(user.getTop2Genre().getName());
                    if (user.getTop3Genre() != null) topGenres.add(user.getTop3Genre().getName());

                    Map<String, Object> response = Map.of(
                            "username", user.getUsername(),
                            "profile_picture", user.getProfilePicture(),
                            "genres", topGenres
                    );

                    return ResponseEntity.ok(response);
                })
                .orElseGet(() -> ResponseEntity
                        .status(404)
                        .body(Map.of("message", "User not found")));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Long id, @RequestBody Map<String, Object> payload) {
        return userRepository.findById(id)
                .map(user -> {
                    if (payload.containsKey("username")) {
                        user.setUsername((String) payload.get("username"));
                    }
                    if (payload.containsKey("profile_picture")) {
                        user.setProfilePicture((String) payload.get("profile_picture"));
                    }

                    if (payload.containsKey("genres")) {
                        List<String> genreNames = (List<String>) payload.get("genres");
                        user.setTop1Genre(null);
                        user.setTop2Genre(null);
                        user.setTop3Genre(null);

                        for (int i = 0; i < genreNames.size() && i < 3; i++) {
                            int idx = i;
                            genreRepository.findByNameIgnoreCase(genreNames.get(i))
                                    .ifPresent(genre -> {
                                        switch (idx) {
                                            case 0 -> user.setTop1Genre(genre);
                                            case 1 -> user.setTop2Genre(genre);
                                            case 2 -> user.setTop3Genre(genre);
                                        }
                                    });
                        }
                    }

                    User saved = userRepository.save(user);

                    List<String> genres = new ArrayList<>();
                    if (saved.getTop1Genre() != null) genres.add(saved.getTop1Genre().getName());
                    if (saved.getTop2Genre() != null) genres.add(saved.getTop2Genre().getName());
                    if (saved.getTop3Genre() != null) genres.add(saved.getTop3Genre().getName());

                    Map<String, Object> response = Map.of(
                            "id", saved.getId(),
                            "username", saved.getUsername(),
                            "profile_picture", saved.getProfilePicture(),
                            "genres", genres
                    );

                    return ResponseEntity.ok(response);
                })
                .orElseGet(() -> ResponseEntity.status(404)
                        .body(Map.of("message", "User not found")));
    }
}

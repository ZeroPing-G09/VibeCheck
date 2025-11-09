package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
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
}

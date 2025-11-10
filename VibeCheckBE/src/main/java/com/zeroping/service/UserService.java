package com.zeroping.service;

import com.zeroping.dto.UserPreferencesDTO;
import com.zeroping.entity.User;
import com.zeroping.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    private final UserRepository userRepository;

    @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public void updateUserPreferences(UserPreferencesDTO userPreferencesDTO) {
        User user = userRepository.findById(userPreferencesDTO.getUserId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        user.setTop1GenreId(userPreferencesDTO.getTop1GenreId());
        user.setTop2GenreId(userPreferencesDTO.getTop2GenreId());
        user.setTop3GenreId(userPreferencesDTO.getTop3GenreId());

        userRepository.save(user);
    }
}
package com.zeroping.service;

import com.zeroping.dto.UserPreferencesDTO;
import com.zeroping.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {
    @Autowired
    private UserRepository userRepository; 

    public String updateUserPreferences(UserPreferencesDTO preferences) throws Exception {
        Integer userId = preferences.getUserId();

        int rowsAffected = userRepository.updatePreferences(userId, preferences);

        if (rowsAffected > 0) { 
            return "{\"success\": true, \"message\": \"Preferences updated successfully.\"}";
        } else {
            throw new Exception("User not found or preferences were unchanged.");
        }
    }
}
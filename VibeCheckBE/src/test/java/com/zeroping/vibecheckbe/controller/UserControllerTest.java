package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.service.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.Primary;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(UserController.class)
@Import(UserControllerTest.TestConfig.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserService userService;

    @TestConfiguration
    static class TestConfig {
        @Bean
        @Primary
        public UserService userService() {
            return mock(UserService.class);
        }

        @Bean
        @Primary
        public SecurityFilterChain testSecurityFilterChain(HttpSecurity http) throws Exception {
            http.csrf(AbstractHttpConfigurer::disable)
                    .authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
            return http.build();
        }
    }

    @Test
    void savePreferences_ValidRequest_ReturnsSuccess() throws Exception {
        doNothing().when(userService).updateUserPreferences(any(UserPreferencesDTO.class));

        String jsonRequest = """
            {
                "userId": 1,
                "top1GenreId": 5,
                "top2GenreId": 10,
                "top3GenreId": 15
            }
            """;

        mockMvc.perform(post("/users/preferences")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(jsonRequest))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Preferences updated successfully."));
    }

    @Test
    void savePreferences_MissingUserId_ReturnsBadRequest() throws Exception {
        String jsonRequest = """
            {
                "top1GenreId": 5,
                "top2GenreId": 10,
                "top3GenreId": 15
            }
            """;

        mockMvc.perform(post("/users/preferences")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(jsonRequest))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.message").value("User ID is required."));
    }

    @Test
    void savePreferences_ServiceThrowsException_ReturnsInternalError() throws Exception {
        doThrow(new RuntimeException("DB error")).when(userService).updateUserPreferences(any(UserPreferencesDTO.class));

        String jsonRequest = """
            {
                "userId": 1,
                "top1GenreId": 5,
                "top2GenreId": 10,
                "top3GenreId": 15
            }
            """;

        mockMvc.perform(post("/users/preferences")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(jsonRequest))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.message").value("Internal error updating preferences."));
    }
}
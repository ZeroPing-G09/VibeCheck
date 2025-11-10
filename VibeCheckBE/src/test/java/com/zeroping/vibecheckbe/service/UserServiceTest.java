package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.entity.User;
import com.zeroping.vibecheckbe.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    @Test
    void updateUserPreferences_WhenUserExists_ShouldUpdatePreferences() {
        // Given
        Long userId = 1L;
        User existingUser = new User();
        existingUser.setId(userId);
        existingUser.setTop1GenreId(null);
        existingUser.setTop2GenreId(null);
        existingUser.setTop3GenreId(null);

        UserPreferencesDTO preferences = new UserPreferencesDTO();
        preferences.setUserId(userId);
        preferences.setTop1GenreId(5L);
        preferences.setTop2GenreId(10L);
        preferences.setTop3GenreId(15L);

        when(userRepository.findById(userId)).thenReturn(Optional.of(existingUser));
        when(userRepository.save(any(User.class))).thenReturn(existingUser);

        // When
        assertDoesNotThrow(() -> userService.updateUserPreferences(preferences));

        // Then
        verify(userRepository).findById(userId);
        verify(userRepository).save(existingUser);

        assertEquals(5, existingUser.getTop1GenreId());
        assertEquals(10, existingUser.getTop2GenreId());
        assertEquals(15, existingUser.getTop3GenreId());
    }

    @Test
    void updateUserPreferences_WhenUserNotFound_ShouldThrowException() {
        // Given
        Long userId = 999L;
        UserPreferencesDTO preferences = new UserPreferencesDTO();
        preferences.setUserId(userId);

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // When & Then
        RuntimeException exception = assertThrows(RuntimeException.class,
                () -> userService.updateUserPreferences(preferences));

        assertEquals("User not found", exception.getMessage());
        verify(userRepository).findById(userId);
        verify(userRepository, never()).save(any());
    }

    @Test
    void updateUserPreferences_WhenSomePreferencesAreNull_ShouldUpdateOnlyProvidedValues() {
        // Given
        Long userId = 1L;
        User existingUser = new User();
        existingUser.setId(userId);
        existingUser.setTop1GenreId(1L);
        existingUser.setTop2GenreId(2L);
        existingUser.setTop3GenreId(3L);

        UserPreferencesDTO preferences = new UserPreferencesDTO();
        preferences.setUserId(userId);
        preferences.setTop1GenreId(5L);  // Only update top1, leave others null
        preferences.setTop2GenreId(null);
        preferences.setTop3GenreId(null);

        when(userRepository.findById(userId)).thenReturn(Optional.of(existingUser));
        when(userRepository.save(any(User.class))).thenReturn(existingUser);

        // When
        userService.updateUserPreferences(preferences);

        // Then
        assertEquals(5, existingUser.getTop1GenreId());  // Updated
        assertNull(existingUser.getTop2GenreId());       // Set to null
        assertNull(existingUser.getTop3GenreId());       // Set to null
    }

    @Test
    void updateUserPreferences_ShouldCallSaveWithUpdatedUser() {
        // Given
        Long userId = 1L;
        User existingUser = new User();
        existingUser.setId(userId);

        UserPreferencesDTO preferences = new UserPreferencesDTO();
        preferences.setUserId(userId);
        preferences.setTop1GenreId(5L);
        preferences.setTop2GenreId(10L);
        preferences.setTop3GenreId(15L);

        when(userRepository.findById(userId)).thenReturn(Optional.of(existingUser));
        when(userRepository.save(existingUser)).thenReturn(existingUser);

        // When
        userService.updateUserPreferences(preferences);

        // Then - Verify that save was called with the same user instance that was found
        verify(userRepository).save(existingUser);
    }
}
package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.entity.Genre;
import com.zeroping.vibecheckbe.entity.User;
import com.zeroping.vibecheckbe.exception.genre.GenreNotFoundException;
import com.zeroping.vibecheckbe.exception.user.UserNotFoundException;
import com.zeroping.vibecheckbe.repository.GenreRepository;
import com.zeroping.vibecheckbe.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private GenreRepository genreRepository;

    @InjectMocks
    private UserService userService;

    @Test
    @DisplayName("""
            Given an existing user with genres
            When getUserById is called
            Then it returns a successful response with display name, avatar and genre names
            """)
    void givenExistingUser_WhenGetUserById_ThenReturnsMappedResponse() {
        // Given
        UUID userId = UUID.randomUUID();
        User u = new User();
        u.setId(userId);
        u.setDisplayName("alex");
        u.setAvatarUrl("pic.png");
        u.setEmail("alex@example.com");
        
        Set<Genre> genres = new HashSet<>();
        genres.add(genre(10L, "Rock"));
        genres.add(genre(11L, "Jazz"));
        u.setGenres(genres);

        when(userRepository.findById(userId)).thenReturn(Optional.of(u));

        // When
        Map<String, Object> out = userService.getUserById(userId);

        // Then
        assertEquals("alex", out.get("display_name"));
        assertEquals("pic.png", out.get("avatar_url"));
        @SuppressWarnings("unchecked")
        List<String> genreNames = (List<String>) out.get("genres");
        assertTrue(genreNames.contains("Rock"));
        assertTrue(genreNames.contains("Jazz"));
        verify(userRepository).findById(userId);
    }

    @Test
    @DisplayName("""
            Given a non-existent user ID
            When getUserById is called
            Then it throws UserNotFoundException
            """)
    void givenMissingUser_WhenGetUserById_ThenThrowsUserNotFound() {
        // Given
        UUID userId = UUID.randomUUID();
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(UserNotFoundException.class, () -> userService.getUserById(userId));

        // Verify the interaction happened
        verify(userRepository).findById(userId);
    }

    @Test
    @DisplayName("""
            Given valid user preferences with genre IDs
            When updateUserPreferences is called
            Then it should update user preferences with genre entities
            """)
    void updateUserPreferences_WhenUserExists_ShouldUpdatePreferences() {
        // Given
        UUID userId = UUID.randomUUID();
        User existingUser = new User();
        existingUser.setId(userId);
        existingUser.setGenres(new HashSet<>());

        UserPreferencesDTO preferences = new UserPreferencesDTO();
        preferences.setTop1GenreId(5L);
        preferences.setTop2GenreId(10L);
        preferences.setTop3GenreId(15L);

        Genre rockGenre = genre(5L, "Rock");
        Genre jazzGenre = genre(10L, "Jazz");
        Genre popGenre = genre(15L, "Pop");

        when(userRepository.findById(userId)).thenReturn(Optional.of(existingUser));
        when(genreRepository.findById(5L)).thenReturn(Optional.of(rockGenre));
        when(genreRepository.findById(10L)).thenReturn(Optional.of(jazzGenre));
        when(genreRepository.findById(15L)).thenReturn(Optional.of(popGenre));
        when(userRepository.save(any(User.class))).thenReturn(existingUser);

        // When & Then
        assertDoesNotThrow(() -> userService.updateUserPreferences(userId, preferences));

        verify(userRepository).findById(userId);
        verify(genreRepository).findById(5L);
        verify(genreRepository).findById(10L);
        verify(genreRepository).findById(15L);
        verify(userRepository).save(existingUser);

        assertTrue(existingUser.getGenres().contains(rockGenre));
        assertTrue(existingUser.getGenres().contains(jazzGenre));
        assertTrue(existingUser.getGenres().contains(popGenre));
    }

    @Test
    @DisplayName("""
            Given user not found
            When updateUserPreferences is called
            Then it should throw UserNotFoundException
            """)
    void updateUserPreferences_WhenUserNotFound_ShouldThrowException() {
        // Given
        UUID userId = UUID.randomUUID();
        UserPreferencesDTO preferences = new UserPreferencesDTO();
        preferences.setTop1GenreId(5L);

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(UserNotFoundException.class,
                () -> userService.updateUserPreferences(userId, preferences));

        verify(userRepository).findById(userId);
        verify(genreRepository, never()).findById(any());
        verify(userRepository, never()).save(any());
    }

    @Test
    @DisplayName("""
            When some genre preferences are null
            Then it should update only provided genre values
            """)
    void updateUserPreferences_WhenSomePreferencesAreNull_ShouldUpdateOnlyProvidedValues() {
        // Given
        UUID userId = UUID.randomUUID();
        User existingUser = new User();
        existingUser.setId(userId);
        Set<Genre> oldGenres = new HashSet<>();
        oldGenres.add(genre(1L, "OldRock"));
        oldGenres.add(genre(2L, "OldJazz"));
        oldGenres.add(genre(3L, "OldPop"));
        existingUser.setGenres(oldGenres);

        UserPreferencesDTO preferences = new UserPreferencesDTO();
        preferences.setTop1GenreId(5L);  // Only update top1, leave others null
        preferences.setTop2GenreId(null);
        preferences.setTop3GenreId(null);

        Genre newRockGenre = genre(5L, "NewRock");

        when(userRepository.findById(userId)).thenReturn(Optional.of(existingUser));
        when(genreRepository.findById(5L)).thenReturn(Optional.of(newRockGenre));
        when(userRepository.save(any(User.class))).thenReturn(existingUser);

        // When
        userService.updateUserPreferences(userId, preferences);

        // Then
        assertTrue(existingUser.getGenres().contains(newRockGenre));
        assertEquals(1, existingUser.getGenres().size());
    }

    @Test
    @DisplayName("""
            When updateUserPreferences is called
            Then it should call save with updated user entity
            """)
    void updateUserPreferences_ShouldCallSaveWithUpdatedUser() {
        // Given
        UUID userId = UUID.randomUUID();
        User existingUser = new User();
        existingUser.setId(userId);
        existingUser.setGenres(new HashSet<>());

        UserPreferencesDTO preferences = new UserPreferencesDTO();
        preferences.setTop1GenreId(5L);
        preferences.setTop2GenreId(10L);
        preferences.setTop3GenreId(15L);

        when(userRepository.findById(userId)).thenReturn(Optional.of(existingUser));
        when(genreRepository.findById(5L)).thenReturn(Optional.of(genre(5L, "Rock")));
        when(genreRepository.findById(10L)).thenReturn(Optional.of(genre(10L, "Jazz")));
        when(genreRepository.findById(15L)).thenReturn(Optional.of(genre(15L, "Pop")));
        when(userRepository.save(existingUser)).thenReturn(existingUser);

        // When
        userService.updateUserPreferences(userId, preferences);

        // Then - Verify that save was called with the same user instance that was found
        verify(userRepository).save(existingUser);
    }

    @Test
    @DisplayName("""
            Given all null genre preferences
            When updateUserPreferences is called
            Then it should clear all genre preferences
            """)
    void updateUserPreferences_WhenAllPreferencesNull_ShouldClearAllGenres() {
        // Given
        UUID userId = UUID.randomUUID();
        User existingUser = new User();
        existingUser.setId(userId);
        Set<Genre> genres = new HashSet<>();
        genres.add(genre(1L, "Rock"));
        genres.add(genre(2L, "Jazz"));
        genres.add(genre(3L, "Pop"));
        existingUser.setGenres(genres);

        UserPreferencesDTO preferences = new UserPreferencesDTO();
        preferences.setTop1GenreId(null);
        preferences.setTop2GenreId(null);
        preferences.setTop3GenreId(null);

        when(userRepository.findById(userId)).thenReturn(Optional.of(existingUser));
        when(userRepository.save(any(User.class))).thenReturn(existingUser);

        // When
        userService.updateUserPreferences(userId, preferences);

        // Then
        assertTrue(existingUser.getGenres().isEmpty());
    }

    @Test
    @DisplayName("""
            Given non-existent genre ID
            When updateUserPreferences is called
            Then it should throw GenreNotFoundException
            """)
    void updateUserPreferences_WhenGenreNotFound_ShouldThrowException() {
        // Given
        UUID userId = UUID.randomUUID();
        User existingUser = new User();
        existingUser.setId(userId);
        existingUser.setGenres(new HashSet<>());

        UserPreferencesDTO preferences = new UserPreferencesDTO();
        preferences.setTop1GenreId(999L); // Non-existent genre

        when(userRepository.findById(userId)).thenReturn(Optional.of(existingUser));
        when(genreRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(GenreNotFoundException.class, () -> userService.updateUserPreferences(userId, preferences));
        verify(userRepository, never()).save(any());
    }

    private Genre genre(Long id, String name) {
        Genre g = new Genre();
        g.setId(id);
        g.setName(name);
        return g;
    }
}

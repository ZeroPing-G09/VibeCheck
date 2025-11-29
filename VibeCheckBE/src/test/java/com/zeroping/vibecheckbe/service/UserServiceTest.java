package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.dto.UserUpdateDTO;
import com.zeroping.vibecheckbe.entity.Genre;
import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.entity.User;
import com.zeroping.vibecheckbe.exception.genre.GenreNotFoundException;
import com.zeroping.vibecheckbe.exception.user.UserNotFoundException;
import com.zeroping.vibecheckbe.repository.GenreRepository;
import com.zeroping.vibecheckbe.repository.UserRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.*;
import java.util.Optional;

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
            Given an existing user with top genres
            When getUserById is called
            Then it returns a successful response with username, picture and genre names
            """)
    void givenExistingUser_WhenGetUserById_ThenReturnsMappedResponse() {
        // Given
        User u = new User();
        u.setId(1L);
        u.setUsername("alex");
        u.setProfilePicture("pic.png");
        u.setTop1Genre(genre(10L, "Rock"));
        u.setTop2Genre(genre(11L, "Jazz"));

        when(userRepository.findById(1L)).thenReturn(Optional.of(u));

        // When
        Map<String, Object> out = userService.getUserById(1L);

        // Then
        assertEquals("alex", out.get("username"));
        assertEquals("pic.png", out.get("profile_picture"));
        @SuppressWarnings("unchecked")
        List<String> genres = (List<String>) out.get("genres");
        assertEquals(List.of("Rock", "Jazz"), genres);
        verify(userRepository).findById(1L);
    }

    @Test
    @DisplayName("""
            Given a valid user and payload with username/picture/genres
            When updateUser is called
            Then it returns a successful response and persists the changes
            """)
    void givenValidPayload_WhenUpdateUser_ThenPersistsAndReturnsResponse() {
        // Given
        Long id = 1L;
        User existing = new User();
        existing.setId(id);
        existing.setUsername("old");
        existing.setProfilePicture("old.png");

        UserUpdateDTO payload = new UserUpdateDTO();
        payload.setUsername("newname");
        payload.setProfilePicture("new.png");

        UserPreferencesDTO prefs = new UserPreferencesDTO();
        prefs.setUserId(id);
        prefs.setTop1GenreId(1L);  // Rock
        prefs.setTop2GenreId(2L);  // Pop

        payload.setPreferences(prefs);

        when(userRepository.findById(id)).thenReturn(Optional.of(existing));
        when(genreRepository.findById(1L)).thenReturn(Optional.of(genre(1L, "Rock")));
        when(genreRepository.findById(2L)).thenReturn(Optional.of(genre(2L, "Pop")));

        when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));

        // When
        Map<String, Object> out = userService.updateUser(id, payload);

        // Then
        assertEquals("newname", out.get("username"));
        assertEquals("new.png", out.get("profile_picture"));
        @SuppressWarnings("unchecked")
        List<String> genres = (List<String>) out.get("genres");
        assertEquals(List.of("Rock", "Pop"), genres);

        ArgumentCaptor<User> captor = ArgumentCaptor.forClass(User.class);
        verify(userRepository, atLeast(1)).save(captor.capture());
        User saved = captor.getValue();
        assertEquals("newname", saved.getUsername());
        assertEquals("new.png", saved.getProfilePicture());
        assertEquals("Rock", saved.getTop1Genre().getName());
        assertEquals("Pop", saved.getTop2Genre().getName());
        assertNull(saved.getTop3Genre());
    }

    @Test
    @DisplayName("""
            Given existing top genres and no 'genres' key in payload
            When updateUser is called
            Then it returns a response preserving previous top genres
            """)
    void givenNoGenresKey_WhenUpdateUser_ThenPreservesExistingTopGenres() {
        // Given
        Long id = 5L;
        User u = new User();
        u.setId(id);
        u.setUsername("old");
        u.setTop1Genre(genre(1L, "Rock"));

        UserUpdateDTO payload = new UserUpdateDTO();
        payload.setUsername("kept");
        payload.setProfilePicture("x.png");

        payload.setPreferences(null);

        when(userRepository.findById(id)).thenReturn(Optional.of(u));
        when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));

        // When
        Map<String, Object> out = userService.updateUser(id, payload);

        // Then
        @SuppressWarnings("unchecked")
        List<String> genres = (List<String>) out.get("genres");
        assertEquals(List.of("Rock"), genres);
        verify(genreRepository, never()).findByNameIgnoreCase(anyString());
    }

    @Test
    @DisplayName("""
            Given a non-existent user ID
            When getUserById is called
            Then it throws UserNotFoundException
            """)
    void givenMissingUser_WhenGetUserById_ThenThrowsUserNotFound() {
        // Given
        when(userRepository.findById(99L)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(UserNotFoundException.class, () -> userService.getUserById(99L));

        // Verify the interaction happened
        verify(userRepository).findById(99L);
    }

    @Test
    @DisplayName("""
            Given a non-existent user ID
            When updateUser is called
            Then it throws UserNotFoundException and does not save
            """)
    void givenMissingUser_WhenUpdateUser_ThenThrowsUserNotFound() {
        // Given
        when(userRepository.findById(42L)).thenReturn(Optional.empty());

        UserUpdateDTO payload = new UserUpdateDTO();

        // When & Then
        assertThrows(UserNotFoundException.class, () -> userService.updateUser(42L, payload));

        // Verify the interaction happened
        verify(userRepository).findById(42L);
        verify(userRepository, never()).save(any());
    }

    @Test
    @DisplayName("""
            Given an invalid genre name in payload
            When updateUser is called
            Then it throws GenreNotFoundForUserException and does not save
            """)
    void givenInvalidGenre_WhenUpdateUser_ThenThrowsGenreNotFoundAndNoSave() {
        // Given
        Long id = 3L;
        User u = new User();
        u.setId(id);
        when(userRepository.findById(id)).thenReturn(Optional.of(u));

        UserUpdateDTO payload = new UserUpdateDTO();

        UserPreferencesDTO prefs = new UserPreferencesDTO();
        prefs.setUserId(id);
        prefs.setTop1GenreId(999L); // non-existent genre id
        payload.setPreferences(prefs);

        // Mock genre repo to return empty for the missing id
        when(genreRepository.findById(999L)).thenReturn(Optional.empty());

        // When / Then
        assertThrows(GenreNotFoundException.class,
                () -> userService.updateUser(id, payload));

        // Ensure we never saved the user
        verify(userRepository, never()).save(any());
    }

    private Genre genre(Long id, String name) {
        Genre g = new Genre();
        g.setId(id);
        g.setName(name);
        return g;
    }

    @Test
    @DisplayName("""
            Given valid user preferences with genre IDs
            When updateUserPreferences is called
            Then it should update user preferences with genre entities
            """)
    void updateUserPreferences_WhenUserExists_ShouldUpdatePreferences() {
        // Given
        Long userId = 1L;
        User existingUser = new User();
        existingUser.setId(userId);
        existingUser.setTop1Genre(null);
        existingUser.setTop2Genre(null);
        existingUser.setTop3Genre(null);

        UserPreferencesDTO preferences = new UserPreferencesDTO();
        preferences.setUserId(userId);
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
        assertDoesNotThrow(() -> userService.updateUserPreferences(preferences));

        verify(userRepository).findById(userId);
        verify(genreRepository).findById(5L);
        verify(genreRepository).findById(10L);
        verify(genreRepository).findById(15L);
        verify(userRepository).save(existingUser);

        assertEquals(rockGenre, existingUser.getTop1Genre());
        assertEquals(jazzGenre, existingUser.getTop2Genre());
        assertEquals(popGenre, existingUser.getTop3Genre());
    }

    @Test
    @DisplayName("""
            Given user not found
            When updateUserPreferences is called
            Then it should throw UserNotFoundException
            """)
    void updateUserPreferences_WhenUserNotFound_ShouldThrowException() {
        // Given
        Long userId = 999L;
        UserPreferencesDTO preferences = new UserPreferencesDTO();
        preferences.setUserId(userId);
        preferences.setTop1GenreId(5L);

        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // When & Then
        // Note: This test expects UserNotFoundException, not RuntimeException
        assertThrows(UserNotFoundException.class,
                () -> userService.updateUserPreferences(preferences));

        verify(userRepository).findById(userId);
        verify(genreRepository, never()).findById(any());
        verify(userRepository, never()).save(any());
    }

    @Test
    @DisplayName("""
            When some genre preferences are null
            Then it should update only provided genre values and set others to null
            """)
    void updateUserPreferences_WhenSomePreferencesAreNull_ShouldUpdateOnlyProvidedValues() {
        // Given
        Long userId = 1L;
        User existingUser = new User();
        existingUser.setId(userId);
        existingUser.setTop1Genre(genre(1L, "OldRock"));
        existingUser.setTop2Genre(genre(2L, "OldJazz"));
        existingUser.setTop3Genre(genre(3L, "OldPop"));

        UserPreferencesDTO preferences = new UserPreferencesDTO();
        preferences.setUserId(userId);
        preferences.setTop1GenreId(5L);  // Only update top1, leave others null
        preferences.setTop2GenreId(null);
        preferences.setTop3GenreId(null);

        Genre newRockGenre = genre(5L, "NewRock");

        when(userRepository.findById(userId)).thenReturn(Optional.of(existingUser));
        when(genreRepository.findById(5L)).thenReturn(Optional.of(newRockGenre));
        when(userRepository.save(any(User.class))).thenReturn(existingUser);

        // When
        userService.updateUserPreferences(preferences);

        // Then
        assertEquals(newRockGenre, existingUser.getTop1Genre());  // Updated
        assertNull(existingUser.getTop2Genre());                  // Set to null
        assertNull(existingUser.getTop3Genre());                  // Set to null
    }

    @Test
    @DisplayName("""
            When updateUserPreferences is called
            Then it should call save with updated user entity
            """)
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
        when(genreRepository.findById(5L)).thenReturn(Optional.of(genre(5L, "Rock")));
        when(genreRepository.findById(10L)).thenReturn(Optional.of(genre(10L, "Jazz")));
        when(genreRepository.findById(15L)).thenReturn(Optional.of(genre(15L, "Pop")));
        when(userRepository.save(existingUser)).thenReturn(existingUser);

        // When
        userService.updateUserPreferences(preferences);

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
        Long userId = 1L;
        User existingUser = new User();
        existingUser.setId(userId);
        existingUser.setTop1Genre(genre(1L, "Rock"));
        existingUser.setTop2Genre(genre(2L, "Jazz"));
        existingUser.setTop3Genre(genre(3L, "Pop"));

        UserPreferencesDTO preferences = new UserPreferencesDTO();
        preferences.setUserId(userId);
        preferences.setTop1GenreId(null);
        preferences.setTop2GenreId(null);
        preferences.setTop3GenreId(null);

        when(userRepository.findById(userId)).thenReturn(Optional.of(existingUser));
        when(userRepository.save(any(User.class))).thenReturn(existingUser);

        // When
        userService.updateUserPreferences(preferences);

        // Then
        assertNull(existingUser.getTop1Genre());
        assertNull(existingUser.getTop2Genre());
        assertNull(existingUser.getTop3Genre());
    }

    @Test
    @DisplayName("""
            Given non-existent genre ID
            When updateUserPreferences is called
            Then it should throw GenreNotFoundException
            """)
    void updateUserPreferences_WhenGenreNotFound_ShouldThrowException() {
        // Given
        Long userId = 1L;
        User existingUser = new User();
        existingUser.setId(userId);

        UserPreferencesDTO preferences = new UserPreferencesDTO();
        preferences.setUserId(userId);
        preferences.setTop1GenreId(999L); // Non-existent genre

        when(userRepository.findById(userId)).thenReturn(Optional.of(existingUser));
        when(genreRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        assertThrows(GenreNotFoundException.class, () -> userService.updateUserPreferences(preferences));
        verify(userRepository, never()).save(any());
    }
}
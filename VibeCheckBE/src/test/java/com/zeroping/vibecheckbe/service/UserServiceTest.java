package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.entity.Genre;
import com.zeroping.vibecheckbe.entity.User;
import com.zeroping.vibecheckbe.exception.user.GenreNotFoundForUserException;
import com.zeroping.vibecheckbe.exception.user.UserNotFoundException;
import com.zeroping.vibecheckbe.repository.GenreRepository;
import com.zeroping.vibecheckbe.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private GenreRepository genreRepository;

    @InjectMocks
    private UserService userService;

    @BeforeEach
    void init() {
        MockitoAnnotations.openMocks(this);
    }

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

        Map<String, Object> payload = new HashMap<>();
        payload.put("username", "newname");
        payload.put("profile_picture", "new.png");
        payload.put("genres", List.of("Rock", "Pop"));

        when(userRepository.findById(id)).thenReturn(Optional.of(existing));
        when(genreRepository.findByNameIgnoreCase("Rock")).thenReturn(Optional.of(genre(1L, "Rock")));
        when(genreRepository.findByNameIgnoreCase("Pop")).thenReturn(Optional.of(genre(2L, "Pop")));

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
        verify(userRepository).save(captor.capture());
        User saved = captor.getValue();
        assertEquals("newname", saved.getUsername());
        assertEquals("new.png", saved.getProfilePicture());
        assertEquals("Rock", saved.getTop1Genre().getName());
        assertEquals("Pop", saved.getTop2Genre().getName());
        assertNull(saved.getTop3Genre());
    }

    @Test
    @DisplayName("""
            Given more than 3 genre names
            When updateUser is called
            Then it returns only the first 3 genres and ignores the rest
            """)
    void givenMoreThanThreeGenres_WhenUpdateUser_ThenOnlyFirstThreeApplied() {
        // Given
        Long id = 7L;
        User u = new User();
        u.setId(id);

        List<String> names = List.of("Rock", "Pop", "Jazz", "HipHop"); // 4 names

        Map<String, Object> payload = Map.of("genres", names);

        when(userRepository.findById(id)).thenReturn(Optional.of(u));
        when(genreRepository.findByNameIgnoreCase("Rock")).thenReturn(Optional.of(genre(1L, "Rock")));
        when(genreRepository.findByNameIgnoreCase("Pop")).thenReturn(Optional.of(genre(2L, "Pop")));
        when(genreRepository.findByNameIgnoreCase("Jazz")).thenReturn(Optional.of(genre(3L, "Jazz")));

        when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));

        // When
        Map<String, Object> out = userService.updateUser(id, payload);

        // Then
        @SuppressWarnings("unchecked")
        List<String> genres = (List<String>) out.get("genres");
        assertEquals(List.of("Rock", "Pop", "Jazz"), genres);
        verify(genreRepository, never()).findByNameIgnoreCase("HipHop");
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

        Map<String, Object> payload = Map.of("username", "kept", "profile_picture", "x.png");

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
        when(userRepository.findById(99L)).thenReturn(Optional.empty());
        assertThrows(UserNotFoundException.class, () -> userService.getUserById(99L));
        verify(userRepository).findById(99L);
    }

    @Test
    @DisplayName("""
            Given a non-existent user ID
            When updateUser is called
            Then it throws UserNotFoundException and does not save
            """)
    void givenMissingUser_WhenUpdateUser_ThenThrowsUserNotFound() {
        when(userRepository.findById(42L)).thenReturn(Optional.empty());
        assertThrows(UserNotFoundException.class, () -> userService.updateUser(42L, Map.of()));
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

        Map<String, Object> payload = Map.of("genres", List.of("NarniaCore"));

        when(userRepository.findById(id)).thenReturn(Optional.of(u));
        when(genreRepository.findByNameIgnoreCase("NarniaCore")).thenReturn(Optional.empty());

        // When / Then
        assertThrows(GenreNotFoundForUserException.class, () -> userService.updateUser(id, payload));
        verify(userRepository, never()).save(any());
    }

    private Genre genre(Long id, String name) {
        Genre g = new Genre();
        g.setId(id);
        g.setName(name);
        return g;
    }
}

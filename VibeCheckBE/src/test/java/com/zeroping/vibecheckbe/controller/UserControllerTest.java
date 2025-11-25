package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.UserUpdateDTO;
import com.zeroping.vibecheckbe.entity.Genre;
import com.zeroping.vibecheckbe.entity.User;
import com.zeroping.vibecheckbe.exception.user.GenreNotFoundForUserException;
import com.zeroping.vibecheckbe.exception.user.UserNotFoundException;
import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class UserControllerTest {

    @Mock
    private UserService userService;

    @InjectMocks
    private UserController userController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    @DisplayName("""
            Given a valid user ID
            When getUser is called
            Then it returns a successful response with user details
            """)
    void givenValidId_WhenGetUserIsCalled_ThenReturnsUserDetails() {
        // Given
        Map<String, Object> mockUser = Map.of(
                "id", 1L,
                "username", "Andreea",
                "profile_picture", "andreea.png",
                "genres", List.of("Pop", "Jazz")
        );

        when(userService.getUserById(1L)).thenReturn(mockUser);

        // When
        ResponseEntity<Map<String, Object>> response = userController.getUser(1L);

        // Then
        assertEquals(200, response.getStatusCode().value());
        assertNotNull(response.getBody());
        assertEquals("Andreea", response.getBody().get("username"));
        assertEquals(List.of("Pop", "Jazz"), response.getBody().get("genres"));
        verify(userService, times(1)).getUserById(1L);
    }

    @Test
    @DisplayName("""
            Given a valid ID and valid payload
            When updateUser is called
            Then it returns a successful response with updated details
            """)
    void givenValidIdAndPayload_WhenUpdateUserIsCalled_ThenReturnsUpdatedUser() {
        // Given
        Long userId = 1L;

        UserUpdateDTO payload = new UserUpdateDTO();
        payload.setUsername("UpdatedUser");
        payload.setProfilePicture("updated.png");

        UserPreferencesDTO prefs = new UserPreferencesDTO();
        prefs.setUserId(userId);
        prefs.setTop1GenreId(1L); // Rock
        prefs.setTop2GenreId(2L); // Pop
        payload.setPreferences(prefs);

        // Mocked response from service
        Map<String, Object> updatedUser = Map.of(
                "id", 1L,
                "username", "UpdatedUser",
                "profile_picture", "updated.png", // make sure key matches toUserResponse
                "genres", List.of("Rock", "Pop")
        );

        when(userService.updateUser(userId, payload)).thenReturn(updatedUser);

        // When
        ResponseEntity<?> response = userController.updateUser(userId, payload);

        // Then
        assertNotNull(response.getBody());

        @SuppressWarnings("unchecked")
        Map<String, Object> body = (Map<String, Object>) response.getBody();

        assertEquals("UpdatedUser", body.get("username"));
        assertEquals("updated.png", body.get("profile_picture"));

        @SuppressWarnings("unchecked")
        List<String> genres = (List<String>) body.get("genres");
        assertEquals(List.of("Rock", "Pop"), genres);

        // Verify service call
        verify(userService, times(1)).updateUser(userId, payload);
    }

    @Test
    @DisplayName("""
            Given an invalid user ID
            When getUser is called
            Then it returns a 404 not found error
            """)
    void givenInvalidId_WhenGetUserIsCalled_ThenThrowsUserNotFoundException() {
        // Given
        Long invalidId = 999L;
        when(userService.getUserById(invalidId)).thenThrow(new UserNotFoundException(invalidId));

        // When / Then
        UserNotFoundException exception = assertThrows(
                UserNotFoundException.class,
                () -> userController.getUser(invalidId)
        );

        assertTrue(exception.getMessage().contains("999"));
        verify(userService, times(1)).getUserById(invalidId);
    }

    @Test
    @DisplayName("""
            Given a valid user ID but invalid genres
            When updateUser is called
            Then it returns a 400 bad request error
            """)
    void givenInvalidGenres_WhenUpdateUserIsCalled_ThenThrowsGenreNotFoundForUserException() {
        // Given
        Long userId = 1L;

        // Build DTO payload instead of Map
        UserUpdateDTO invalidPayload = new UserUpdateDTO();
        invalidPayload.setUsername("TestUser");

        UserPreferencesDTO prefs = new UserPreferencesDTO();
        prefs.setUserId(userId);
        prefs.setTop1GenreId(999L); // invalid/non-existent genre ID
        invalidPayload.setPreferences(prefs);

        // Mock service to throw the exception when called with this payload
        when(userService.updateUser(userId, invalidPayload))
                .thenThrow(new GenreNotFoundForUserException("Genre not found: 999"));

        // When / Then
        GenreNotFoundForUserException exception = assertThrows(
                GenreNotFoundForUserException.class,
                () -> userController.updateUser(userId, invalidPayload)
        );

        assertTrue(exception.getMessage().contains("999"));

        // Verify service was called once with the DTO
        verify(userService, times(1)).updateUser(userId, invalidPayload);
    }

    @Test
    @DisplayName("""
            Given a non-numeric ID input
            When calling getUser
            Then it returns a type conversion error before service execution
            """)
    void givenInvalidTypeId_WhenGetUserIsCalled_ThenThrowsException() {
        assertThrows(NumberFormatException.class, () -> {
            Long invalidId = Long.valueOf("abc");
            userController.getUser(invalidId);
        });

        verify(userService, never()).getUserById(any());
    }

    @Test
    @DisplayName("""
        Given a valid preferences payload
        When savePreferences is called
        Then it returns a success message
        """)
    void givenValidPreferences_WhenSavePreferencesIsCalled_ThenReturnsSuccess() {
// Given
        UserPreferencesDTO dto = new UserPreferencesDTO();
        dto.setUserId(1L);
        dto.setTop1GenreId(5L);
        dto.setTop2GenreId(10L);
        dto.setTop3GenreId(15L);

        User mockUser = new User();
        mockUser.setId(1L);
        mockUser.setTop1Genre(new Genre(5L, "Genre5"));
        mockUser.setTop2Genre(new Genre(10L, "Genre10"));
        mockUser.setTop3Genre(new Genre(15L, "Genre15"));

        when(userService.updateUserPreferences(any(UserPreferencesDTO.class)))
                .thenReturn(mockUser);  // return the mocked User

        // When
        ResponseEntity<Map<String, Object>> response = userController.savePreferences(dto);

        // Then
        assertEquals(200, response.getStatusCode().value());
        assertNotNull(response.getBody());
        assertTrue((Boolean) response.getBody().get("success"));
        assertEquals("Preferences updated successfully.", response.getBody().get("message"));

        verify(userService, times(1)).updateUserPreferences(any(UserPreferencesDTO.class));
    }

    @Test
    @DisplayName("""
        Given a preferences payload without userId
        When savePreferences is called
        Then it returns a bad request error
        """)
    void givenMissingUserId_WhenSavePreferencesIsCalled_ThenReturnsBadRequest() {
        // Given
        UserPreferencesDTO dto = new UserPreferencesDTO();
        dto.setTop1GenreId(5L);
        dto.setTop2GenreId(10L);
        dto.setTop3GenreId(15L);

        // When
        ResponseEntity<Map<String, Object>> response = userController.savePreferences(dto);

        // Then
        assertEquals(400, response.getStatusCode().value());
        assertNotNull(response.getBody());
        assertFalse((Boolean) response.getBody().get("success"));
        assertEquals("User ID is required.", response.getBody().get("message"));
        verify(userService, never()).updateUserPreferences(any());
    }

    @Test
    @DisplayName("""
        Given a valid preferences payload
        When the service throws an exception
        Then it returns internal server error
        """)
    void givenValidPreferences_WhenServiceThrowsException_ThenReturnsInternalError() {
        // Given
        UserPreferencesDTO dto = new UserPreferencesDTO();
        dto.setUserId(1L);
        dto.setTop1GenreId(5L);
        dto.setTop2GenreId(10L);
        dto.setTop3GenreId(15L);

        doThrow(new RuntimeException("DB error"))
                .when(userService).updateUserPreferences(any(UserPreferencesDTO.class));

        // When
        ResponseEntity<Map<String, Object>> response = userController.savePreferences(dto);

        // Then
        assertEquals(500, response.getStatusCode().value());
        assertNotNull(response.getBody());
        assertFalse((Boolean) response.getBody().get("success"));
        assertEquals("Internal error updating preferences.", response.getBody().get("message"));
        verify(userService, times(1)).updateUserPreferences(any());
    }
}

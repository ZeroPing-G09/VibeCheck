package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
import com.zeroping.vibecheckbe.exception.user.UserNotFoundException;
import com.zeroping.vibecheckbe.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
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
        UUID userId = UUID.randomUUID();
        Map<String, Object> mockUser = Map.of(
                "id", userId,
                "display_name", "Andreea",
                "avatar_url", "andreea.png",
                "email", "andreea@example.com",
                "genres", List.of("Pop", "Jazz")
        );

        when(userService.getUserById(userId)).thenReturn(mockUser);

        // When
        ResponseEntity<Map<String, Object>> response = userController.getUser(userId);

        // Then
        assertEquals(200, response.getStatusCode().value());
        assertNotNull(response.getBody());
        assertEquals("Andreea", response.getBody().get("display_name"));
        assertEquals(List.of("Pop", "Jazz"), response.getBody().get("genres"));
        verify(userService, times(1)).getUserById(userId);
    }

    @Test
    @DisplayName("""
            Given an invalid user ID
            When getUser is called
            Then it throws UserNotFoundException
            """)
    void givenInvalidId_WhenGetUserIsCalled_ThenThrowsUserNotFoundException() {
        // Given
        UUID invalidId = UUID.randomUUID();
        when(userService.getUserById(invalidId)).thenThrow(new UserNotFoundException("User not found: " + invalidId));

        // When / Then
        UserNotFoundException exception = assertThrows(
                UserNotFoundException.class,
                () -> userController.getUser(invalidId)
        );

        assertTrue(exception.getMessage().contains(invalidId.toString()));
        verify(userService, times(1)).getUserById(invalidId);
    }

    @Test
    @DisplayName("""
            Given a valid user email
            When getUserByEmail is called
            Then it returns a successful response with user details
            """)
    void givenValidEmail_WhenGetUserByEmailIsCalled_ThenReturnsUserDetails() {
        // Given
        String email = "test@example.com";
        Map<String, Object> mockUser = Map.of(
                "id", UUID.randomUUID(),
                "display_name", "Test User",
                "avatar_url", "avatar.png",
                "email", email,
                "genres", List.of("Rock", "Pop")
        );

        when(userService.getUserByEmail(email)).thenReturn(mockUser);

        // When
        ResponseEntity<Map<String, Object>> response = userController.getUserByEmail(email);

        // Then
        assertEquals(200, response.getStatusCode().value());
        assertNotNull(response.getBody());
        assertEquals("Test User", response.getBody().get("display_name"));
        assertEquals(email, response.getBody().get("email"));
        assertEquals(List.of("Rock", "Pop"), response.getBody().get("genres"));
        verify(userService, times(1)).getUserByEmail(email);
    }

    @Test
    @DisplayName("""
            Given an invalid user email
            When getUserByEmail is called
            Then it throws UserNotFoundException
            """)
    void givenInvalidEmail_WhenGetUserByEmailIsCalled_ThenThrowsUserNotFoundException() {
        // Given
        String email = "nonexistent@example.com";
        when(userService.getUserByEmail(email)).thenThrow(new UserNotFoundException("User not found for email: " + email));

        // When / Then
        UserNotFoundException exception = assertThrows(
                UserNotFoundException.class,
                () -> userController.getUserByEmail(email)
        );

        assertTrue(exception.getMessage().contains(email));
        verify(userService, times(1)).getUserByEmail(email);
    }

    @Test
    @DisplayName("""
            Given a valid user ID and update data
            When updateUser is called with matching authenticated user
            Then it returns updated user data
            """)
    void givenValidUpdateData_WhenUpdateUserIsCalled_ThenReturnsUpdatedUser() {
        // Given
        UUID userId = UUID.randomUUID();
        Map<String, Object> updateData = Map.of(
                "display_name", "UpdatedName",
                "avatar_url", "new-avatar.png",
                "genres", List.of("Rock", "Jazz")
        );
        Map<String, Object> updatedUser = Map.of(
                "id", userId,
                "display_name", "UpdatedName",
                "avatar_url", "new-avatar.png",
                "email", "test@example.com",
                "genres", List.of("Rock", "Jazz")
        );

        // Mock SecurityContext
        Authentication authentication = mock(Authentication.class);
        SecurityContext securityContext = mock(SecurityContext.class);
        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.getName()).thenReturn(userId.toString());
        SecurityContextHolder.setContext(securityContext);

        when(userService.updateUser(eq(userId), any(Map.class))).thenReturn(updatedUser);

        // When
        ResponseEntity<Map<String, Object>> response = userController.updateUser(userId, updateData);

        // Then
        assertEquals(200, response.getStatusCode().value());
        assertNotNull(response.getBody());
        assertEquals("UpdatedName", response.getBody().get("display_name"));
        verify(userService, times(1)).updateUser(eq(userId), any(Map.class));
    }

    @Test
    @DisplayName("""
            Given a user ID that doesn't match authenticated user
            When updateUser is called
            Then it returns 403 Forbidden
            """)
    void givenMismatchedUserId_WhenUpdateUserIsCalled_ThenReturnsForbidden() {
        // Given
        UUID requestedUserId = UUID.randomUUID();
        UUID authenticatedUserId = UUID.randomUUID();
        Map<String, Object> updateData = Map.of("display_name", "UpdatedName");

        // Mock SecurityContext with different user ID
        Authentication authentication = mock(Authentication.class);
        SecurityContext securityContext = mock(SecurityContext.class);
        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.getName()).thenReturn(authenticatedUserId.toString());
        SecurityContextHolder.setContext(securityContext);

        // When
        ResponseEntity<Map<String, Object>> response = userController.updateUser(requestedUserId, updateData);

        // Then
        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().containsKey("error"));
        verify(userService, never()).updateUser(any(), any());
    }

    @Test
    @DisplayName("""
            Given a valid preferences payload
            When savePreferences is called
            Then it returns a success message
            """)
    void givenValidPreferences_WhenSavePreferencesIsCalled_ThenReturnsSuccess() {
        // Given
        UUID userId = UUID.randomUUID();
        UserPreferencesDTO dto = new UserPreferencesDTO();
        dto.setTop1GenreId(5L);
        dto.setTop2GenreId(10L);
        dto.setTop3GenreId(15L);

        // Mock SecurityContext
        Authentication authentication = mock(Authentication.class);
        SecurityContext securityContext = mock(SecurityContext.class);
        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.getName()).thenReturn(userId.toString());
        SecurityContextHolder.setContext(securityContext);

        // When
        ResponseEntity<Map<String, Object>> response = userController.savePreferences(dto);

        // Then
        assertEquals(200, response.getStatusCode().value());
        assertNotNull(response.getBody());
        assertTrue((Boolean) response.getBody().get("success"));
        assertEquals("Preferences updated successfully.", response.getBody().get("message"));

        verify(userService, times(1)).updateUserPreferences(eq(userId), any(UserPreferencesDTO.class));
    }
}

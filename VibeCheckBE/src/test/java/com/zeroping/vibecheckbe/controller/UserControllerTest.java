package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.dto.*;
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
        UserDTO mockUser = new UserDTO();
        mockUser.setId(userId);
        mockUser.setDisplay_name("Andreea");
        mockUser.setAvatar_url("andreea.png");
        mockUser.setEmail("andreea@example.com");
        mockUser.setGenres(List.of("Pop", "Jazz"));

        when(userService.getUserById(userId)).thenReturn(mockUser);

        // When
        ResponseEntity<UserDTO> response = userController.getUser(userId);

        // Then
        assertEquals(200, response.getStatusCode().value());
        assertNotNull(response.getBody());
        assertEquals("Andreea", response.getBody().getDisplay_name());
        assertEquals(List.of("Pop", "Jazz"), response.getBody().getGenres());
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
        UUID userId = UUID.randomUUID();
        UserDTO mockUser = new UserDTO();
        mockUser.setId(userId);
        mockUser.setDisplay_name("Test User");
        mockUser.setAvatar_url("avatar.png");
        mockUser.setEmail(email);
        mockUser.setGenres(List.of("Rock", "Pop"));

        when(userService.getUserByEmail(email)).thenReturn(mockUser);

        // When
        ResponseEntity<UserDTO> response = userController.getUserByEmail(email);

        // Then
        assertEquals(200, response.getStatusCode().value());
        assertNotNull(response.getBody());
        assertEquals("Test User", response.getBody().getDisplay_name());
        assertEquals(email, response.getBody().getEmail());
        assertEquals(List.of("Rock", "Pop"), response.getBody().getGenres());
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
        UserUpdateDTO updateDTO = new UserUpdateDTO();
        updateDTO.setDisplay_name("UpdatedName");
        updateDTO.setAvatar_url("new-avatar.png");
        updateDTO.setGenres(List.of("Rock", "Jazz"));
        
        UserDTO updatedUserDTO = new UserDTO();
        updatedUserDTO.setId(userId);
        updatedUserDTO.setDisplay_name("UpdatedName");
        updatedUserDTO.setAvatar_url("new-avatar.png");
        updatedUserDTO.setEmail("test@example.com");
        updatedUserDTO.setGenres(List.of("Rock", "Jazz"));

        // Mock SecurityContext
        Authentication authentication = mock(Authentication.class);
        SecurityContext securityContext = mock(SecurityContext.class);
        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.getName()).thenReturn(userId.toString());
        SecurityContextHolder.setContext(securityContext);

        when(userService.updateUser(eq(userId), any(UserUpdateDTO.class))).thenReturn(updatedUserDTO);

        // When
        ResponseEntity<?> response = userController.updateUser(userId, updateDTO);

        // Then
        assertEquals(200, response.getStatusCode().value());
        assertNotNull(response.getBody());
        assertTrue(response.getBody() instanceof UserDTO);
        UserDTO responseBody = (UserDTO) response.getBody();
        assertEquals("UpdatedName", responseBody.getDisplay_name());
        verify(userService, times(1)).updateUser(eq(userId), any(UserUpdateDTO.class));
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
        UserUpdateDTO updateDTO = new UserUpdateDTO();
        updateDTO.setDisplay_name("UpdatedName");

        // Mock SecurityContext with different user ID
        Authentication authentication = mock(Authentication.class);
        SecurityContext securityContext = mock(SecurityContext.class);
        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.getName()).thenReturn(authenticatedUserId.toString());
        SecurityContextHolder.setContext(securityContext);

        // When
        ResponseEntity<?> response = userController.updateUser(requestedUserId, updateDTO);

        // Then
        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        assertNotNull(response.getBody());
        assertTrue(response.getBody() instanceof Map);
        @SuppressWarnings("unchecked")
        Map<String, Object> responseBody = (Map<String, Object>) response.getBody();
        assertTrue(responseBody.containsKey("error"));
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

    @Test
    @DisplayName("""
        Given a valid feedback request
        When SavePlaylistFeedback is called
        Then it returns 200 OK and persists the feedback
        """)
    void givenValidRequest_WhenSavePlaylistFeedbackIsCalled_ThenReturnsSuccess() {
        // Given
        UUID userId = UUID.randomUUID();
        Long playlistId = 123456L;

        PlaylistFeedbackRequest request = new PlaylistFeedbackRequest();
        request.setPlaylistId(playlistId);
        request.setLiked(true);
        PlaylistFeedbackResponse expectedResponse = new PlaylistFeedbackResponse("Feedback received", true);

        // Mock SecurityContext
        Authentication authentication = mock(Authentication.class);
        SecurityContext securityContext = mock(SecurityContext.class);
        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.getName()).thenReturn(userId.toString());
        SecurityContextHolder.setContext(securityContext);

        when(userService.savePlaylistFeedback(eq(userId), eq(request))).thenReturn(expectedResponse);

        // When
        ResponseEntity<PlaylistFeedbackResponse> response = userController.SavePlaylistFeedback(request);

        // Then
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertNotNull(response.getBody());
        assertEquals("Feedback received", response.getBody().getMessage());

        verify(userService, times(1)).savePlaylistFeedback(eq(userId), eq(request));
    }

    @Test
    @DisplayName("""
        Given a request with missing fields
        When SavePlaylistFeedback is called
        Then it returns 400 Bad Request
        """)
    void givenMissingFields_WhenSavePlaylistFeedbackIsCalled_ThenReturnsBadRequest() {
        // Given
        // Case 1: Missing playlistId
        PlaylistFeedbackRequest requestMissingId = new PlaylistFeedbackRequest();
        requestMissingId.setLiked(true);

        // Case 2: Missing liked status
        PlaylistFeedbackRequest requestMissingLiked = new PlaylistFeedbackRequest();
        requestMissingLiked.setPlaylistId(12345L);

        // Mock SecurityContext
        Authentication authentication = mock(Authentication.class);
        SecurityContext securityContext = mock(SecurityContext.class);
        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.getName()).thenReturn(UUID.randomUUID().toString());
        SecurityContextHolder.setContext(securityContext);

        // When & Then for Request 1
        ResponseEntity<PlaylistFeedbackResponse> response1 = userController.SavePlaylistFeedback(requestMissingId);
        assertEquals(HttpStatus.BAD_REQUEST, response1.getStatusCode());
        assertEquals("Some fields are missing", response1.getBody().getMessage());

        // When & Then for Request 2
        ResponseEntity<PlaylistFeedbackResponse> response2 = userController.SavePlaylistFeedback(requestMissingLiked);
        assertEquals(HttpStatus.BAD_REQUEST, response2.getStatusCode());
        assertEquals("Some fields are missing", response2.getBody().getMessage());

        verify(userService, never()).savePlaylistFeedback(any(), any());
    }

    @Test
    @DisplayName("""
        Given an unauthenticated context (null principal)
        When SavePlaylistFeedback is called
        Then it returns 401 Unauthorized
        """)
    void givenNullPrincipal_WhenSavePlaylistFeedbackIsCalled_ThenReturnsUnauthorized() {
        // Given
        PlaylistFeedbackRequest request = new PlaylistFeedbackRequest();
        request.setPlaylistId(123456L);
        request.setLiked(true);

        // Mock SecurityContext to return NULL name
        Authentication authentication = mock(Authentication.class);
        SecurityContext securityContext = mock(SecurityContext.class);
        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.getName()).thenReturn(null);
        SecurityContextHolder.setContext(securityContext);

        // When
        ResponseEntity<PlaylistFeedbackResponse> response = userController.SavePlaylistFeedback(request);

        // Then
        assertEquals(HttpStatus.UNAUTHORIZED, response.getStatusCode());
        assertEquals("Invalid JWT", response.getBody().getMessage());

        verify(userService, never()).savePlaylistFeedback(any(), any());
    }


}

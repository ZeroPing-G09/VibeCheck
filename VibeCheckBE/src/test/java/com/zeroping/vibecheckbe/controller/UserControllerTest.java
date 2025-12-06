// package com.zeroping.vibecheckbe.controller;

// import com.zeroping.vibecheckbe.dto.UserPreferencesDTO;
// import com.zeroping.vibecheckbe.entity.User;
// import com.zeroping.vibecheckbe.exception.user.UserNotFoundException;
// import com.zeroping.vibecheckbe.service.UserService;
// import org.junit.jupiter.api.BeforeEach;
// import org.junit.jupiter.api.DisplayName;
// import org.junit.jupiter.api.Test;
// import org.mockito.InjectMocks;
// import org.mockito.Mock;
// import org.mockito.MockitoAnnotations;
// import org.springframework.http.ResponseEntity;
// import org.springframework.security.core.Authentication;
// import org.springframework.security.core.context.SecurityContext;
// import org.springframework.security.core.context.SecurityContextHolder;

// import java.util.List;
// import java.util.Map;
// import java.util.UUID;

// import static org.junit.jupiter.api.Assertions.*;
// import static org.mockito.ArgumentMatchers.any;
// import static org.mockito.ArgumentMatchers.eq;
// import static org.mockito.Mockito.*;

// class UserControllerTest {

//     @Mock
//     private UserService userService;

//     @InjectMocks
//     private UserController userController;

//     @BeforeEach
//     void setUp() {
//         MockitoAnnotations.openMocks(this);
//     }

//     @Test
//     @DisplayName("""
//             Given a valid user ID
//             When getUser is called
//             Then it returns a successful response with user details
//             """)
//     void givenValidId_WhenGetUserIsCalled_ThenReturnsUserDetails() {
//         // Given
//         UUID userId = UUID.randomUUID();
//         Map<String, Object> mockUser = Map.of(
//                 "id", userId,
//                 "display_name", "Andreea",
//                 "avatar_url", "andreea.png",
//                 "email", "andreea@example.com",
//                 "genres", List.of("Pop", "Jazz")
//         );

//         when(userService.getUserById(userId)).thenReturn(mockUser);

//         // When
//         ResponseEntity<Map<String, Object>> response = userController.getUser(userId);

//         // Then
//         assertEquals(200, response.getStatusCode().value());
//         assertNotNull(response.getBody());
//         assertEquals("Andreea", response.getBody().get("display_name"));
//         assertEquals(List.of("Pop", "Jazz"), response.getBody().get("genres"));
//         verify(userService, times(1)).getUserById(userId);
//     }

//     @Test
//     @DisplayName("""
//             Given an invalid user ID
//             When getUser is called
//             Then it returns a 404 not found error
//             """)
//     void givenInvalidId_WhenGetUserIsCalled_ThenThrowsUserNotFoundException() {
//         // Given
//         UUID invalidId = UUID.randomUUID();
//         when(userService.getUserById(invalidId)).thenThrow(new UserNotFoundException("User not found: " + invalidId));

//         // When / Then
//         UserNotFoundException exception = assertThrows(
//                 UserNotFoundException.class,
//                 () -> userController.getUser(invalidId)
//         );

//         assertTrue(exception.getMessage().contains(invalidId.toString()));
//         verify(userService, times(1)).getUserById(invalidId);
//     }

//     @Test
//     @DisplayName("""
//         Given a valid preferences payload
//         When savePreferences is called
//         Then it returns a success message
//         """)
//     void givenValidPreferences_WhenSavePreferencesIsCalled_ThenReturnsSuccess() {
//         // Given
//         UUID userId = UUID.randomUUID();
//         UserPreferencesDTO dto = new UserPreferencesDTO();
//         dto.setTop1GenreId(5L);
//         dto.setTop2GenreId(10L);
//         dto.setTop3GenreId(15L);

//         User mockUser = new User();
//         mockUser.setId(userId);

//         // Mock SecurityContext
//         Authentication authentication = mock(Authentication.class);
//         SecurityContext securityContext = mock(SecurityContext.class);
//         when(securityContext.getAuthentication()).thenReturn(authentication);
//         when(authentication.getName()).thenReturn(userId.toString());
//         SecurityContextHolder.setContext(securityContext);

//         when(userService.updateUserPreferences(eq(userId), any(UserPreferencesDTO.class)))
//                 .thenReturn(mockUser);

//         // When
//         ResponseEntity<Map<String, Object>> response = userController.savePreferences(dto);

//         // Then
//         assertEquals(200, response.getStatusCode().value());
//         assertNotNull(response.getBody());
//         assertTrue((Boolean) response.getBody().get("success"));
//         assertEquals("Preferences updated successfully.", response.getBody().get("message"));

//         verify(userService, times(1)).updateUserPreferences(eq(userId), any(UserPreferencesDTO.class));
//     }

//     @Test
//     @DisplayName("""
//         Given a valid preferences payload
//         When the service throws an exception
//         Then it returns internal server error
//         """)
//     void givenValidPreferences_WhenServiceThrowsException_ThenReturnsInternalError() {
//         // Given
//         UUID userId = UUID.randomUUID();
//         UserPreferencesDTO dto = new UserPreferencesDTO();
//         dto.setTop1GenreId(5L);
//         dto.setTop2GenreId(10L);
//         dto.setTop3GenreId(15L);

//         // Mock SecurityContext
//         Authentication authentication = mock(Authentication.class);
//         SecurityContext securityContext = mock(SecurityContext.class);
//         when(securityContext.getAuthentication()).thenReturn(authentication);
//         when(authentication.getName()).thenReturn(userId.toString());
//         SecurityContextHolder.setContext(securityContext);

//         doThrow(new RuntimeException("DB error"))
//                 .when(userService).updateUserPreferences(eq(userId), any(UserPreferencesDTO.class));

//         // When
//         ResponseEntity<Map<String, Object>> response = userController.savePreferences(dto);

//         // Then
//         assertEquals(500, response.getStatusCode().value());
//         assertNotNull(response.getBody());
//         assertFalse((Boolean) response.getBody().get("success"));
//         assertEquals("Internal error updating preferences.", response.getBody().get("message"));
//         verify(userService, times(1)).updateUserPreferences(eq(userId), any(UserPreferencesDTO.class));
//     }
// }

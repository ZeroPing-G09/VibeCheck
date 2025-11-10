package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.exception.genre.GenreNotFoundException;
import com.zeroping.vibecheckbe.service.GenreService;
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
import static org.mockito.Mockito.*;

class GenreControllerTest {

    @Mock
    private GenreService genreService;

    @InjectMocks
    private GenreController genreController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    @DisplayName("""
            Given valid data
            When getAllGenres is called
            Then it returns a successful response with genres
            """)
    void givenValidData_WhenGetAllGenresIsCalled_ThenReturnsGenresList() {
        // Given
        List<Map<String, Object>> mockGenres = List.of(
                Map.of("id", 1L, "name", "Rock"),
                Map.of("id", 2L, "name", "Pop")
        );

        when(genreService.getAllGenres()).thenReturn(mockGenres);

        // When
        ResponseEntity<List<Map<String, Object>>> response = genreController.getAllGenres();

        // Then
        assertEquals(200, response.getStatusCode().value());
        assertEquals(2, response.getBody().size());
        assertEquals("Rock", response.getBody().get(0).get("name"));
        verify(genreService, times(1)).getAllGenres();
    }

    @Test
    @DisplayName("""
            Given a valid ID
            When getGenreById is called
            Then it returns a successful response with genre details
            """)
    void givenValidId_WhenGetGenreByIdIsCalled_ThenReturnsGenreDetails() {
        // Given
        Map<String, Object> mockGenre = Map.of("id", 1L, "name", "Jazz");
        when(genreService.getGenreById(1L)).thenReturn(mockGenre);

        // When
        ResponseEntity<Map<String, Object>> response = genreController.getGenreById(1L);

        // Then
        assertEquals(200, response.getStatusCode().value());
        assertEquals("Jazz", response.getBody().get("name"));
        verify(genreService, times(1)).getGenreById(1L);
    }

    @Test
    @DisplayName("""
            Given no genres in the database
            When getAllGenres is called
            Then it returns a successful response with an empty list
            """)
    void givenNoGenres_WhenGetAllGenresIsCalled_ThenReturnsEmptyList() {
        // Given
        when(genreService.getAllGenres()).thenReturn(List.of());

        // When
        ResponseEntity<List<Map<String, Object>>> response = genreController.getAllGenres();

        // Then
        assertEquals(200, response.getStatusCode().value());
        assertTrue(response.getBody().isEmpty());
        verify(genreService, times(1)).getAllGenres();
    }

    @Test
    @DisplayName("""
            Given an invalid ID
            When getGenreById is called
            Then it returns a 404 not found error
            """)
    void givenInvalidId_WhenGetGenreByIdIsCalled_ThenThrowsGenreNotFoundException() {
        // Given
        Long invalidId = 999L;
        when(genreService.getGenreById(invalidId)).thenThrow(new GenreNotFoundException(invalidId));

        // When / Then
        GenreNotFoundException exception = assertThrows(
                GenreNotFoundException.class,
                () -> genreController.getGenreById(invalidId)
        );

        assertTrue(exception.getMessage().contains("999"));
        verify(genreService, times(1)).getGenreById(invalidId);
    }

    @Test
    @DisplayName("""
            Given a non-numeric ID input
            When calling getGenreById
            Then it returns a type conversion error before service execution
            """)
    void givenInvalidTypeId_WhenGetGenreByIdIsCalled_ThenThrowsException() {
        assertThrows(NumberFormatException.class, () -> {
            Long invalidId = Long.valueOf("abc");
            genreController.getGenreById(invalidId);
        });

        verify(genreService, never()).getGenreById(any());
    }
}

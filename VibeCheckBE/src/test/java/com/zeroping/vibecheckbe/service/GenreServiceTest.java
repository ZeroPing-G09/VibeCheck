package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.entity.Genre;
import com.zeroping.vibecheckbe.exception.genre.GenreNotFoundException;
import com.zeroping.vibecheckbe.repository.GenreRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class GenreServiceTest {

    @Mock
    private GenreRepository genreRepository;

    @InjectMocks
    private GenreService genreService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    @DisplayName("""
            Given existing genres in the repository
            When getAllGenres is called
            Then it returns a list of genres with their IDs and names
            """)
    void givenExistingGenres_WhenGetAllGenresIsCalled_ThenReturnsGenreList() {
        // Given
        Genre genre1 = new Genre();
        genre1.setId(1L);
        genre1.setName("Rock");

        Genre genre2 = new Genre();
        genre2.setId(2L);
        genre2.setName("Pop");

        when(genreRepository.findAll()).thenReturn(List.of(genre1, genre2));

        // When
        List<Map<String, Object>> result = genreService.getAllGenres();

        // Then
        assertEquals(2, result.size());
        assertEquals("Rock", result.get(0).get("name"));
        assertEquals(2L, result.get(1).get("id"));
        verify(genreRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("""
            Given a valid genre ID
            When getGenreById is called
            Then it returns the correct genre data as a map
            """)
    void givenValidId_WhenGetGenreByIdIsCalled_ThenReturnsGenreData() {
        // Given
        Genre genre = new Genre();
        genre.setId(1L);
        genre.setName("Jazz");

        when(genreRepository.findById(1L)).thenReturn(Optional.of(genre));

        // When
        Map<String, Object> result = genreService.getGenreById(1L);

        // Then
        assertEquals(1L, result.get("id"));
        assertEquals("Jazz", result.get("name"));
        verify(genreRepository, times(1)).findById(1L);
    }

    @Test
    @DisplayName("""
            Given an empty repository
            When getAllGenres is called
            Then it returns an empty list
            """)
    void givenEmptyRepository_WhenGetAllGenresIsCalled_ThenReturnsEmptyList() {
        // Given
        when(genreRepository.findAll()).thenReturn(List.of());

        // When
        List<Map<String, Object>> result = genreService.getAllGenres();

        // Then
        assertNotNull(result);
        assertTrue(result.isEmpty());
        verify(genreRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("""
            Given a non-existent genre ID
            When getGenreById is called
            Then it throws a GenreNotFoundException
            """)
    void givenNonExistentId_WhenGetGenreByIdIsCalled_ThenThrowsGenreNotFoundException() {
        // Given
        Long invalidId = 999L;
        when(genreRepository.findById(invalidId)).thenReturn(Optional.empty());

        // When / Then
        GenreNotFoundException exception = assertThrows(
                GenreNotFoundException.class,
                () -> genreService.getGenreById(invalidId)
        );

        assertTrue(exception.getMessage().contains("999"));
        verify(genreRepository, times(1)).findById(invalidId);
    }
}

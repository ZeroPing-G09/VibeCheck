package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.entity.Genre;
import com.zeroping.vibecheckbe.exception.genre.GenreNotFoundException;
import com.zeroping.vibecheckbe.repository.GenreRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

// Service class for managing genres
@Service
public class GenreService {
    private final GenreRepository genreRepository;

    public GenreService(GenreRepository genreRepository) {
        this.genreRepository = genreRepository;
    }

    // Retrieve all genres
    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllGenres() {
        List<Genre> genres = genreRepository.findAll();
        return genres.stream()
                .map(g -> {
                    Map<String, Object> genreMap = new HashMap<>();
                    genreMap.put("id", g.getId());
                    genreMap.put("name", g.getName());
                    return genreMap;
                })
                .collect(Collectors.toList());
    }

    // Retrieve a genre by its ID
    @Transactional(readOnly = true)
    public Map<String, Object> getGenreById(Long id) {
        Genre genre = genreRepository.findById(id)
                .orElseThrow(() -> new GenreNotFoundException(id));

        return Map.of(
                "id", genre.getId(),
                "name", genre.getName()
        );
    }
}

package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.entity.Genre;
import com.zeroping.vibecheckbe.repository.GenreRepository;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/genres")
public class GenreController {

    private final GenreRepository genreRepository;

    public GenreController(GenreRepository genreRepository) {
        this.genreRepository = genreRepository;
    }

    @GetMapping
    public List<Map<String, Object>> getAllGenres() {
        List<Genre> genres = genreRepository.findAll();

        return genres.stream()
                .map(g -> {
                    Map<String, Object> genreMap = new HashMap<>();
                    genreMap.put("id", g.getId());
                    genreMap.put("name", g.getName());
                    return genreMap;
                })
                .toList();
    }

    @GetMapping("/{id}")
    public Map<String, Object> getGenreById(@PathVariable Long id) {
        Genre genre = genreRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Genre not found"));

        Map<String, Object> genreMap = new HashMap<>();
        genreMap.put("id", genre.getId());
        genreMap.put("name", genre.getName());
        return genreMap;
    }
}

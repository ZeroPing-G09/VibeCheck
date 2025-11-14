package com.zeroping.vibecheckbe.controller;

import com.zeroping.vibecheckbe.service.GenreService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/genres")
public class GenreController {

    private final GenreService genreService;

    public GenreController(GenreService genreService) {
        this.genreService = genreService;
    }

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getAllGenres() {
        List<Map<String, Object>> genres = genreService.getAllGenres();
        return ResponseEntity.ok(genres);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getGenreById(@PathVariable Long id) {
        Map<String, Object> genre = genreService.getGenreById(id);
        return ResponseEntity.ok(genre);
    }
}

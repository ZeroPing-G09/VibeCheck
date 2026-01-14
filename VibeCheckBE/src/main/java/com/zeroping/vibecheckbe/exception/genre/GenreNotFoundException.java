package com.zeroping.vibecheckbe.exception.genre;

// Custom exception for when a genre is not found
public class GenreNotFoundException extends RuntimeException {
    public GenreNotFoundException(Long id) {
        super("Genre with ID " + id + " not found.");
    }

    public GenreNotFoundException(String message) {
        super(message);
    }
}

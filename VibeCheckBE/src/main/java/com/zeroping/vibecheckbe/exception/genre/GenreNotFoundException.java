package com.zeroping.vibecheckbe.exception.genre;

public class GenreNotFoundException extends RuntimeException {
    public GenreNotFoundException(Long id) {
        super("Genre with ID " + id + " not found.");
    }

    public GenreNotFoundException(String message) {
        super(message);
    }
}

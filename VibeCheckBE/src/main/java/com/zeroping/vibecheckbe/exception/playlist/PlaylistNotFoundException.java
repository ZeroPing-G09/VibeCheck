package com.zeroping.vibecheckbe.exception.playlist;

// Custom exception for handling cases where a playlist is not found
public class PlaylistNotFoundException extends RuntimeException {
    public PlaylistNotFoundException(String message) {
        super(message);
    }
}

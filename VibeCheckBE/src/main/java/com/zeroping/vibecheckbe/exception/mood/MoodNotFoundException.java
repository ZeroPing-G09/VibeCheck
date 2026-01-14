package com.zeroping.vibecheckbe.exception.mood;

// Custom exception for when a mood is not found
public class MoodNotFoundException extends RuntimeException {
    public MoodNotFoundException(Long id) {
        super("Mood not found with id: " + id);
    }
}


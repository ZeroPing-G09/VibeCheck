package com.zeroping.vibecheckbe.exception.mood;

public class MoodNotFoundException extends RuntimeException {
    public MoodNotFoundException(Long id) {
        super("Mood not found with id: " + id);
    }
}


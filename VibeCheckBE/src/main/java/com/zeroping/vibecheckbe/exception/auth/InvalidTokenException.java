package com.zeroping.vibecheckbe.exception.auth;

// Custom exception for invalid authentication tokens
public class InvalidTokenException extends RuntimeException {
    public InvalidTokenException(String message) {
        super(message);
    }
}

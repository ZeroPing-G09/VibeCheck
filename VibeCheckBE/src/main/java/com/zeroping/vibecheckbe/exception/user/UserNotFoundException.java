package com.zeroping.vibecheckbe.exception.user;

// Custom exception for handling cases where a user is not found
public class UserNotFoundException extends RuntimeException {
    public UserNotFoundException(String email) {
        super("User with email " + email + " not found.");
    }
}

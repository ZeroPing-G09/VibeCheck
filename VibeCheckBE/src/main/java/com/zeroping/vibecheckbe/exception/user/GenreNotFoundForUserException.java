package com.zeroping.vibecheckbe.exception.user;

// Custom exception for handling cases where a genre is not found for user assignment
public class GenreNotFoundForUserException extends RuntimeException {
  public GenreNotFoundForUserException(String genreName) {
    super("Genre not found for user assignment: " + genreName);
  }
}

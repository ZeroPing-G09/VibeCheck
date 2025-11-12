package com.zeroping.vibecheckbe.exception.user;

public class GenreNotFoundForUserException extends RuntimeException {
  public GenreNotFoundForUserException(String genreName) {
    super("Genre not found for user assignment: " + genreName);
  }
}

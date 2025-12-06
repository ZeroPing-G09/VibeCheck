package com.zeroping.vibecheckbe.exceptionHandler;

import com.zeroping.vibecheckbe.controller.UserController;
import com.zeroping.vibecheckbe.exception.genre.GenreNotFoundException;
import com.zeroping.vibecheckbe.exception.user.GenreNotFoundForUserException;
import com.zeroping.vibecheckbe.exception.user.UserNotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice(assignableTypes = UserController.class)
public class UserControllerExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(UserControllerExceptionHandler.class);

    @ExceptionHandler(UserNotFoundException.class)
    public ProblemDetail handleUserNotFoundException(UserNotFoundException e) {
        return ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, e.getMessage());
    }

    @ExceptionHandler(GenreNotFoundForUserException.class)
    public ProblemDetail handleInvalidGenreException(GenreNotFoundForUserException e) {
        return ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST, e.getMessage());
    }

    @ExceptionHandler(GenreNotFoundException.class)
    public ProblemDetail handleGenreNotFoundException(GenreNotFoundException e) {
        log.error("Genre not found: {}", e.getMessage());
        return ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, e.getMessage());
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ProblemDetail handleDataIntegrityViolationException(DataIntegrityViolationException e) {
                return ProblemDetail.forStatusAndDetail(HttpStatus.CONFLICT, "A data integrity violation occurred.");
    }

    @ExceptionHandler(Exception.class)
    public ProblemDetail handleGenericException(Exception e) {
        log.error("Unexpected internal error occurred", e);
        return ProblemDetail.forStatusAndDetail(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "An unexpected internal error occurred. Please contact support if this persists."
        );
    }
}


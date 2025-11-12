package com.zeroping.vibecheckbe.exceptionHandler;

import com.zeroping.vibecheckbe.controller.GenreController;
import com.zeroping.vibecheckbe.exception.genre.GenreNotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice(assignableTypes = GenreController.class)
public class GenreControllerExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(GenreControllerExceptionHandler.class);

    @ExceptionHandler(GenreNotFoundException.class)
    public ProblemDetail handleGenreNotFoundException(GenreNotFoundException e) {
        return ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, e.getMessage());
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ProblemDetail handleDataIntegrityViolationException(DataIntegrityViolationException e) {
        log.error("Data integrity violation occurred", e);

        return ProblemDetail.forStatusAndDetail(
                HttpStatus.CONFLICT,
                "A data integrity violation occurred. Please verify your input and try again."
        );
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ProblemDetail handleIllegalArgumentException(IllegalArgumentException e) {
        return ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST, e.getMessage());
    }

    @ExceptionHandler(Exception.class)
    public ProblemDetail handleGenericException(Exception e) {
        return ProblemDetail.forStatusAndDetail(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "Unexpected error: " + e.getMessage()
        );
    }

}

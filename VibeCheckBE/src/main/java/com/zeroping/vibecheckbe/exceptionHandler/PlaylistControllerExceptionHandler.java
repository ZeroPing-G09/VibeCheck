package com.zeroping.vibecheckbe.exceptionHandler;

import com.zeroping.vibecheckbe.controller.PlaylistController;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.io.IOException;

// Centralized exception handler for PlaylistController
@RestControllerAdvice(assignableTypes = PlaylistController.class)
public class PlaylistControllerExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(PlaylistControllerExceptionHandler.class);

    // Handle illegal state exceptions
    @ExceptionHandler(IllegalStateException.class)
    public ProblemDetail handleIllegalState(IllegalStateException e) {
        log.error("Illegal state in playlist service", e);
        return ProblemDetail.forStatusAndDetail(HttpStatus.INTERNAL_SERVER_ERROR, e.getMessage());
    }

    // Handle JSON parsing exceptions
    @ExceptionHandler({JsonParseException.class, JsonMappingException.class})
    public ProblemDetail handleJsonParsing(Exception e) {
        log.error("Failed to parse JSON from AI", e);
        return ProblemDetail.forStatusAndDetail(
                HttpStatus.BAD_REQUEST,
                "Invalid JSON received from AI: " + e.getMessage()
        );
    }

    // Handle I/O exceptions
    @ExceptionHandler(IOException.class)
    public ProblemDetail handleIo(IOException e) {
        log.error("I/O error communicating with AI service", e);
        return ProblemDetail.forStatusAndDetail(
                HttpStatus.SERVICE_UNAVAILABLE,
                "Failed to communicate with AI service: " + e.getMessage()
        );
    }

    // Handle illegal argument exceptions
    @ExceptionHandler(IllegalArgumentException.class)
    public ProblemDetail handleIllegalArgument(IllegalArgumentException e) {
        log.error("Bad request to playlist endpoint", e);
        return ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST, e.getMessage());
    }

    // Handle all other exceptions
    @ExceptionHandler(Exception.class)
    public ProblemDetail handleGeneric(Exception e) {
        log.error("Unexpected error in playlist controller", e);
        return ProblemDetail.forStatusAndDetail(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "Unexpected error: " + e.getMessage()
        );
    }
}

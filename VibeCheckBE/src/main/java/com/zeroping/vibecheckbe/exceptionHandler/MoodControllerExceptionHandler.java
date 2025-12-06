package com.zeroping.vibecheckbe.exceptionHandler;

import com.zeroping.vibecheckbe.controller.MoodController;
import com.zeroping.vibecheckbe.exception.mood.MoodNotFoundException;
import com.zeroping.vibecheckbe.exception.user.UserNotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice(assignableTypes = MoodController.class)
public class MoodControllerExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(MoodControllerExceptionHandler.class);

    @ExceptionHandler(MoodNotFoundException.class)
    public ProblemDetail handleMoodNotFoundException(MoodNotFoundException e) {
        log.error("Mood not found: {}", e.getMessage());
        return ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, e.getMessage());
    }

    @ExceptionHandler(UserNotFoundException.class)
    public ProblemDetail handleUserNotFoundException(UserNotFoundException e) {
        log.error("User not found: {}", e.getMessage());
        return ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, e.getMessage());
    }

    @ExceptionHandler(RuntimeException.class)
    public ProblemDetail handleRuntimeException(RuntimeException e) {
        log.error("Runtime exception in MoodController: {}", e.getMessage(), e);
        e.printStackTrace(); // Print full stack trace to console
        return ProblemDetail.forStatusAndDetail(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "Error processing request: " + e.getMessage() + " | Cause: " + (e.getCause() != null ? e.getCause().getMessage() : "Unknown")
        );
    }

    @ExceptionHandler(Exception.class)
    public ProblemDetail handleGenericException(Exception e) {
        log.error("Unexpected internal error occurred in MoodController", e);
        e.printStackTrace(); // Print full stack trace to console
        String errorMessage = e.getMessage();
        if (e.getCause() != null) {
            errorMessage += " | Caused by: " + e.getCause().getMessage();
        }
        return ProblemDetail.forStatusAndDetail(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "An unexpected internal error occurred: " + errorMessage
        );
    }
}


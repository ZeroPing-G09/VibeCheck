package com.zeroping.vibecheckbe.config;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;

import java.io.IOException;

// Custom handler for access denied exceptions
public class CustomAccessDeniedHandler implements AccessDeniedHandler {
    // Handle access denied exceptions and return a structured JSON response
    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response, AccessDeniedException accessDeniedException)
            throws IOException {
        // Set response status and content type
        response.setStatus(HttpStatus.FORBIDDEN.value());
        response.setContentType("application/json");

        // Create a problem detail JSON response
        String problemDetail = """
                    {
                        "type": "about:blank",
                        "title": "Access Denied",
                        "status": 403,
                        "detail": "You do not have permission to access this resource.",
                        "instance": "%s"
                    }
                """.formatted(request.getRequestURI());

        response.getWriter().write(problemDetail);
    }
}
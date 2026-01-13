package com.zeroping.vibecheckbe.config;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;

import java.io.IOException;

// Custom AuthenticationEntryPoint to return a Problem Details JSON response for unauthorized access
public class CustomAuthenticationEntryPoint implements AuthenticationEntryPoint {
    // Handle unauthorized access attempts
    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException)
            throws IOException {
        // Set response status and content type
        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        response.setContentType("application/json");

        // Create Problem Details JSON response
        String problemDetail = """
                    {
                        "type": "about:blank",
                        "title": "Unauthorized",
                        "status": 401,
                        "detail": "Access to this resource requires authentication.",
                        "instance": "%s"
                    }
                """.formatted(request.getRequestURI());

        // Write the Problem Details JSON response
        response.getWriter().write(problemDetail);
    }
}
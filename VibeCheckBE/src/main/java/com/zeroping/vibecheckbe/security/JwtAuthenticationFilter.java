package com.zeroping.vibecheckbe.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.zeroping.vibecheckbe.exception.auth.InvalidTokenException;
import com.zeroping.vibecheckbe.utils.JwtUtils;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.NonNull;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Collections;
import java.util.UUID;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger DEBUG_LOGGER = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    private final JwtUtils jwtUtils;

    public JwtAuthenticationFilter(JwtUtils jwtUtils) {
        this.jwtUtils = jwtUtils;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, @NonNull HttpServletResponse response, @NonNull FilterChain filterChain)
            throws ServletException, IOException {

        String path = request.getRequestURI();
        
        // Skip JWT validation for public endpoints
        // Allow /moods and /moods/* except /moods/entries (which requires auth)
        boolean isPublicMoodEndpoint = path.startsWith("/moods") && !path.startsWith("/moods/entries");
        boolean isPublicGenreEndpoint = path.startsWith("/genres");
        boolean isPublicUserEndpoint = path.startsWith("/users/by-email");
        
        if (isPublicUserEndpoint || isPublicMoodEndpoint || isPublicGenreEndpoint) {
            filterChain.doFilter(request, response);
            return;
        }

        String bearerToken = request.getHeader("Authorization");
        String jwt = "";
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            jwt = bearerToken.substring(7);
        }

        DEBUG_LOGGER.debug("JWT Authentication Filter - Path: {}, Has Bearer Token: {}, JWT Length: {}", 
                path, StringUtils.hasText(bearerToken), jwt.length());

        try {
            if (StringUtils.hasText(jwt)) {
                if (jwtUtils.validateToken(jwt)) {
                    UUID userId = jwtUtils.getUserIdFromToken(jwt);
                    DEBUG_LOGGER.debug("JWT validated successfully for user: {}", userId);
                    UsernamePasswordAuthenticationToken authToken =
                            new UsernamePasswordAuthenticationToken(
                                    userId.toString(),
                                    jwt,
                                    Collections.singletonList(new SimpleGrantedAuthority("ROLE_AUTHENTICATED"))
                            );
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                } else {
                    DEBUG_LOGGER.warn("JWT token validation failed for path: {}", path);
                    throw new InvalidTokenException("Invalid JWT token");
                }
            } else {
                DEBUG_LOGGER.warn("No JWT token provided for path: {}", path);
                throw new InvalidTokenException("Missing JWT token");
            }
            filterChain.doFilter(request, response);
        } catch (InvalidTokenException ex) {
            DEBUG_LOGGER.error("JWT authentication failed: {}", ex.getMessage());
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            ProblemDetail problemDetail = ProblemDetail.forStatusAndDetail(HttpStatus.UNAUTHORIZED, ex.getMessage());
            response.setContentType("application/problem+json");
            new ObjectMapper().writeValue(response.getWriter(), problemDetail);
            response.getWriter().flush();
        }
    }
}
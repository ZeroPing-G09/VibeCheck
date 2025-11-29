package com.zeroping.vibecheckbe.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.security.Key;
import java.nio.charset.StandardCharsets;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.authority.SimpleGrantedAuthority; // <-- New Import
import java.util.List; // <-- New Import

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger DEBUG_LOGGER = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    @Value("${supabase.jwt-secret}")
    private String jwtSecret;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        // TEMPORARY DEBUG: Log the loaded secret to check for truncation or whitespace issues
        // The logger.info call in doFilterInternal is safer as the @Value injection happens before it runs.
        if (jwtSecret != null && DEBUG_LOGGER.isDebugEnabled()) {
            DEBUG_LOGGER.debug("JWT Secret Check - Length: {} - Starts With: {}",
                    jwtSecret.length(),
                    jwtSecret.substring(0, Math.min(jwtSecret.length(), 10))
            );
        }

        final String authHeader = request.getHeader("Authorization");
        final String jwt;
        final String userId; // This will hold the user's UUID (from 'sub' claim)

        // 1. Check for JWT existence
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        // 2. Extract JWT (strip "Bearer ")
        jwt = authHeader.substring(7);

        try {
            // 3. Validate and Extract Claims (signature, expiration, etc.)
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(jwt)
                    .getBody();

            // Supabase uses 'sub' (subject) to store the user UUID
            userId = claims.getSubject();

            // 4. Set Authentication in Context
            if (userId != null && SecurityContextHolder.getContext().getAuthentication() == null) {

                // Creates an Authentication Token using the UUID as the principal's name
                // FIX: Provide a default, non-null authority to satisfy Spring Security's authorization rules.
                UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                        userId, // Principal
                        null,   // Credentials
                        List.of(new SimpleGrantedAuthority("ROLE_USER")) // Default Authority added
                );

                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                // Set the token in the security context
                SecurityContextHolder.getContext().setAuthentication(authToken);
            }
        } catch (Exception e) {
            logger.error("JWT validation failed for token: " + jwt, e);
            // On failure, authentication remains null, resulting in a 401 later.
        }

        filterChain.doFilter(request, response);
    }

    /**
     * Generates the signing key for JWT verification.
     * FIX: Uses the raw UTF-8 bytes of the Supabase secret string
     * as the HMAC key material to match the signing process.
     */
    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
    }
}
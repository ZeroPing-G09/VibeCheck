package com.zeroping.vibecheckbe.utils;

import com.zeroping.vibecheckbe.exception.auth.InvalidTokenException;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

@Component
public class JwtUtils {

    @Value("${supabase.jwt-secret}")
    private String supabaseSecret;

    private SecretKey getSigningKey() {
        byte[] keyBytes = this.supabaseSecret.getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    public boolean validateToken(String token) throws InvalidTokenException {
        try {
            Jwts.parserBuilder()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            throw new InvalidTokenException("Invalid JWT token");
        }
    }

    public UUID getUserIdFromToken(String token) throws InvalidTokenException {
        try {
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
            String userIdString = claims.getSubject();
            return UUID.fromString(userIdString);
        } catch (Exception e) {
            throw new InvalidTokenException("Invalid JWT token");
        }
    }
}

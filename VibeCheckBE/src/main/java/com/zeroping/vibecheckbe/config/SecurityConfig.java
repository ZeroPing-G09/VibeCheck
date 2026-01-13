package com.zeroping.vibecheckbe.config;

import com.zeroping.vibecheckbe.security.JwtAuthenticationFilter;
import com.zeroping.vibecheckbe.utils.JwtUtils;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

// Custom handlers for authentication and access denied scenarios
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
    @Bean
    public JwtAuthenticationFilter jwtAuthFilter(JwtUtils jwtUtils) {
        return new JwtAuthenticationFilter(jwtUtils);
    }

    @Bean
    public AuthenticationEntryPoint customAuthenticationEntryPoint() {
        return new CustomAuthenticationEntryPoint();
    }

    @Bean
    public AccessDeniedHandler customAccessDeniedHandler() {
        return new CustomAccessDeniedHandler();
    }

    // Security filter chain configuration
    @Bean
    public SecurityFilterChain securityFilterChain(
            HttpSecurity http,
            JwtAuthenticationFilter jwtAuthenticationFilter,
            AuthenticationEntryPoint customAuthenticationEntryPoint,
            AccessDeniedHandler customAccessDeniedHandler
        ) throws Exception {
        http.csrf(AbstractHttpConfigurer::disable)// disable CSRF for API testing
                .exceptionHandling(exception
                        -> exception.authenticationEntryPoint(customAuthenticationEntryPoint)
                        .accessDeniedHandler(customAccessDeniedHandler))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/users/by-email").permitAll() // allow unauthenticated access to this endpoint
                        .requestMatchers("/moods").permitAll() // allow unauthenticated access to moods (public reference data)
                        .requestMatchers("/genres").permitAll() // allow unauthenticated access to genres (public reference data)
                        .anyRequest().authenticated()
                )
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
}


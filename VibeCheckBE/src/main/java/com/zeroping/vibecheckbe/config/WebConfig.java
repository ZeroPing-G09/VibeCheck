package com.zeroping.vibecheckbe.config;

import org.jetbrains.annotations.NotNull;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

// Configuration class to set up CORS for local development environments
// Suppressing warning for using HTTP URLs in allowed origins
@SuppressWarnings("HttpUrlsUsage")
@Configuration
public class WebConfig {
    // CORS configuration to allow requests from local development environments
    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(@NotNull CorsRegistry registry) {
                registry.addMapping("/**")
                        .allowedOriginPatterns(
                                "http://localhost:*",
                                "http://127.0.0.1:*",
                                "http://10.0.2.2:*"  // Android emulator
                        )
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                        .allowCredentials(true)
                        .allowedHeaders("*")
                        .exposedHeaders("Authorization");
            }
        };
    }
}

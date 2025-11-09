package com.zeroping.vibecheckbe.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
public class SecurityConfig {

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // Let Security use your WebMvc CORS config
                .cors(Customizer.withDefaults())
                // No CSRF for simple API calls during dev
                .csrf(csrf -> csrf.disable())
                // Route-level authorization
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()  // preflight
                        .requestMatchers(HttpMethod.GET, "/users/**").permitAll() // <-- your endpoint
                        .anyRequest().authenticated()
                )
                // Keep httpBasic enabled for anything else (optional)
                .httpBasic(Customizer.withDefaults());

        return http.build();
    }
}

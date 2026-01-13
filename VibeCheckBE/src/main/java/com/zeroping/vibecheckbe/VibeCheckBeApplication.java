// Java
package com.zeroping.vibecheckbe;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

// Main application class for VibeCheck backend
@SpringBootApplication(scanBasePackages = "com.zeroping.vibecheckbe")
@EnableJpaRepositories("com.zeroping.vibecheckbe.repository")
@EntityScan("com.zeroping.vibecheckbe.entity")
public class VibeCheckBeApplication {
    public static void main(String[] args) {
        SpringApplication.run(VibeCheckBeApplication.class, args);
    }
}

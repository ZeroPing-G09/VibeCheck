package com.zeroping.vibecheckbe;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;

// remove exclude after connecting to db
@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class })
public class VibeCheckBeApplication {
    public static void main(String[] args) {
        SpringApplication.run(VibeCheckBeApplication.class, args);
    }
}

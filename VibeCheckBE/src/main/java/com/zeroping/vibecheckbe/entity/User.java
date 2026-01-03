package com.zeroping.vibecheckbe.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "\"Users\"", schema = "public")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor

public class User {

    @Id
    private UUID id;

    @Column(name = "display_name")
    private String displayName;
    private String email;

    @Column(name = "last_log_in")
    private Instant lastLogIn;

    @Column(name = "spotify_access_token")
    private String spotifyAccessToken;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
    @Column(name = "avatar_url")
    private String avatarUrl;

    // Mapping the Join Table
    @ManyToMany
    @JoinTable(
            name = "user_genres", // The name of the join table in Supabase
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "genre_id")
    )
    private Set<Genre> genres = new HashSet<>();
}

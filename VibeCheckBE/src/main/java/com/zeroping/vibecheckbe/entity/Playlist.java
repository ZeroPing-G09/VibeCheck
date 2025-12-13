package com.zeroping.vibecheckbe.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.UUID;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "\"Playlists\"", schema = "public")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Playlist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false)
    private String name;


    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "mood")
    private String mood;

    @ManyToMany(cascade = {CascadeType.PERSIST, CascadeType.MERGE})
    @JoinTable(
            name = "playlist_songs",
            joinColumns = @JoinColumn(name = "playlist_id"),
            inverseJoinColumns = @JoinColumn(name = "song_id")
    )
    private Set<Song> songs;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();


    @Column(name = "liked")
    private Boolean liked = false;

    @Column(name = "liked_at")
    private Instant likedAt;
}
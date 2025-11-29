package com.zeroping.vibecheckbe.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.Instant;
import java.util.UUID;
import java.util.Set;

@Entity
@Table(name = "\"Playlists\"", schema = "public")
@Data
@NoArgsConstructor
public class Playlist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "user_id", nullable = false)
    private UUID userId; // Links to the user from auth.users (public.users.id)

    @Column(name = "mood")
    private String mood; // From the PlaylistRequest

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    // Many-to-Many relationship with Song using a join table (playlist_songs)
    @ManyToMany(cascade = {CascadeType.PERSIST, CascadeType.MERGE})
    @JoinTable(
            name = "playlist_songs",
            joinColumns = @JoinColumn(name = "playlist_id"),
            inverseJoinColumns = @JoinColumn(name = "song_id")
    )
    private Set<Song> songs;
}
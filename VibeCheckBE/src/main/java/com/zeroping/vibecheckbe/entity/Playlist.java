package com.zeroping.vibecheckbe.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
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

    // Kept from MAIN: Using UUID is safer if User entity isn't fully mapped or external (Supabase/Auth0)
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    // Kept from MAIN
    @Column(name = "mood")
    private String mood;

    // Kept from MAIN: ManyToMany is the correct way to store songs, not a list of strings
    @ManyToMany(cascade = {CascadeType.PERSIST, CascadeType.MERGE})
    @JoinTable(
            name = "playlist_songs",
            joinColumns = @JoinColumn(name = "playlist_id"),
            inverseJoinColumns = @JoinColumn(name = "song_id")
    )
    private Set<Song> songs;

    // Added from SALVARE branch: Export flags
    @Column(name = "exported_to_spotify")
    private Boolean exportedToSpotify = false;

    @Column(name = "spotify_playlist_id")
    private String spotifyPlaylistId;

    // Kept from MAIN: Instant is generally preferred over LocalDateTime for UTC consistency
    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();
}
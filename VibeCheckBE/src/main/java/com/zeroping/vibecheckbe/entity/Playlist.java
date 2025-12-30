package com.zeroping.vibecheckbe.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "\"Playlists\"", schema = "public")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Playlist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ElementCollection
    @CollectionTable(name = "\"PlaylistTracks\"", joinColumns = @JoinColumn(name = "playlist_id"))
    @Column(name = "track_uri")
    private List<String> trackUris;

    @Column(name = "exported_to_spotify")
    private Boolean exportedToSpotify = false;

    @Column(name = "spotify_playlist_id")
    private String spotifyPlaylistId;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        if (exportedToSpotify == null) {
            exportedToSpotify = false;
        }
    }
}


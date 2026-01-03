package com.zeroping.vibecheckbe.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;

import java.util.Set;

@Entity
@Table(name = "\"Songs\"", schema = "public")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Song {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String url;

    @Column(name = "artist_name", nullable = false)
    private String artistName;

    @ManyToMany(mappedBy = "songs")
    @JsonIgnoreProperties("songs")
    private Set<Playlist> playlists;

    @Column(name = "spotify_uri", nullable = false, unique = true)
    private String spotifyUri;
}

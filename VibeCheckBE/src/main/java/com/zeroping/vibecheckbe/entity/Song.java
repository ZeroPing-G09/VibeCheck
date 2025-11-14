package com.zeroping.vibecheckbe.entity;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;

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

    @Column(nullable = false)
    private String artist_name;


    @OneToMany(mappedBy = "song")
    @JsonManagedReference("song-playlists")
    private List<PlaylistSong> playlistSongs;
}

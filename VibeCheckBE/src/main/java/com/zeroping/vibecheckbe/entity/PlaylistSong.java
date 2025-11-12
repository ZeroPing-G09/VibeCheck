package com.zeroping.vibecheckbe.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@Entity
@Table(name = "\"PlaylistSongs\"", schema = "public")
public class PlaylistSong {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "song_id")
    @JsonBackReference("song-playlists")
    private Song song;

    @ManyToOne
    @JoinColumn(name = "playlist_id")
    @JsonBackReference("playlist-songs")
    private Playlist playlist;

    public PlaylistSong(Playlist playlist, Song song) {
        this.playlist = playlist;
        this.song = song;
    }
}

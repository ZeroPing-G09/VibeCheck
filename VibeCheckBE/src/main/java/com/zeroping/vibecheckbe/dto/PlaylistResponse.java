package com.zeroping.vibecheckbe.dto;

import com.zeroping.vibecheckbe.entity.Song;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PlaylistResponse {
    private PlaylistDTO playlist;
    private List<Song> songs;
}

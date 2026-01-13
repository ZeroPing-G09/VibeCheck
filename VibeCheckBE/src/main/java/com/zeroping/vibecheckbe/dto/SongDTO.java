package com.zeroping.vibecheckbe.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

// DTO for Song
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SongDTO {
    private Long id;
    private String name;
    private String url;
    private String artistName;
}

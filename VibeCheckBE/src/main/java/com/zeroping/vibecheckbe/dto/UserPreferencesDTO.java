package com.zeroping.vibecheckbe.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@NoArgsConstructor
public class UserPreferencesDTO {
    private Long top1GenreId;
    private Long top2GenreId;
    private Long top3GenreId;
}
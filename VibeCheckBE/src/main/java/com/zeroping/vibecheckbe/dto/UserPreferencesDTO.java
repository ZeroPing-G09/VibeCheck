package com.zeroping.vibecheckbe.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

// DTO for User Preferences
@Data
@NoArgsConstructor
public class UserPreferencesDTO {
    private Long top1GenreId;
    private Long top2GenreId;
    private Long top3GenreId;
}
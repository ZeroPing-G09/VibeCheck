package com.zeroping.vibecheckbe.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class UserPreferencesDTO {
    private Long userId;
    
    private Long top1GenreId;
    private Long top2GenreId;
    private Long top3GenreId;
}
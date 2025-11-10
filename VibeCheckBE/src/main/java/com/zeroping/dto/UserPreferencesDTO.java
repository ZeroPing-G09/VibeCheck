package com.zeroping.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class UserPreferencesDTO {
    private Integer userId; 
    
    private Integer top1GenreId;
    private Integer top2GenreId;
    private Integer top3GenreId;
}
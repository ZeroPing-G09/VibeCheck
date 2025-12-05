package com.zeroping.vibecheckbe.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class UserUpdateDTO {
    private String display_name;
    private String profilePicture;
    private UserPreferencesDTO preferences;
}


package com.zeroping.vibecheckbe.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

// DTO for User Update
@Data
@NoArgsConstructor
public class UserUpdateDTO {
    private String display_name;
    private String avatar_url;
    private List<String> genres;
}


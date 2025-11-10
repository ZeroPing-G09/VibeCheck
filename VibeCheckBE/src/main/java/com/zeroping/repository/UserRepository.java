package com.zeroping.repository;

import com.zeroping.dto.UserPreferencesDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class UserRepository {
    private final JdbcTemplate jdbcTemplate;

    @Autowired
    public UserRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public int updatePreferences(Integer userId, UserPreferencesDTO preferences) {
        final String SQL = """
            UPDATE users
            SET top1_genre_id = ?,
                top2_genre_id = ?,
                top3_genre_id = ?
            WHERE id = ?
            """;
        
        return jdbcTemplate.update(
            SQL,
            preferences.getTop1GenreId(), 
            preferences.getTop2GenreId(), 
            preferences.getTop3GenreId(), 
            userId
        );
    }
}
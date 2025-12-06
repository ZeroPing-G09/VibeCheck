package com.zeroping.vibecheckbe.repository;

import com.zeroping.vibecheckbe.entity.Mood;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MoodRepository extends JpaRepository<Mood, Long> {
    Optional<Mood> findByNameIgnoreCase(String name);
}


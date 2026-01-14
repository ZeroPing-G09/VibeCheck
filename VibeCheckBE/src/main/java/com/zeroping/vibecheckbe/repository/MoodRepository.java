package com.zeroping.vibecheckbe.repository;

import com.zeroping.vibecheckbe.entity.Mood;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

// Repository interface for Mood entity
@Repository
public interface MoodRepository extends JpaRepository<Mood, Long> {
}


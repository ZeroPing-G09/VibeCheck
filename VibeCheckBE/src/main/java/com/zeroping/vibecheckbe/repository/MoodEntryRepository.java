package com.zeroping.vibecheckbe.repository;

import com.zeroping.vibecheckbe.entity.MoodEntry;
import com.zeroping.vibecheckbe.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

// Repository interface for MoodEntry entity
@Repository
public interface MoodEntryRepository extends JpaRepository<MoodEntry, Long> {
    List<MoodEntry> findByUserOrderByCreatedAtDesc(User user);
}


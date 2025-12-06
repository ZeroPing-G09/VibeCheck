package com.zeroping.vibecheckbe.repository;

import com.zeroping.vibecheckbe.entity.MoodEntry;
import com.zeroping.vibecheckbe.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface MoodEntryRepository extends JpaRepository<MoodEntry, Long> {
    List<MoodEntry> findByUserOrderByCreatedAtDesc(User user);
    Optional<MoodEntry> findFirstByUserOrderByCreatedAtDesc(User user);
    List<MoodEntry> findByUserAndCreatedAtAfter(User user, LocalDateTime date);
}


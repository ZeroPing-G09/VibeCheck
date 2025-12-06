package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.entity.Mood;
import com.zeroping.vibecheckbe.entity.MoodEntry;
import com.zeroping.vibecheckbe.entity.User;
import com.zeroping.vibecheckbe.exception.user.UserNotFoundException;
import com.zeroping.vibecheckbe.exception.mood.MoodNotFoundException;
import com.zeroping.vibecheckbe.repository.MoodRepository;
import com.zeroping.vibecheckbe.repository.MoodEntryRepository;
import com.zeroping.vibecheckbe.repository.UserRepository;
import com.zeroping.vibecheckbe.util.MoodEmojiMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class MoodService {

    private final MoodRepository moodRepository;
    private final MoodEntryRepository moodEntryRepository;
    private final UserRepository userRepository;

    public MoodService(MoodRepository moodRepository, 
                       MoodEntryRepository moodEntryRepository,
                       UserRepository userRepository) {
        this.moodRepository = moodRepository;
        this.moodEntryRepository = moodEntryRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllMoods() {
        try {
            System.out.println("MoodService.getAllMoods: Starting to fetch moods from repository");
            System.out.println("MoodService.getAllMoods: Repository is null? " + (moodRepository == null));
            
            List<Mood> moods = moodRepository.findAll();
            System.out.println("MoodService.getAllMoods: Found " + moods.size() + " moods in database");
            
            if (moods.isEmpty()) {
                System.out.println("MoodService.getAllMoods: No moods found in database");
                return new ArrayList<>();
            }
            
            return moods.stream()
                    .map(m -> {
                        try {
                            Map<String, Object> moodMap = new HashMap<>();
                            moodMap.put("id", m.getId());
                            moodMap.put("name", m.getName() != null ? m.getName() : "");
                            moodMap.put("tempo", m.getTempo() != null ? m.getTempo() : "");
                            moodMap.put("danceable", m.getDanceable() != null ? m.getDanceable() : "");
                            // Add emoji and color based on mood name
                            String moodName = m.getName() != null ? m.getName() : "";
                            moodMap.put("emoji", MoodEmojiMapper.getEmoji(moodName));
                            moodMap.put("colorCode", MoodEmojiMapper.getColorCode(moodName));
                            return moodMap;
                        } catch (Exception e) {
                            System.err.println("Error mapping mood: " + m.getId() + ", error: " + e.getMessage());
                            e.printStackTrace();
                            throw new RuntimeException("Error processing mood: " + m.getId(), e);
                        }
                    })
                    .collect(Collectors.toList());
        } catch (Exception e) {
            System.err.println("MoodService.getAllMoods error: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to retrieve moods: " + e.getMessage(), e);
        }
    }

    @Transactional
    public Map<String, Object> createMoodEntry(UUID userId, Long moodId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));
        
        Mood mood = moodRepository.findById(moodId)
                .orElseThrow(() -> new MoodNotFoundException(moodId));

        MoodEntry entry = new MoodEntry();
        entry.setUser(user);
        entry.setMood(mood);
        entry.setCreatedAt(java.time.LocalDateTime.now());

        MoodEntry saved = moodEntryRepository.save(entry);

        Map<String, Object> response = new HashMap<>();
        response.put("id", saved.getId());
        response.put("userId", saved.getUser().getId());
        response.put("moodId", saved.getMood().getId());
        response.put("moodName", saved.getMood().getName());
        response.put("moodEmoji", MoodEmojiMapper.getEmoji(saved.getMood().getName()));
        response.put("createdAt", saved.getCreatedAt().toString());
        return response;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getUserMoodEntries(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));

        List<MoodEntry> entries = moodEntryRepository.findByUserOrderByCreatedAtDesc(user);
        return entries.stream()
                .map(e -> {
                    Map<String, Object> entryMap = new HashMap<>();
                    entryMap.put("id", e.getId());
                    entryMap.put("moodId", e.getMood().getId());
                    entryMap.put("moodName", e.getMood().getName());
                    entryMap.put("moodEmoji", MoodEmojiMapper.getEmoji(e.getMood().getName()));
                    entryMap.put("createdAt", e.getCreatedAt().toString());
                    return entryMap;
                })
                .collect(Collectors.toList());
    }
}


package com.zeroping.vibecheckbe.service;

import com.zeroping.vibecheckbe.dto.BatchMoodEntryDTO;
import com.zeroping.vibecheckbe.dto.CreateBatchMoodEntriesDTO;
import com.zeroping.vibecheckbe.dto.CreateMoodEntryDTO;
import com.zeroping.vibecheckbe.dto.MoodEntryResponseDTO;
import com.zeroping.vibecheckbe.dto.MoodHistoryDTO;
import com.zeroping.vibecheckbe.dto.PlaylistDTO;
import com.zeroping.vibecheckbe.entity.Mood;
import com.zeroping.vibecheckbe.entity.MoodEntry;
import com.zeroping.vibecheckbe.entity.User;
import com.zeroping.vibecheckbe.exception.user.UserNotFoundException;
import com.zeroping.vibecheckbe.exception.mood.MoodNotFoundException;
import com.zeroping.vibecheckbe.repository.MoodRepository;
import com.zeroping.vibecheckbe.repository.MoodEntryRepository;
import com.zeroping.vibecheckbe.repository.UserRepository;
import com.zeroping.vibecheckbe.util.MoodEmojiMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;
import java.time.LocalDateTime;

@Service
public class MoodService {

    private static final Logger log = LoggerFactory.getLogger(MoodService.class);

    private final MoodRepository moodRepository;
    private final MoodEntryRepository moodEntryRepository;
    private final UserRepository userRepository;
    private final PlaylistService playlistService;

    public MoodService(MoodRepository moodRepository, 
                       MoodEntryRepository moodEntryRepository,
                       UserRepository userRepository,
                       PlaylistService playlistService) {
        this.moodRepository = moodRepository;
        this.moodEntryRepository = moodEntryRepository;
        this.userRepository = userRepository;
        this.playlistService = playlistService;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getAllMoods() {
        log.debug("getAllMoods: Fetching moods from repository");
        
        List<Mood> moods = moodRepository.findAll();
        log.debug("getAllMoods: Found {} moods in database", moods.size());
        
        if (moods.isEmpty()) {
            return new ArrayList<>();
        }
        
        return moods.stream()
                .map(m -> {
                    Map<String, Object> moodMap = new HashMap<>();
                    moodMap.put("id", m.getId());
                    moodMap.put("name", m.getName() != null ? m.getName() : "");
                    moodMap.put("tempo", m.getTempo() != null ? m.getTempo() : "");
                    moodMap.put("danceable", m.getDanceable() != null ? m.getDanceable() : "");
                    String moodName = m.getName() != null ? m.getName() : "";
                    moodMap.put("emoji", MoodEmojiMapper.getEmoji(moodName));
                    moodMap.put("colorCode", MoodEmojiMapper.getColorCode(moodName));
                    return moodMap;
                })
                .collect(Collectors.toList());
    }

    @Transactional
    public MoodEntryResponseDTO createMoodEntry(CreateMoodEntryDTO dto) {
        User user = userRepository.findById(dto.userId())
                .orElseThrow(() -> new UserNotFoundException("User not found: " + dto.userId()));
        
        Mood mood = moodRepository.findById(dto.moodId())
                .orElseThrow(() -> new MoodNotFoundException(dto.moodId()));

        MoodEntry entry = new MoodEntry();
        entry.setUser(user);
        entry.setMood(mood);
        entry.setIntensity(dto.intensity());
        entry.setNotes(dto.notes());

        MoodEntry saved = moodEntryRepository.save(entry);
        return toResponseDTO(saved);
    }

    @Transactional
    public List<MoodEntryResponseDTO> createMultipleMoodEntries(CreateBatchMoodEntriesDTO dto) {
        User user = userRepository.findById(dto.userId())
                .orElseThrow(() -> new UserNotFoundException("User not found: " + dto.userId()));

        List<MoodEntryResponseDTO> savedEntries = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        for (BatchMoodEntryDTO moodData : dto.moodEntries()) {
            Mood mood = moodRepository.findById(moodData.moodId())
                    .orElseThrow(() -> new MoodNotFoundException(moodData.moodId()));

            MoodEntry entry = new MoodEntry();
            entry.setUser(user);
            entry.setMood(mood);
            entry.setIntensity(moodData.intensity());
            // Use individual notes if provided, otherwise use general notes
            entry.setNotes(moodData.notes() != null ? moodData.notes() : dto.generalNotes());
            entry.setCreatedAt(now); // Same timestamp for all entries in batch

            MoodEntry saved = moodEntryRepository.save(entry);
            savedEntries.add(toResponseDTO(saved));
        }

        return savedEntries;
    }

    @Transactional(readOnly = true)
    public List<MoodEntryResponseDTO> getUserMoodEntries(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));

        List<MoodEntry> entries = moodEntryRepository.findByUserOrderByCreatedAtDesc(user);
        return entries.stream()
                .map(this::toResponseDTO)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<MoodHistoryDTO> getUserMoodHistory(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new UserNotFoundException("User not found: " + userId));

        List<MoodEntry> entries = moodEntryRepository.findByUserOrderByCreatedAtDesc(user);
        
        return entries.stream()
                .map(entry -> {
                    String moodName = entry.getMood().getName();
                    List<PlaylistDTO> playlists = playlistService.getPlaylistsByMood(userId, moodName);
                    
                    MoodHistoryDTO dto = new MoodHistoryDTO();
                    dto.setId(entry.getId());
                    dto.setUserId(entry.getUser().getId());
                    dto.setMoodId(entry.getMood().getId());
                    dto.setMoodName(moodName);
                    dto.setMoodEmoji(MoodEmojiMapper.getEmoji(moodName));
                    dto.setIntensity(entry.getIntensity() != null ? entry.getIntensity() : 50);
                    dto.setNotes(entry.getNotes());
                    dto.setCreatedAt(entry.getCreatedAt());
                    dto.setPlaylists(playlists);
                    
                    return dto;
                })
                .collect(Collectors.toList());
    }

    private MoodEntryResponseDTO toResponseDTO(MoodEntry entry) {
        return new MoodEntryResponseDTO(
                entry.getId(),
                entry.getUser().getId(),
                entry.getMood().getId(),
                entry.getMood().getName(),
                MoodEmojiMapper.getEmoji(entry.getMood().getName()),
                entry.getIntensity() != null ? entry.getIntensity() : 50,
                entry.getNotes(),
                entry.getCreatedAt()
        );
    }
}

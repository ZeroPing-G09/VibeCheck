package com.zeroping.vibecheckbe.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "\"MoodEntries\"", schema = "public")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class MoodEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "mood_id", nullable = false)
    private Mood mood;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "intensity", nullable = false)
    private Integer intensity = 50; // Default to 50% (0-100 scale)

    @Column(name = "notes", nullable = true, columnDefinition = "TEXT")
    private String notes;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        // Ensure intensity is set if null
        if (intensity == null) {
            intensity = 50;
        }
    }
}


package com.zeroping.vibecheckbe.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "\"Users\"", schema = "public")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(name = "profile_picture")
    private String profilePicture;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "top1_genre_id", referencedColumnName = "id")
    private Genre top1Genre;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "top2_genre_id", referencedColumnName = "id")
    private Genre top2Genre;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "top3_genre_id", referencedColumnName = "id")
    private Genre top3Genre;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}

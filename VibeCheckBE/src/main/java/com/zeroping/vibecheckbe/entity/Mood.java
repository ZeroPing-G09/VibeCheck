package com.zeroping.vibecheckbe.entity;

import jakarta.persistence.*;
import lombok.*;

// Genre entity representing a music genre in the database
@Entity
@Table(name = "\"Moods\"", schema = "public")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Mood {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String name;

    @Column(name = "tempo")
    private String tempo;

    @Column(name = "danceable")
    private String danceable;
}


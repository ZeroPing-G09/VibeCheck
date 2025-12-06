package com.zeroping.vibecheckbe.entity;

import jakarta.persistence.*;
import lombok.*;

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

    @Column(name = "tempo", nullable = true)
    private String tempo;

    @Column(name = "danceable", nullable = true)
    private String danceable;
}


package com.zeroping.vibecheckbe.entity;

import jakarta.persistence.*;
import lombok.*;

// Genre entity representing a music genre in the database
@Entity
@Table(name = "\"Genres\"", schema = "public")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Genre {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String name;
}

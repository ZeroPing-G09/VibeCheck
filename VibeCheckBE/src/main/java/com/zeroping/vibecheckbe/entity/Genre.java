package com.zeroping.vibecheckbe.entity;

import jakarta.persistence.*;
import lombok.*;

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

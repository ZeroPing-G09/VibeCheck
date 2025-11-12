package com.zeroping.vibecheckbe.repository;

import com.zeroping.vibecheckbe.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> { }

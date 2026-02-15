package com.learn.wire.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.learn.wire.entity.MatchSessionStateEntity;

public interface MatchSessionStateRepository extends JpaRepository<MatchSessionStateEntity, Long> {

    Optional<MatchSessionStateEntity> findBySessionId(Long sessionId);
}

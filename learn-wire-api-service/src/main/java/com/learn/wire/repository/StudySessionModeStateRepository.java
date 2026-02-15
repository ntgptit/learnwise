package com.learn.wire.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.learn.wire.entity.StudySessionModeStateEntity;

public interface StudySessionModeStateRepository extends JpaRepository<StudySessionModeStateEntity, Long> {

    Optional<StudySessionModeStateEntity> findBySessionIdAndMode(Long sessionId, String mode);

    long countBySessionIdAndStatus(Long sessionId, String status);
}

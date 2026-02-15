package com.learn.wire.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.learn.wire.entity.StudyAttemptEntity;

public interface StudyAttemptRepository extends JpaRepository<StudyAttemptEntity, Long> {

    Optional<StudyAttemptEntity> findBySessionIdAndClientEventId(Long sessionId, String clientEventId);
}

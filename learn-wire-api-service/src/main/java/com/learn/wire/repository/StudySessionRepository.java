package com.learn.wire.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.learn.wire.entity.StudySessionEntity;

public interface StudySessionRepository extends JpaRepository<StudySessionEntity, Long> {

    Optional<StudySessionEntity> findByIdAndDeletedAtIsNull(Long id);

    Optional<StudySessionEntity> findFirstByDeckIdAndStatusAndDeletedAtIsNullOrderByStartedAtDesc(
            Long deckId,
            String status);
}

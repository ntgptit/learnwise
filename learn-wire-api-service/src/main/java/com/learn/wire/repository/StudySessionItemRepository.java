package com.learn.wire.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.learn.wire.entity.StudySessionItemEntity;

public interface StudySessionItemRepository extends JpaRepository<StudySessionItemEntity, Long> {

    List<StudySessionItemEntity> findByModeStateIdOrderByItemOrderAsc(Long modeStateId);
}

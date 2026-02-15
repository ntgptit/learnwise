package com.learn.wire.entity;

import java.time.Instant;

import com.learn.wire.constant.StudyConst;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = StudyConst.SESSION_TABLE_NAME)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class StudySessionEntity extends AuditableSoftDeleteEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "deck_id", nullable = false)
    private Long deckId;

    @Column(name = "active_mode", nullable = false, length = StudyConst.MODE_MAX_LENGTH)
    private String activeMode;

    @Column(name = "status", nullable = false, length = StudyConst.STATUS_MAX_LENGTH)
    private String status;

    @Column(name = "seed", nullable = false)
    private int seed;

    @Column(name = "started_at", nullable = false)
    private Instant startedAt;

    @Column(name = "completed_at")
    private Instant completedAt;
}

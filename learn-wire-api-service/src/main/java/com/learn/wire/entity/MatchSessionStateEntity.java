package com.learn.wire.entity;

import java.time.Instant;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

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
@Table(name = StudyConst.MATCH_STATE_TABLE_NAME)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class MatchSessionStateEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "mode_state_id", nullable = false)
    private Long modeStateId;

    @Column(name = "selected_left_tile_id")
    private Long selectedLeftTileId;

    @Column(name = "selected_right_tile_id")
    private Long selectedRightTileId;

    @Column(name = "interaction_locked", nullable = false)
    private boolean interactionLocked;

    @Column(name = "feedback_status", length = StudyConst.FEEDBACK_STATUS_MAX_LENGTH)
    private String feedbackStatus;

    @Column(name = "feedback_left_tile_id")
    private Long feedbackLeftTileId;

    @Column(name = "feedback_right_tile_id")
    private Long feedbackRightTileId;

    @Column(name = "feedback_until")
    private Instant feedbackUntil;

    @Column(name = "version", nullable = false)
    private int version;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}

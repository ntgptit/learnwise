package com.learn.wire.entity;

import java.time.Instant;

import org.hibernate.annotations.CreationTimestamp;

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
@Table(name = StudyConst.ATTEMPT_TABLE_NAME)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class StudyAttemptEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "session_id", nullable = false)
    private Long sessionId;

    @Column(name = "client_event_id", nullable = false, length = StudyConst.EVENT_ID_MAX_LENGTH)
    private String clientEventId;

    @Column(name = "client_sequence", nullable = false)
    private int clientSequence;

    @Column(name = "event_type", nullable = false, length = StudyConst.EVENT_TYPE_MAX_LENGTH)
    private String eventType;

    @Column(name = "target_index")
    private Integer targetIndex;

    @Column(name = "target_tile_id")
    private Long targetTileId;

    @Column(name = "left_tile_id")
    private Long leftTileId;

    @Column(name = "right_tile_id")
    private Long rightTileId;

    @Column(name = "is_correct")
    private Boolean isCorrect;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}

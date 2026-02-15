package com.learn.wire.entity;

import java.time.Instant;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import com.learn.wire.constant.FlashcardConst;
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
@Table(name = StudyConst.MATCH_TILE_TABLE_NAME)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class MatchSessionTileEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "session_id", nullable = false)
    private Long sessionId;

    @Column(name = "pair_key", nullable = false)
    private int pairKey;

    @Column(name = "side", nullable = false, length = StudyConst.TILE_SIDE_MAX_LENGTH)
    private String side;

    @Column(name = "label_text", nullable = false, length = FlashcardConst.BACK_TEXT_MAX_LENGTH)
    private String labelText;

    @Column(name = "tile_order", nullable = false)
    private int tileOrder;

    @Column(name = "is_matched", nullable = false)
    private boolean matched;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}

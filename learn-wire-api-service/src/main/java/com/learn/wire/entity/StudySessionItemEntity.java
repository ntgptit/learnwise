package com.learn.wire.entity;

import java.time.Instant;

import org.hibernate.annotations.CreationTimestamp;

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
@Table(name = StudyConst.SESSION_ITEM_TABLE_NAME)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class StudySessionItemEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "mode_state_id", nullable = false)
    private Long modeStateId;

    @Column(name = "flashcard_id", nullable = false)
    private Long flashcardId;

    @Column(name = "item_order", nullable = false)
    private int itemOrder;

    @Column(name = "front_text", nullable = false, length = FlashcardConst.FRONT_TEXT_MAX_LENGTH)
    private String frontText;

    @Column(name = "back_text", nullable = false, length = FlashcardConst.BACK_TEXT_MAX_LENGTH)
    private String backText;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}

package com.learn.wire.entity;

import com.learn.wire.constant.FlashcardConst;

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
@Table(name = FlashcardConst.TABLE_NAME)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class FlashcardEntity extends AuditableSoftDeleteEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "deck_id", nullable = false)
    private Long deckId;

    @Column(name = "front_text", nullable = false, length = FlashcardConst.FRONT_TEXT_MAX_LENGTH)
    private String frontText;

    @Column(name = "back_text", nullable = false, length = FlashcardConst.BACK_TEXT_MAX_LENGTH)
    private String backText;

}

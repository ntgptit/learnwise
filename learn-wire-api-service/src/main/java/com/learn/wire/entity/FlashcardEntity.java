package com.learn.wire.entity;

import java.time.Instant;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import com.learn.wire.constant.FlashcardConst;
import com.learn.wire.constant.FolderConst;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = FlashcardConst.TABLE_NAME)
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FlashcardEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "folder_id", nullable = false)
    private Long folderId;

    @Column(name = "front_text", nullable = false, length = FlashcardConst.FRONT_TEXT_MAX_LENGTH)
    private String frontText;

    @Column(name = "back_text", nullable = false, length = FlashcardConst.BACK_TEXT_MAX_LENGTH)
    private String backText;

    @Column(name = "created_by", nullable = false, length = FolderConst.NAME_MAX_LENGTH)
    private String createdBy;

    @Column(name = "updated_by", nullable = false, length = FolderConst.NAME_MAX_LENGTH)
    private String updatedBy;

    @Column(name = "deleted_by", length = FolderConst.NAME_MAX_LENGTH)
    private String deletedBy;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @Column(name = "deleted_at")
    private Instant deletedAt;
}

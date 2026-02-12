package com.learn.wire.entity;

import java.time.Instant;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import com.learn.wire.constant.DeckConst;
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
@Table(name = DeckConst.TABLE_NAME)
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeckEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "folder_id", nullable = false)
    private Long folderId;

    @Column(name = "name", nullable = false, length = DeckConst.NAME_MAX_LENGTH)
    private String name;

    @Column(name = "description", nullable = false, length = DeckConst.DESCRIPTION_MAX_LENGTH)
    private String description;

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

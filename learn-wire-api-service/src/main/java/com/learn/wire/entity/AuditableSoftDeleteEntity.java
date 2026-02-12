package com.learn.wire.entity;

import java.time.Instant;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import com.learn.wire.constant.FolderConst;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import lombok.Setter;

@MappedSuperclass
@Getter
@Setter
public abstract class AuditableSoftDeleteEntity {

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

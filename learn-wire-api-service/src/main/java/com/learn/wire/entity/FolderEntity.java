package com.learn.wire.entity;

import com.learn.wire.constant.FolderConst;

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
@Table(name = FolderConst.TABLE_NAME)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class FolderEntity extends AuditableSoftDeleteEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "name", nullable = false, length = FolderConst.NAME_MAX_LENGTH)
    private String name;

    @Column(name = "description", nullable = false, length = FolderConst.DESCRIPTION_MAX_LENGTH)
    private String description;

    @Column(name = "color_hex", nullable = false, length = FolderConst.COLOR_HEX_MAX_LENGTH)
    private String colorHex;

    @Column(name = "parent_folder_id")
    private Long parentFolderId;

    @Column(name = "direct_flashcard_count", nullable = false)
    private int directFlashcardCount;

    @Column(name = "aggregate_flashcard_count", nullable = false)
    private int aggregateFlashcardCount;

}

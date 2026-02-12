package com.learn.wire.entity;

import com.learn.wire.constant.DeckConst;

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
@Table(name = DeckConst.TABLE_NAME)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class DeckEntity extends AuditableSoftDeleteEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "folder_id", nullable = false)
    private Long folderId;

    @Column(name = "name", nullable = false, length = DeckConst.NAME_MAX_LENGTH)
    private String name;

    @Column(name = "normalized_name", length = DeckConst.NAME_MAX_LENGTH)
    private String normalizedName;

    @Column(name = "description", nullable = false, length = DeckConst.DESCRIPTION_MAX_LENGTH)
    private String description;

}

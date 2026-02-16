package com.learn.wire.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.learn.wire.entity.FolderEntity;

public interface FolderRepository extends JpaRepository<FolderEntity, Long> {

    Optional<FolderEntity> findByIdAndCreatedByAndDeletedAtIsNull(Long id, String createdBy);

    List<FolderEntity> findByCreatedByAndDeletedAtIsNull(String createdBy);

    boolean existsByParentFolderIdAndCreatedByAndDeletedAtIsNull(Long parentFolderId, String createdBy);

    @Query("""
            SELECT folder
            FROM FolderEntity folder
            WHERE folder.deletedAt IS NULL
              AND folder.createdBy = :createdBy
              AND (
                (:parentFolderId IS NULL AND folder.parentFolderId IS NULL)
                OR folder.parentFolderId = :parentFolderId
              )
              AND (
                :search = ''
                OR LOWER(folder.name) LIKE LOWER(CONCAT('%', :search, '%'))
                OR LOWER(folder.description) LIKE LOWER(CONCAT('%', :search, '%'))
              )
            """)
    Page<FolderEntity> findPageByParentAndSearch(
            @Param("parentFolderId") Long parentFolderId,
            @Param("createdBy") String createdBy,
            @Param("search") String search,
            Pageable pageable);

    @Query("""
            SELECT folder.parentFolderId as parentFolderId, COUNT(folder.id) as childCount
            FROM FolderEntity folder
            WHERE folder.deletedAt IS NULL
              AND folder.createdBy = :createdBy
              AND folder.parentFolderId IN :parentIds
            GROUP BY folder.parentFolderId
            """)
    List<ParentChildCountProjection> countActiveChildrenByParentIds(
            @Param("parentIds") List<Long> parentIds,
            @Param("createdBy") String createdBy);

    @Query("""
            SELECT CASE WHEN COUNT(folder.id) > 0 THEN true ELSE false END
            FROM FolderEntity folder
            WHERE folder.deletedAt IS NULL
              AND folder.createdBy = :createdBy
              AND LOWER(folder.name) = LOWER(:name)
              AND (
                (:parentFolderId IS NULL AND folder.parentFolderId IS NULL)
                OR folder.parentFolderId = :parentFolderId
              )
            """)
    boolean existsActiveByParentAndName(
            @Param("parentFolderId") Long parentFolderId,
            @Param("createdBy") String createdBy,
            @Param("name") String name);

    @Query("""
            SELECT CASE WHEN COUNT(folder.id) > 0 THEN true ELSE false END
            FROM FolderEntity folder
            WHERE folder.deletedAt IS NULL
              AND folder.createdBy = :createdBy
              AND folder.id <> :excludeFolderId
              AND LOWER(folder.name) = LOWER(:name)
              AND (
                (:parentFolderId IS NULL AND folder.parentFolderId IS NULL)
                OR folder.parentFolderId = :parentFolderId
              )
            """)
    boolean existsActiveByParentAndNameExcludingFolderId(
            @Param("parentFolderId") Long parentFolderId,
            @Param("createdBy") String createdBy,
            @Param("name") String name,
            @Param("excludeFolderId") Long excludeFolderId);

    interface ParentChildCountProjection {
        Long getParentFolderId();

        long getChildCount();
    }
}

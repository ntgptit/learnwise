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

    Optional<FolderEntity> findByIdAndDeletedAtIsNull(Long id);

    List<FolderEntity> findByDeletedAtIsNull();

    @Query("""
            SELECT folder
            FROM FolderEntity folder
            WHERE folder.deletedAt IS NULL
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
            @Param("search") String search,
            Pageable pageable);

    @Query("""
            SELECT folder.parentFolderId as parentFolderId, COUNT(folder.id) as childCount
            FROM FolderEntity folder
            WHERE folder.deletedAt IS NULL
              AND folder.parentFolderId IN :parentIds
            GROUP BY folder.parentFolderId
            """)
    List<ParentChildCountProjection> countActiveChildrenByParentIds(@Param("parentIds") List<Long> parentIds);

    interface ParentChildCountProjection {
        Long getParentFolderId();

        long getChildCount();
    }
}

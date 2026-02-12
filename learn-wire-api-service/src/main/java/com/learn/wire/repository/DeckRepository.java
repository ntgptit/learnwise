package com.learn.wire.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.learn.wire.entity.DeckEntity;

public interface DeckRepository extends JpaRepository<DeckEntity, Long> {

    Optional<DeckEntity> findByIdAndDeletedAtIsNull(Long id);

    Optional<DeckEntity> findByIdAndFolderIdAndDeletedAtIsNull(Long id, Long folderId);

    boolean existsByFolderIdAndDeletedAtIsNull(Long folderId);

    @Query("""
            SELECT deck
            FROM DeckEntity deck
            WHERE deck.deletedAt IS NULL
              AND deck.folderId = :folderId
              AND (
                :search = ''
                OR LOWER(deck.name) LIKE LOWER(CONCAT('%', :search, '%'))
                OR LOWER(deck.description) LIKE LOWER(CONCAT('%', :search, '%'))
              )
            """)
    Page<DeckEntity> findPageByFolderAndSearch(
            @Param("folderId") Long folderId,
            @Param("search") String search,
            Pageable pageable);

    @Query("""
            SELECT CASE WHEN COUNT(deck.id) > 0 THEN true ELSE false END
            FROM DeckEntity deck
            WHERE deck.deletedAt IS NULL
              AND deck.folderId = :folderId
              AND LOWER(deck.name) = LOWER(:name)
            """)
    boolean existsActiveByFolderAndName(
            @Param("folderId") Long folderId,
            @Param("name") String name);

    @Query("""
            SELECT CASE WHEN COUNT(deck.id) > 0 THEN true ELSE false END
            FROM DeckEntity deck
            WHERE deck.deletedAt IS NULL
              AND deck.folderId = :folderId
              AND deck.id <> :excludeDeckId
              AND LOWER(deck.name) = LOWER(:name)
            """)
    boolean existsActiveByFolderAndNameExcludingDeckId(
            @Param("folderId") Long folderId,
            @Param("name") String name,
            @Param("excludeDeckId") Long excludeDeckId);

    @Query("""
            SELECT deck.folderId as folderId, COUNT(deck.id) as deckCount
            FROM DeckEntity deck
            WHERE deck.deletedAt IS NULL
              AND deck.folderId IN :folderIds
            GROUP BY deck.folderId
            """)
    List<FolderDeckCountProjection> countActiveDecksByFolderIds(@Param("folderIds") List<Long> folderIds);

    interface FolderDeckCountProjection {
        Long getFolderId();

        long getDeckCount();
    }
}

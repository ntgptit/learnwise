package com.learn.wire.repository;

import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.learn.wire.entity.FlashcardEntity;

public interface FlashcardRepository extends JpaRepository<FlashcardEntity, Long> {

    @Query("""
            SELECT flashcard
            FROM FlashcardEntity flashcard
            WHERE flashcard.deletedAt IS NULL
              AND flashcard.folderId = :folderId
              AND (
                :search = ''
                OR LOWER(flashcard.frontText) LIKE LOWER(CONCAT('%', :search, '%'))
                OR LOWER(flashcard.backText) LIKE LOWER(CONCAT('%', :search, '%'))
              )
            """)
    Page<FlashcardEntity> findPageByFolderAndSearch(
            @Param("folderId") Long folderId,
            @Param("search") String search,
            Pageable pageable);

    Optional<FlashcardEntity> findByIdAndFolderIdAndDeletedAtIsNull(Long id, Long folderId);
}

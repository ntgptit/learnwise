package com.learn.wire.repository;

import java.util.List;
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
              AND flashcard.deckId = :deckId
              AND (
                :search = ''
                OR LOWER(flashcard.frontText) LIKE LOWER(CONCAT('%', :search, '%'))
                OR LOWER(flashcard.backText) LIKE LOWER(CONCAT('%', :search, '%'))
              )
            """)
    Page<FlashcardEntity> findPageByDeckAndSearch(
            @Param("deckId") Long deckId,
            @Param("search") String search,
            Pageable pageable);

    Optional<FlashcardEntity> findByIdAndDeckIdAndDeletedAtIsNull(Long id, Long deckId);

    List<FlashcardEntity> findByDeckIdAndDeletedAtIsNull(Long deckId);

    long countByDeckIdAndDeletedAtIsNull(Long deckId);

    @Query("""
            SELECT flashcard.deckId as deckId, COUNT(flashcard.id) as flashcardCount
            FROM FlashcardEntity flashcard
            WHERE flashcard.deletedAt IS NULL
              AND flashcard.deckId IN :deckIds
            GROUP BY flashcard.deckId
            """)
    List<DeckFlashcardCountProjection> countActiveFlashcardsByDeckIds(@Param("deckIds") List<Long> deckIds);

    interface DeckFlashcardCountProjection {
        Long getDeckId();

        long getFlashcardCount();
    }
}

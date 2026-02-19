package com.learn.wire.dto.flashcard.response;

import java.time.Instant;

public record FlashcardResponse(
        Long id,
        Long deckId,
        String frontText,
        String backText,
        String frontLangCode,
        String backLangCode,
        String createdBy,
        String updatedBy,
        String createdByDisplayName,
        String updatedByDisplayName,
        Instant createdAt,
        Instant updatedAt) {
}

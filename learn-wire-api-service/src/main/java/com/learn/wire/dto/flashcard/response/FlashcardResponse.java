package com.learn.wire.dto.flashcard.response;

import java.time.Instant;

public record FlashcardResponse(
        Long id,
        Long folderId,
        String frontText,
        String backText,
        String createdBy,
        String updatedBy,
        Instant createdAt,
        Instant updatedAt) {
}

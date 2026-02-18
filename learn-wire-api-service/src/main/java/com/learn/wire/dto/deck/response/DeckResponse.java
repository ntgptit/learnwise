package com.learn.wire.dto.deck.response;

import java.time.Instant;

public record DeckResponse(
        Long id,
        Long folderId,
        String name,
        String description,
        long flashcardCount,
        String createdBy,
        String updatedBy,
        String createdByDisplayName,
        String updatedByDisplayName,
        Instant createdAt,
        Instant updatedAt) {
}

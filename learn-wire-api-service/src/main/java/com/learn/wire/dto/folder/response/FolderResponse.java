package com.learn.wire.dto.folder.response;

import java.time.Instant;

public record FolderResponse(
        Long id,
        String name,
        String description,
        String colorHex,
        Long parentFolderId,
        int directFlashcardCount,
        int flashcardCount,
        int childFolderCount,
        int directDeckCount,
        String createdBy,
        String updatedBy,
        Instant createdAt,
        Instant updatedAt) {
}

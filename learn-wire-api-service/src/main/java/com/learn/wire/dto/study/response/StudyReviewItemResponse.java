package com.learn.wire.dto.study.response;

public record StudyReviewItemResponse(
        Long sessionItemId,
        Long flashcardId,
        int itemOrder,
        String frontText,
        String backText) {
}

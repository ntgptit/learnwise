package com.learn.wire.dto.study.response;

import java.time.Instant;
import java.util.List;

public record StudySessionResponse(
        Long sessionId,
        Long deckId,
        String mode,
        String status,
        int currentIndex,
        int totalUnits,
        int correctCount,
        int wrongCount,
        boolean completed,
        Instant startedAt,
        Instant completedAt,
        List<StudyReviewItemResponse> reviewItems,
        List<StudyMatchTileResponse> leftTiles,
        List<StudyMatchTileResponse> rightTiles,
        StudyAttemptResultResponse lastAttemptResult,
        int completedModeCount,
        int requiredModeCount,
        boolean sessionCompleted) {
}

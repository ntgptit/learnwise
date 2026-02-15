package com.learn.wire.dto.study.response;

import java.time.Instant;

public record StudyAttemptResultResponse(
        String feedbackStatus,
        Long leftTileId,
        Long rightTileId,
        boolean interactionLocked,
        Instant feedbackUntil) {
}

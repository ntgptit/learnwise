package com.learn.wire.dto.study.request;

public record StudySessionEventRequest(
        String clientEventId,
        Integer clientSequence,
        String eventType,
        Long targetTileId,
        Integer targetIndex) {
}

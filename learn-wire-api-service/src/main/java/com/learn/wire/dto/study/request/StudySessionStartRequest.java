package com.learn.wire.dto.study.request;

public record StudySessionStartRequest(
        String mode,
        Integer seed) {
}

package com.learn.wire.dto.auth.response;

public record AuthMeResponse(
        Long userId,
        String email,
        String username,
        String displayName,
        String themeMode,
        Boolean studyAutoPlayAudio,
        Integer studyCardsPerSession) {
}

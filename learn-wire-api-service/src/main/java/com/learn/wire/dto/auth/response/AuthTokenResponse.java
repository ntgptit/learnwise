package com.learn.wire.dto.auth.response;

public record AuthTokenResponse(
        String accessToken,
        String refreshToken,
        long accessTokenExpiresInSeconds,
        Long userId,
        String email,
        String displayName) {
}

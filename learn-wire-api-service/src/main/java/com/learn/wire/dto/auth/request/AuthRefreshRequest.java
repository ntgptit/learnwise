package com.learn.wire.dto.auth.request;

import com.learn.wire.constant.AuthConst;

import jakarta.validation.constraints.NotBlank;

public record AuthRefreshRequest(
        @NotBlank(message = AuthConst.REFRESH_TOKEN_REQUIRED_MESSAGE) String refreshToken) {
}

package com.learn.wire.dto.auth.request;

import com.learn.wire.constant.AuthConst;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AuthUpdateProfileRequest(
        @NotBlank(message = AuthConst.DISPLAY_NAME_REQUIRED_MESSAGE) @Size(max = AuthConst.DISPLAY_NAME_MAX_LENGTH, message = AuthConst.DISPLAY_NAME_TOO_LONG_MESSAGE) String displayName) {
}

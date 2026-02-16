package com.learn.wire.dto.auth.request;

import com.learn.wire.constant.AuthConst;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record AuthRegisterRequest(
        @NotBlank(message = AuthConst.EMAIL_REQUIRED_MESSAGE) @Email(message = AuthConst.EMAIL_INVALID_MESSAGE) @Size(max = AuthConst.EMAIL_MAX_LENGTH, message = AuthConst.EMAIL_TOO_LONG_MESSAGE) String email,
        @NotBlank(message = AuthConst.PASSWORD_REQUIRED_MESSAGE) @Size(min = AuthConst.PASSWORD_MIN_LENGTH, message = AuthConst.PASSWORD_TOO_SHORT_MESSAGE) @Size(max = AuthConst.PASSWORD_MAX_LENGTH, message = AuthConst.PASSWORD_TOO_LONG_MESSAGE) String password,
        @Size(max = AuthConst.DISPLAY_NAME_MAX_LENGTH, message = AuthConst.DISPLAY_NAME_TOO_LONG_MESSAGE) String displayName) {
}

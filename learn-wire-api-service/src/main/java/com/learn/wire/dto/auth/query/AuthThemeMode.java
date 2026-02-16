package com.learn.wire.dto.auth.query;

import com.learn.wire.constant.AuthConst;
import com.learn.wire.exception.BadRequestException;

public enum AuthThemeMode {
    SYSTEM(AuthConst.THEME_MODE_SYSTEM),
    LIGHT(AuthConst.THEME_MODE_LIGHT),
    DARK(AuthConst.THEME_MODE_DARK);

    private final String value;

    AuthThemeMode(String value) {
        this.value = value;
    }

    public String value() {
        return this.value;
    }

    public static AuthThemeMode fromValue(String rawValue) {
        final String normalizedValue = rawValue == null
                ? ""
                : rawValue.trim();
        for (final AuthThemeMode candidate : values()) {
            if (candidate.value.equalsIgnoreCase(normalizedValue)) {
                return candidate;
            }
        }
        throw new BadRequestException(AuthConst.THEME_MODE_INVALID_KEY);
    }
}
